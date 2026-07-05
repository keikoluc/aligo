const db = require('../db');

// Postgres returns COUNT()/AVG() as numeric strings (to avoid silent
// precision loss) while better-sqlite3 returns real JS numbers for the
// same query — normalize here so the admin panel's JSON contract
// doesn't depend on which DB is active.
function toNumberOrNull(value) {
  return value == null ? null : Number(value);
}

async function getStats() {
  const [userRows, listingRows, ratingRow] = await Promise.all([
    db.all("SELECT role, COUNT(*) AS count FROM users GROUP BY role"),
    db.all('SELECT status, COUNT(*) AS count FROM cargo_listings GROUP BY status'),
    db.get('SELECT COUNT(*) AS count, AVG(stars) AS avg_stars FROM ratings'),
  ]);

  return {
    usersByRole: Object.fromEntries(
      userRows.map((r) => [r.role || 'unassigned', toNumberOrNull(r.count)])
    ),
    listingsByStatus: Object.fromEntries(
      listingRows.map((r) => [r.status, toNumberOrNull(r.count)])
    ),
    totalRatings: toNumberOrNull(ratingRow.count) ?? 0,
    avgRating: toNumberOrNull(ratingRow.avg_stars),
  };
}

async function listUsers(search) {
  const SELECT =
    'SELECT id, email, full_name, role, phone, is_verified, created_at FROM users';
  if (search) {
    return db.all(
      `${SELECT} WHERE email LIKE ? OR full_name LIKE ? ORDER BY id DESC LIMIT 200`,
      [`%${search}%`, `%${search}%`]
    );
  }
  return db.all(`${SELECT} ORDER BY id DESC LIMIT 200`);
}

async function listListings(status) {
  const SELECT =
    'SELECT id, cargo_type, status, price, shipper_id, driver_id, created_at FROM cargo_listings';
  if (status) {
    return db.all(`${SELECT} WHERE status = ? ORDER BY created_at DESC LIMIT 200`, [
      status,
    ]);
  }
  return db.all(`${SELECT} ORDER BY created_at DESC LIMIT 200`);
}

// Admin override: force a listing off the board regardless of whose turn
// it is to act, for moderation (e.g. a stuck or disputed delivery).
// Completed listings are left alone — the trade already happened.
async function forceCancelListing(listingId) {
  const result = await db.run(
    "UPDATE cargo_listings SET status = 'cancelled' WHERE id = ? AND status != 'completed'",
    [listingId]
  );
  return { ok: result.changes > 0 };
}

module.exports = { getStats, listUsers, listListings, forceCancelListing };
