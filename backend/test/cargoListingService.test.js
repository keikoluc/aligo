require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const db = require('../src/db');
const userService = require('../src/services/userService');
const cargoListingService = require('../src/services/cargoListingService');

let userCounter = 0;
async function makeUser(role) {
  userCounter += 1;
  const user = await userService.createUser({
    email: `${role}${userCounter}@test.com`,
    authProvider: 'email',
    isVerified: true,
  });
  await db.run('UPDATE users SET role = ?, lat = ?, lng = ? WHERE id = ?', [
    role,
    41.3,
    69.24,
    user.id,
  ]);
  return userService.findById(user.id);
}

const ROUTE = {
  pickup: { label: 'A', lat: 41.3, lng: 69.24 },
  dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
};

async function makeVehicle(driverId, amenities = {}) {
  await db.run(
    `INSERT INTO driver_vehicles
       (user_id, brand_model, color, plate_number, size_label,
        has_refrigeration, has_side_rear_tent, has_lift, has_tie_down_straps)
     VALUES (?, 'Truck', 'White', '01A123AA', 'Medium', ?, ?, ?, ?)`,
    [
      driverId,
      amenities.refrigerated ? 1 : 0,
      amenities.sideRearTent ? 1 : 0,
      amenities.lift ? 1 : 0,
      amenities.tieDownStraps ? 1 : 0,
    ]
  );
}

async function makeListing(shipperId, overrides = {}) {
  return cargoListingService.createListing(shipperId, {
    cargoType: 'general',
    price: 50000,
    ...ROUTE,
    ...overrides,
  });
}

test('createListing rejects a missing cargo type', async () => {
  const shipper = await makeUser('shipper');
  const result = await makeListing(shipper.id, { cargoType: '' });
  assert.equal(result.ok, false);
  assert.match(result.error, /cargo type/i);
});

test('createListing rejects a non-positive price', async () => {
  const shipper = await makeUser('shipper');
  const result = await makeListing(shipper.id, { price: 0 });
  assert.equal(result.ok, false);
  assert.match(result.error, /price/i);
});

test('full lifecycle: open -> accepted -> in_transit -> completed', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  assert.equal(created.ok, true);
  assert.equal(created.listing.status, 'open');
  const listingId = created.listing.id;

  const accepted = await cargoListingService.acceptListing(driver.id, listingId);
  assert.equal(accepted.ok, true);
  assert.equal(accepted.listing.status, 'accepted');

  const pickedUp = await cargoListingService.pickupListing(driver.id, listingId);
  assert.equal(pickedUp.ok, true);
  assert.equal(pickedUp.listing.status, 'in_transit');

  const completed = await cargoListingService.completeListing(driver.id, listingId);
  assert.equal(completed.ok, true);
  assert.equal(completed.listing.status, 'completed');
});

test('a second driver cannot accept an already-taken listing', async () => {
  const shipper = await makeUser('shipper');
  const driver1 = await makeUser('driver');
  const driver2 = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver1.id, listingId);
  const second = await cargoListingService.acceptListing(driver2.id, listingId);

  assert.equal(second.ok, false);
  assert.equal(second.reason, 'already_taken');
});

test('completing before pickup is rejected', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  const completed = await cargoListingService.completeListing(driver.id, listingId);

  assert.equal(completed.ok, false);
  assert.equal(completed.reason, 'not_your_delivery');
});

test('shipper can cancel only while the listing is still open', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  const cancelled = await cargoListingService.cancelListing(shipper.id, listingId);

  assert.equal(cancelled.ok, false);
  assert.equal(cancelled.reason, 'not_cancellable');
});

test('shipper can cancel a still-open listing', async () => {
  const shipper = await makeUser('shipper');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  const cancelled = await cargoListingService.cancelListing(shipper.id, listingId);
  assert.equal(cancelled.ok, true);
  assert.equal(cancelled.listing.status, 'cancelled');
});

test('driver release reopens the listing and clears the assignment', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  const released = await cargoListingService.releaseListing(driver.id, listingId);

  assert.equal(released.ok, true);
  assert.equal(released.listing.status, 'open');
  // driverId is a public-API concern applied by toPublicListing — the raw
  // row released.listing carries the snake_case column instead.
  assert.equal(cargoListingService.toPublicListing(released.listing).driverId, null);
});

test('rating requires a completed listing', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  const rated = await cargoListingService.rateListing(shipper.id, listingId, {
    stars: 5,
  });

  assert.equal(rated.ok, false);
  assert.equal(rated.reason, 'not_completed');
});

test('both parties can rate each other once completed; re-rating upserts', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  await cargoListingService.pickupListing(driver.id, listingId);
  await cargoListingService.completeListing(driver.id, listingId);

  const shipperRates = await cargoListingService.rateListing(shipper.id, listingId, {
    stars: 5,
    comment: 'great driver',
  });
  assert.equal(shipperRates.ok, true);
  // myRating is the public-API shape (applied by toPublicListing); the
  // service itself returns the raw row with a snake_case my_rating.
  assert.equal(
    cargoListingService.toPublicListing(shipperRates.listing).myRating.stars,
    5
  );

  const driverRates = await cargoListingService.rateListing(driver.id, listingId, {
    stars: 4,
  });
  assert.equal(driverRates.ok, true);

  // Re-submitting the shipper's rating should update in place, not duplicate.
  const reRated = await cargoListingService.rateListing(shipper.id, listingId, {
    stars: 3,
    comment: 'actually just okay',
  });
  assert.equal(reRated.ok, true);
  assert.equal(
    cargoListingService.toPublicListing(reRated.listing).myRating.stars,
    3
  );

  const rows = await db.all(
    'SELECT * FROM ratings WHERE listing_id = ? AND rater_id = ?',
    [listingId, shipper.id]
  );
  assert.equal(rows.length, 1);
  assert.equal(rows[0].stars, 3);
});

test('rateListing rejects an out-of-range star count', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  const listingId = created.listing.id;

  await cargoListingService.acceptListing(driver.id, listingId);
  await cargoListingService.pickupListing(driver.id, listingId);
  await cargoListingService.completeListing(driver.id, listingId);

  const result = await cargoListingService.rateListing(shipper.id, listingId, {
    stars: 7,
  });
  assert.equal(result.ok, false);
});

test('listNearby sorts open listings by distance from the driver', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  await db.run('UPDATE users SET lat = ?, lng = ? WHERE id = ?', [
    41.3,
    69.24,
    driver.id,
  ]);

  const near = await makeListing(shipper.id, {
    pickup: { label: 'Near', lat: 41.301, lng: 69.241 },
  });
  const far = await makeListing(shipper.id, {
    pickup: { label: 'Far', lat: 41.5, lng: 69.5 },
  });

  const result = await cargoListingService.listNearby(driver.id);
  assert.equal(result.ok, true);
  const ids = result.listings.map((l) => l.id);
  assert.ok(ids.indexOf(near.listing.id) < ids.indexOf(far.listing.id));
});

test('createListing stores and exposes the required vehicle features', async () => {
  const shipper = await makeUser('shipper');
  const created = await makeListing(shipper.id, {
    requiredFeatures: { refrigerated: true, lift: true },
  });

  const publicListing = cargoListingService.toPublicListing(created.listing);
  assert.deepEqual(publicListing.requiredFeatures, {
    refrigerated: true,
    sideRearTent: false,
    lift: true,
    tieDownStraps: false,
  });
});

// These share one in-memory DB across the whole file, so other tests'
// open listings (with no requirements) may also be present — assert on
// whether *this test's* listing shows up, not on the total count.
test('listNearby hides a listing from a driver whose vehicle lacks a required feature', async () => {
  const shipper = await makeUser('shipper');
  const unequippedDriver = await makeUser('driver');
  await makeVehicle(unequippedDriver.id, { refrigerated: false });

  const created = await makeListing(shipper.id, {
    requiredFeatures: { refrigerated: true },
  });

  const result = await cargoListingService.listNearby(unequippedDriver.id);
  assert.equal(result.ok, true);
  assert.equal(
    result.listings.some((l) => l.id === created.listing.id),
    false
  );
});

test('listNearby shows a listing to a driver whose vehicle has the required feature', async () => {
  const shipper = await makeUser('shipper');
  const equippedDriver = await makeUser('driver');
  await makeVehicle(equippedDriver.id, { refrigerated: true });

  const created = await makeListing(shipper.id, {
    requiredFeatures: { refrigerated: true },
  });

  const result = await cargoListingService.listNearby(equippedDriver.id);
  assert.equal(result.ok, true);
  assert.equal(
    result.listings.some((l) => l.id === created.listing.id),
    true
  );
});

test('listNearby hides a listing from a driver with no vehicle on file when a feature is required', async () => {
  const shipper = await makeUser('shipper');
  const noVehicleDriver = await makeUser('driver');

  const created = await makeListing(shipper.id, { requiredFeatures: { lift: true } });

  const result = await cargoListingService.listNearby(noVehicleDriver.id);
  assert.equal(result.ok, true);
  assert.equal(
    result.listings.some((l) => l.id === created.listing.id),
    false
  );
});

test('acceptListing rejects a driver whose vehicle does not meet the requirement', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  await makeVehicle(driver.id, { refrigerated: false });

  const created = await makeListing(shipper.id, {
    requiredFeatures: { refrigerated: true },
  });

  const result = await cargoListingService.acceptListing(driver.id, created.listing.id);
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'vehicle_mismatch');
});

test('acceptListing succeeds when the driver vehicle meets the requirement', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  await makeVehicle(driver.id, { refrigerated: true });

  const created = await makeListing(shipper.id, {
    requiredFeatures: { refrigerated: true },
  });

  const result = await cargoListingService.acceptListing(driver.id, created.listing.id);
  assert.equal(result.ok, true);
  assert.equal(result.listing.status, 'accepted');
});

test('updateListing edits a still-open listing', async () => {
  const shipper = await makeUser('shipper');
  const created = await makeListing(shipper.id, { cargoType: 'general', price: 50000 });

  const result = await cargoListingService.updateListing(shipper.id, created.listing.id, {
    cargoType: 'furniture',
    price: 75000,
    ...ROUTE,
    requiredFeatures: { lift: true },
  });

  assert.equal(result.ok, true);
  assert.equal(result.listing.cargo_type, 'furniture');
  assert.equal(result.listing.price, 75000);
  const publicListing = cargoListingService.toPublicListing(result.listing);
  assert.equal(publicListing.requiredFeatures.lift, true);
});

test('updateListing rejects invalid data the same way createListing does', async () => {
  const shipper = await makeUser('shipper');
  const created = await makeListing(shipper.id);

  const result = await cargoListingService.updateListing(shipper.id, created.listing.id, {
    cargoType: 'general',
    price: -5,
    ...ROUTE,
  });

  assert.equal(result.ok, false);
  assert.match(result.error, /price/i);
});

test('updateListing refuses to edit a listing that is no longer open', async () => {
  const shipper = await makeUser('shipper');
  const driver = await makeUser('driver');
  const created = await makeListing(shipper.id);
  await cargoListingService.acceptListing(driver.id, created.listing.id);

  const result = await cargoListingService.updateListing(shipper.id, created.listing.id, {
    cargoType: 'furniture',
    price: 99999,
    ...ROUTE,
  });

  assert.equal(result.ok, false);
  assert.equal(result.reason, 'not_editable');
});

test('updateListing refuses to edit another shipper\'s listing', async () => {
  const shipper = await makeUser('shipper');
  const otherShipper = await makeUser('shipper');
  const created = await makeListing(shipper.id);

  const result = await cargoListingService.updateListing(
    otherShipper.id,
    created.listing.id,
    { cargoType: 'furniture', price: 99999, ...ROUTE }
  );

  assert.equal(result.ok, false);
  assert.equal(result.reason, 'not_editable');
});
