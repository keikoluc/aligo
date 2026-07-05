const db = require('../db');
const userService = require('./userService');
const { emitListingUpdated, emitListingLocation } = require('../realtime');
const { sendPush } = require('./pushService');
const telegramClient = require('./telegramClient');

// Fire-and-forget Telegram DM to whichever party has linked their chat —
// a no-op if they haven't (see telegramLinkService). Mirrors sendPush's
// "best effort, never throws" contract.
function notifyTelegram(chatId, text) {
  telegramClient.sendMessage(chatId, text);
}

// Maps a required-feature key (matches VehicleAmenity.apiKey on the
// Flutter side) to its column on cargo_listings (what the shipper
// asked for) and on driver_vehicles (what a given driver's truck has).
const FEATURE_COLUMNS = {
  refrigerated: { requires: 'requires_refrigeration', has: 'has_refrigeration' },
  sideRearTent: { requires: 'requires_side_rear_tent', has: 'has_side_rear_tent' },
  lift: { requires: 'requires_lift', has: 'has_lift' },
  tieDownStraps: { requires: 'requires_tie_down_straps', has: 'has_tie_down_straps' },
};

// Joins in both parties' contact details, push token, and aggregate
// rating (from the ratings table), so toPublicListing can expose the
// public bits once a listing is matched, without a second round-trip
// per row. fcm_token never leaves this module — it's for sendPush only.
const LISTING_SELECT = `
  SELECT cl.*,
         su.full_name AS shipper_full_name, su.phone AS shipper_phone, su.fcm_token AS shipper_fcm_token,
         su.telegram_chat_id AS shipper_telegram_chat_id,
         du.full_name AS driver_full_name, du.phone AS driver_phone, du.fcm_token AS driver_fcm_token,
         du.telegram_chat_id AS driver_telegram_chat_id,
         sr.avg_stars AS shipper_rating_avg, sr.rating_count AS shipper_rating_count,
         dr.avg_stars AS driver_rating_avg, dr.rating_count AS driver_rating_count
  FROM cargo_listings cl
  LEFT JOIN users su ON su.id = cl.shipper_id
  LEFT JOIN users du ON du.id = cl.driver_id
  LEFT JOIN (SELECT ratee_id, AVG(stars) AS avg_stars, COUNT(*) AS rating_count FROM ratings GROUP BY ratee_id) sr
    ON sr.ratee_id = cl.shipper_id
  LEFT JOIN (SELECT ratee_id, AVG(stars) AS avg_stars, COUNT(*) AS rating_count FROM ratings GROUP BY ratee_id) dr
    ON dr.ratee_id = cl.driver_id
`;

function haversineKm(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function isValidPoint(point) {
  return (
    point &&
    typeof point.label === 'string' &&
    point.label.trim() &&
    typeof point.lat === 'number' &&
    typeof point.lng === 'number'
  );
}

function validateListing({ cargoType, pickup, dropoff, price }) {
  if (typeof cargoType !== 'string' || !cargoType.trim()) {
    return 'Cargo type is required.';
  }
  if (!isValidPoint(pickup)) {
    return 'A valid pickup location is required.';
  }
  if (!isValidPoint(dropoff)) {
    return 'A valid dropoff location is required.';
  }
  if (typeof price !== 'number' || !Number.isFinite(price) || price <= 0) {
    return 'Price must be a positive number.';
  }
  return null;
}

// A driver with no vehicle on file, or one missing a capability the
// shipper explicitly asked for, can't take that listing.
function driverMeetsRequirements(vehicle, listingRow) {
  for (const { requires, has } of Object.values(FEATURE_COLUMNS)) {
    if (listingRow[requires] && !(vehicle && vehicle[has])) {
      return false;
    }
  }
  return true;
}

async function findById(listingId) {
  return db.get(`${LISTING_SELECT} WHERE cl.id = ?`, [listingId]);
}

async function createListing(shipperId, payload) {
  const error = validateListing(payload);
  if (error) {
    return { ok: false, error };
  }

  const { cargoType, description, pickup, dropoff, price, requiredFeatures = {} } =
    payload;
  const info = await db.run(
    `INSERT INTO cargo_listings
       (shipper_id, cargo_type, description, pickup_label, pickup_lat, pickup_lng,
        dropoff_label, dropoff_lat, dropoff_lng, price,
        requires_refrigeration, requires_side_rear_tent, requires_lift, requires_tie_down_straps)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      shipperId,
      cargoType.trim(),
      description ? String(description).trim() : null,
      pickup.label.trim(),
      pickup.lat,
      pickup.lng,
      dropoff.label.trim(),
      dropoff.lat,
      dropoff.lng,
      price,
      requiredFeatures.refrigerated ? 1 : 0,
      requiredFeatures.sideRearTent ? 1 : 0,
      requiredFeatures.lift ? 1 : 0,
      requiredFeatures.tieDownStraps ? 1 : 0,
    ]
  );

  const listing = await findById(info.lastInsertRowid);
  return { ok: true, listing };
}

// Shipper corrects a mistake (wrong price, address, cargo type, etc.)
// — only while the listing is still open, since changing terms after a
// driver has committed would be unfair to them.
async function updateListing(shipperId, listingId, payload) {
  const error = validateListing(payload);
  if (error) {
    return { ok: false, error };
  }

  const { cargoType, description, pickup, dropoff, price, requiredFeatures = {} } =
    payload;
  const result = await db.run(
    `UPDATE cargo_listings
     SET cargo_type = ?, description = ?, pickup_label = ?, pickup_lat = ?, pickup_lng = ?,
         dropoff_label = ?, dropoff_lat = ?, dropoff_lng = ?, price = ?,
         requires_refrigeration = ?, requires_side_rear_tent = ?, requires_lift = ?, requires_tie_down_straps = ?
     WHERE id = ? AND shipper_id = ? AND status = 'open'`,
    [
      cargoType.trim(),
      description ? String(description).trim() : null,
      pickup.label.trim(),
      pickup.lat,
      pickup.lng,
      dropoff.label.trim(),
      dropoff.lat,
      dropoff.lng,
      price,
      requiredFeatures.refrigerated ? 1 : 0,
      requiredFeatures.sideRearTent ? 1 : 0,
      requiredFeatures.lift ? 1 : 0,
      requiredFeatures.tieDownStraps ? 1 : 0,
      listingId,
      shipperId,
    ]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_editable' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  return { ok: true, listing };
}

async function listNearby(driverId) {
  const driver = await userService.findById(driverId);
  if (driver.lat == null || driver.lng == null) {
    return {
      ok: false,
      error: 'Complete your profile address to see nearby loads.',
    };
  }

  const vehicle = await db.get('SELECT * FROM driver_vehicles WHERE user_id = ?', [
    driverId,
  ]);

  const rows = await db.all(`${LISTING_SELECT} WHERE cl.status = 'open'`);
  const listings = rows
    .filter((row) => driverMeetsRequirements(vehicle, row))
    .map((row) => ({
      ...row,
      distanceKm: haversineKm(driver.lat, driver.lng, row.pickup_lat, row.pickup_lng),
    }))
    .sort((a, b) => a.distanceKm - b.distanceKm);

  return { ok: true, listings };
}

// Pushes the listing's latest state to anyone (shipper or driver)
// currently watching it, so they don't have to poll to see a status
// change someone else made.
function broadcastListing(listing) {
  emitListingUpdated(listing.id, toPublicListing(listing));
}

async function acceptListing(driverId, listingId) {
  // Defense in depth: listNearby already hides mismatched loads, but a
  // driver could still hit this endpoint directly for a listing that
  // needs a capability their truck doesn't have.
  const listingRow = await db.get('SELECT * FROM cargo_listings WHERE id = ?', [
    listingId,
  ]);
  if (!listingRow) {
    return { ok: false, reason: 'not_found' };
  }
  const vehicle = await db.get('SELECT * FROM driver_vehicles WHERE user_id = ?', [
    driverId,
  ]);
  if (!driverMeetsRequirements(vehicle, listingRow)) {
    return { ok: false, reason: 'vehicle_mismatch' };
  }

  const result = await db.run(
    "UPDATE cargo_listings SET status = 'accepted', driver_id = ? WHERE id = ? AND status = 'open'",
    [driverId, listingId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'already_taken' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  sendPush(listing.shipper_fcm_token, {
    title: 'Haydovchi topildi!',
    body: `${listing.driver_full_name || 'Haydovchi'} yukingizni qabul qildi.`,
    data: { listingId: String(listingId), type: 'accepted' },
  });
  notifyTelegram(
    listing.shipper_telegram_chat_id,
    `🚚 Haydovchi topildi!\n${listing.driver_full_name || 'Haydovchi'} yukingizni qabul qildi.`
  );
  return { ok: true, listing };
}

async function pickupListing(driverId, listingId) {
  const result = await db.run(
    "UPDATE cargo_listings SET status = 'in_transit' WHERE id = ? AND driver_id = ? AND status = 'accepted'",
    [listingId, driverId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_your_delivery' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  sendPush(listing.shipper_fcm_token, {
    title: 'Yuk olib ketildi',
    body: 'Haydovchi yukingizni yuklab oldi va yo\'lda.',
    data: { listingId: String(listingId), type: 'in_transit' },
  });
  notifyTelegram(
    listing.shipper_telegram_chat_id,
    "🚛 Yukingiz olib ketildi va yo'lda."
  );
  return { ok: true, listing };
}

async function completeListing(driverId, listingId) {
  const result = await db.run(
    "UPDATE cargo_listings SET status = 'completed' WHERE id = ? AND driver_id = ? AND status = 'in_transit'",
    [listingId, driverId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_your_delivery' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  sendPush(listing.shipper_fcm_token, {
    title: 'Yetkazib berildi!',
    body: 'Yukingiz muvaffaqiyatli yetkazildi.',
    data: { listingId: String(listingId), type: 'completed' },
  });
  notifyTelegram(listing.shipper_telegram_chat_id, '✅ Yukingiz muvaffaqiyatli yetkazildi!');
  return { ok: true, listing };
}

// Shipper backs out of a listing before any driver has taken it.
async function cancelListing(shipperId, listingId) {
  const result = await db.run(
    "UPDATE cargo_listings SET status = 'cancelled' WHERE id = ? AND shipper_id = ? AND status = 'open'",
    [listingId, shipperId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_cancellable' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  return { ok: true, listing };
}

// Driver backs out after accepting — reopens the listing for other
// drivers rather than leaving the shipper stranded.
async function releaseListing(driverId, listingId) {
  const result = await db.run(
    `UPDATE cargo_listings
     SET status = 'open', driver_id = NULL, driver_lat = NULL,
         driver_lng = NULL, driver_location_updated_at = NULL
     WHERE id = ? AND driver_id = ? AND status IN ('accepted', 'in_transit')`,
    [listingId, driverId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_your_delivery' : 'not_found' };
  }

  const listing = await findById(listingId);
  broadcastListing(listing);
  sendPush(listing.shipper_fcm_token, {
    title: 'Haydovchi voz kechdi',
    body: 'Yukingiz yana ochiq e\'lonlar ro\'yxatiga qaytdi.',
    data: { listingId: String(listingId), type: 'open' },
  });
  notifyTelegram(
    listing.shipper_telegram_chat_id,
    "↩️ Haydovchi voz kechdi. Yukingiz yana ochiq e'lonlar ro'yxatiga qaytdi."
  );
  return { ok: true, listing };
}

async function updateDriverLocation(driverId, listingId, lat, lng) {
  const updatedAt = new Date().toISOString();
  const result = await db.run(
    `UPDATE cargo_listings
     SET driver_lat = ?, driver_lng = ?, driver_location_updated_at = ?
     WHERE id = ? AND driver_id = ? AND status IN ('accepted', 'in_transit')`,
    [lat, lng, updatedAt, listingId, driverId]
  );

  if (result.changes === 0) {
    const existing = await db.get('SELECT id FROM cargo_listings WHERE id = ?', [
      listingId,
    ]);
    return { ok: false, reason: existing ? 'not_your_delivery' : 'not_found' };
  }

  emitListingLocation(listingId, { lat, lng, updatedAt });
  const listing = await findById(listingId);
  return { ok: true, listing };
}

// Either party rates the other once a listing is completed. Upserts on
// (listing_id, rater_id) so re-submitting edits the existing rating
// instead of erroring or creating a duplicate.
async function rateListing(raterId, listingId, { stars, comment }) {
  if (!Number.isInteger(stars) || stars < 1 || stars > 5) {
    return { ok: false, error: 'Stars must be an integer between 1 and 5.' };
  }

  const listing = await findById(listingId);
  if (!listing) {
    return { ok: false, reason: 'not_found' };
  }
  if (listing.status !== 'completed') {
    return { ok: false, reason: 'not_completed' };
  }

  let rateeId;
  let rateeToken;
  let rateeChatId;
  if (listing.shipper_id === raterId) {
    rateeId = listing.driver_id;
    rateeToken = listing.driver_fcm_token;
    rateeChatId = listing.driver_telegram_chat_id;
  } else if (listing.driver_id === raterId) {
    rateeId = listing.shipper_id;
    rateeToken = listing.shipper_fcm_token;
    rateeChatId = listing.shipper_telegram_chat_id;
  } else {
    return { ok: false, reason: 'forbidden' };
  }

  await db.run(
    `INSERT INTO ratings (listing_id, rater_id, ratee_id, stars, comment)
     VALUES (?, ?, ?, ?, ?)
     ON CONFLICT (listing_id, rater_id)
     DO UPDATE SET stars = excluded.stars, comment = excluded.comment`,
    [listingId, raterId, rateeId, stars, comment ? String(comment).trim() : null]
  );

  sendPush(rateeToken, {
    title: 'Yangi baho',
    body: `Sizga ${stars}★ baho berildi.`,
    data: { listingId: String(listingId), type: 'rated' },
  });
  notifyTelegram(rateeChatId, `⭐ Sizga ${stars}★ baho berildi.`);

  const updatedListing = await findById(listingId);
  const [withRating] = await attachMyRatings([updatedListing], raterId);
  return { ok: true, listing: withRating };
}

// Batches "did I already rate this listing" onto a list of rows so list
// endpoints don't need one query per listing.
async function attachMyRatings(rows, userId) {
  if (rows.length === 0) return rows;
  const ids = rows.map((r) => r.id);
  const placeholders = ids.map(() => '?').join(',');
  const myRatings = await db.all(
    `SELECT listing_id, stars, comment FROM ratings WHERE rater_id = ? AND listing_id IN (${placeholders})`,
    [userId, ...ids]
  );
  const byListingId = new Map(myRatings.map((r) => [r.listing_id, r]));
  return rows.map((r) => ({ ...r, my_rating: byListingId.get(r.id) ?? null }));
}

async function getById(userId, listingId) {
  const listing = await findById(listingId);
  if (!listing) {
    return { ok: false, reason: 'not_found' };
  }
  if (listing.shipper_id !== userId && listing.driver_id !== userId) {
    return { ok: false, reason: 'forbidden' };
  }
  const [withRating] = await attachMyRatings([listing], userId);
  return { ok: true, listing: withRating };
}

async function listMine(shipperId) {
  const rows = await db.all(
    `${LISTING_SELECT} WHERE cl.shipper_id = ? ORDER BY cl.created_at DESC, cl.id DESC`,
    [shipperId]
  );
  return attachMyRatings(rows, shipperId);
}

async function listMineAsDriver(driverId) {
  const rows = await db.all(
    `${LISTING_SELECT} WHERE cl.driver_id = ? ORDER BY cl.created_at DESC, cl.id DESC`,
    [driverId]
  );
  return attachMyRatings(rows, driverId);
}

// Postgres returns AVG()/COUNT() as numeric strings (to avoid silent
// precision loss) while better-sqlite3 returns real JS numbers for the
// same query — normalize here so the JSON contract (and the Dart
// `as num?` casts that parse it) doesn't depend on which DB is active.
function toNumberOrNull(value) {
  return value == null ? null : Number(value);
}

function toPublicListing(row) {
  const isMatched = row.status !== 'open';
  return {
    id: row.id,
    shipperId: row.shipper_id,
    cargoType: row.cargo_type,
    description: row.description,
    pickup: { label: row.pickup_label, lat: row.pickup_lat, lng: row.pickup_lng },
    dropoff: { label: row.dropoff_label, lat: row.dropoff_lat, lng: row.dropoff_lng },
    price: row.price,
    status: row.status,
    driverId: row.driver_id,
    distanceKm: row.distanceKm ?? null,
    createdAt: row.created_at,
    requiredFeatures: {
      refrigerated: !!row.requires_refrigeration,
      sideRearTent: !!row.requires_side_rear_tent,
      lift: !!row.requires_lift,
      tieDownStraps: !!row.requires_tie_down_straps,
    },
    // Only reveal contact details once the two parties are actually
    // matched — not while a listing is still open and unclaimed.
    shipper: isMatched
      ? {
          fullName: row.shipper_full_name,
          phone: row.shipper_phone,
          ratingAvg: toNumberOrNull(row.shipper_rating_avg),
          ratingCount: toNumberOrNull(row.shipper_rating_count) ?? 0,
        }
      : null,
    driver: isMatched && row.driver_id
      ? {
          fullName: row.driver_full_name,
          phone: row.driver_phone,
          ratingAvg: toNumberOrNull(row.driver_rating_avg),
          ratingCount: toNumberOrNull(row.driver_rating_count) ?? 0,
        }
      : null,
    driverLocation: isMatched && row.driver_lat != null && row.driver_lng != null
      ? {
          lat: row.driver_lat,
          lng: row.driver_lng,
          updatedAt: row.driver_location_updated_at,
        }
      : null,
    myRating: row.my_rating
      ? { stars: row.my_rating.stars, comment: row.my_rating.comment }
      : null,
  };
}

module.exports = {
  haversineKm,
  createListing,
  updateListing,
  listNearby,
  acceptListing,
  pickupListing,
  completeListing,
  cancelListing,
  releaseListing,
  updateDriverLocation,
  rateListing,
  getById,
  listMine,
  listMineAsDriver,
  toPublicListing,
};
