require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const db = require('../src/db');
const userService = require('../src/services/userService');
const cargoListingService = require('../src/services/cargoListingService');
const adminService = require('../src/services/adminService');

const ROUTE = {
  pickup: { label: 'A', lat: 41.3, lng: 69.24 },
  dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
};

test('getStats aggregates users by role and listings by status', async () => {
  const shipper = await userService.createUser({
    email: 'stats-shipper@test.com',
    authProvider: 'email',
    isVerified: true,
  });
  await db.run("UPDATE users SET role = 'shipper' WHERE id = ?", [shipper.id]);
  await cargoListingService.createListing(shipper.id, {
    cargoType: 'general',
    price: 1000,
    ...ROUTE,
  });

  const stats = await adminService.getStats();
  assert.equal(stats.usersByRole.shipper, 1);
  assert.equal(stats.listingsByStatus.open, 1);
});

test('listUsers filters by search term across email and name', async () => {
  await userService.createUser({
    email: 'findme@test.com',
    fullName: 'Findable Person',
    authProvider: 'email',
    isVerified: true,
  });
  await userService.createUser({
    email: 'other@test.com',
    fullName: 'Someone Else',
    authProvider: 'email',
    isVerified: true,
  });

  const results = await adminService.listUsers('findme');
  assert.equal(results.length, 1);
  assert.equal(results[0].email, 'findme@test.com');
});

test('forceCancelListing cancels an open listing', async () => {
  const shipper = await userService.createUser({
    email: 'cancel-shipper@test.com',
    authProvider: 'email',
    isVerified: true,
  });
  const created = await cargoListingService.createListing(shipper.id, {
    cargoType: 'general',
    price: 1000,
    ...ROUTE,
  });

  const result = await adminService.forceCancelListing(created.listing.id);
  assert.equal(result.ok, true);

  const row = await db.get('SELECT status FROM cargo_listings WHERE id = ?', [
    created.listing.id,
  ]);
  assert.equal(row.status, 'cancelled');
});

test('forceCancelListing refuses to touch a completed listing', async () => {
  const shipper = await userService.createUser({
    email: 'completed-shipper@test.com',
    authProvider: 'email',
    isVerified: true,
  });
  const created = await cargoListingService.createListing(shipper.id, {
    cargoType: 'general',
    price: 1000,
    ...ROUTE,
  });
  await db.run("UPDATE cargo_listings SET status = 'completed' WHERE id = ?", [
    created.listing.id,
  ]);

  const result = await adminService.forceCancelListing(created.listing.id);
  assert.equal(result.ok, false);
});
