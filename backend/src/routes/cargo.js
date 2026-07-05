const express = require('express');

const { requireAuth } = require('../middleware/auth');
const cargoListingService = require('../services/cargoListingService');
const pricingService = require('../services/pricingService');
const userService = require('../services/userService');
const { t } = require('../i18n');

const router = express.Router();

async function requireRole(req, res, role) {
  const user = await userService.findById(req.userId);
  if (!user || user.role !== role) {
    res
      .status(403)
      .json({ error: t(`Only ${role}s can perform this action.`, req.locale) });
    return null;
  }
  return user;
}

function parseCoord(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num : null;
}

function parseBool(value) {
  return value === true || value === 'true';
}

function requiredFeaturesFromQuery(query) {
  return {
    refrigerated: parseBool(query.refrigerated),
    sideRearTent: parseBool(query.sideRearTent),
    lift: parseBool(query.lift),
    tieDownStraps: parseBool(query.tieDownStraps),
  };
}

router.get('/estimate', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'shipper');
  if (!user) return;

  const { cargoType, pickupLat, pickupLng, dropoffLat, dropoffLng } = req.query;

  const pickup = { lat: parseCoord(pickupLat), lng: parseCoord(pickupLng) };
  const dropoff = { lat: parseCoord(dropoffLat), lng: parseCoord(dropoffLng) };
  if (
    typeof cargoType !== 'string' ||
    !cargoType.trim() ||
    pickup.lat == null ||
    pickup.lng == null ||
    dropoff.lat == null ||
    dropoff.lng == null
  ) {
    return res.status(400).json({
      error: t(
        'cargoType, pickup and dropoff coordinates are required.',
        req.locale
      ),
    });
  }

  try {
    const { distanceKm, durationMin } = await pricingService.fetchRouteDistanceKm(pickup, dropoff);
    const suggestedPrice = pricingService.estimatePrice(
      cargoType,
      distanceKm,
      requiredFeaturesFromQuery(req.query)
    );
    return res.json({ distanceKm, durationMin, suggestedPrice });
  } catch (err) {
    console.error(err);
    return res
      .status(502)
      .json({ error: t('Could not estimate a price right now.', req.locale) });
  }
});

router.post('/', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'shipper');
  if (!user) return;

  const { cargoType, description, pickup, dropoff, price, requiredFeatures } =
    req.body || {};
  const result = await cargoListingService.createListing(req.userId, {
    cargoType,
    description,
    pickup,
    dropoff,
    price,
    requiredFeatures,
  });

  if (!result.ok) {
    return res.status(400).json({ error: t(result.error, req.locale) });
  }
  return res
    .status(201)
    .json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.put('/:id', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'shipper');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const { cargoType, description, pickup, dropoff, price, requiredFeatures } =
    req.body || {};
  const result = await cargoListingService.updateListing(req.userId, listingId, {
    cargoType,
    description,
    pickup,
    dropoff,
    price,
    requiredFeatures,
  });

  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    if (result.reason === 'not_editable') {
      return res.status(409).json({
        error: t(
          'This listing can no longer be edited — a driver may have already accepted it.',
          req.locale
        ),
      });
    }
    return res.status(400).json({ error: t(result.error, req.locale) });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.get('/nearby', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const result = await cargoListingService.listNearby(req.userId);
  if (!result.ok) {
    return res.status(400).json({ error: t(result.error, req.locale) });
  }
  return res.json({
    listings: result.listings.map(cargoListingService.toPublicListing),
  });
});

router.post('/:id/accept', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.acceptListing(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    if (result.reason === 'vehicle_mismatch') {
      return res.status(409).json({
        error: t(
          'Your vehicle does not have a capability this load requires.',
          req.locale
        ),
        reason: 'vehicle_mismatch',
      });
    }
    return res.status(409).json({
      error: t('This load was already accepted by another driver.', req.locale),
      reason: 'already_taken',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/pickup', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.pickupListing(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res.status(409).json({
      error: t(
        'This delivery is not currently assigned to you, or was already picked up.',
        req.locale
      ),
      reason: 'not_your_delivery',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/complete', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.completeListing(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res.status(409).json({
      error: t(
        'This delivery is not currently assigned to you, or the cargo has not been picked up yet.',
        req.locale
      ),
      reason: 'not_your_delivery',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/cancel', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'shipper');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.cancelListing(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res.status(409).json({
      error: t(
        'This listing can no longer be cancelled — a driver may have already accepted it.',
        req.locale
      ),
      reason: 'not_cancellable',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/release', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.releaseListing(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res.status(409).json({
      error: t('This delivery is not currently assigned to you.', req.locale),
      reason: 'not_your_delivery',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/rate', requireAuth, async (req, res) => {
  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const { stars, comment } = req.body || {};
  const result = await cargoListingService.rateListing(req.userId, listingId, {
    stars,
    comment,
  });
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    if (result.reason === 'not_completed') {
      return res
        .status(409)
        .json({ error: t('You can only rate a completed delivery.', req.locale) });
    }
    if (result.reason === 'forbidden') {
      return res
        .status(403)
        .json({ error: t('You are not part of this listing.', req.locale) });
    }
    return res.status(400).json({ error: t(result.error, req.locale) });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.post('/:id/location', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const { lat, lng } = req.body || {};
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    return res.status(400).json({ error: t('lat and lng must be numbers.', req.locale) });
  }

  const result = await cargoListingService.updateDriverLocation(
    req.userId,
    listingId,
    lat,
    lng
  );
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res.status(409).json({
      error: t(
        'This delivery is not currently assigned to you, or is not active.',
        req.locale
      ),
      reason: 'not_your_delivery',
    });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

router.get('/mine', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'shipper');
  if (!user) return;

  const rows = await cargoListingService.listMine(req.userId);
  return res.json({ listings: rows.map(cargoListingService.toPublicListing) });
});

router.get('/deliveries', requireAuth, async (req, res) => {
  const user = await requireRole(req, res, 'driver');
  if (!user) return;

  const rows = await cargoListingService.listMineAsDriver(req.userId);
  return res.json({ listings: rows.map(cargoListingService.toPublicListing) });
});

// Wildcard GET /:id must be declared last among GET routes so it doesn't
// shadow the literal paths above (/nearby, /mine, /deliveries). Either the
// shipper or the assigned driver may fetch a listing this way, so it's
// authorized via getById rather than requireRole.
router.get('/:id', requireAuth, async (req, res) => {
  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await cargoListingService.getById(req.userId, listingId);
  if (!result.ok) {
    if (result.reason === 'not_found') {
      return res.status(404).json({ error: t('Listing not found.', req.locale) });
    }
    return res
      .status(403)
      .json({ error: t('You do not have access to this listing.', req.locale) });
  }
  return res.json({ listing: cargoListingService.toPublicListing(result.listing) });
});

module.exports = router;
