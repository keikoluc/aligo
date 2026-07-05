require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const pricingService = require('../src/services/pricingService');

test('estimatePrice applies the matching category rate', () => {
  // furniture: base 25000 + 2200/km * 10km = 47000
  assert.equal(pricingService.estimatePrice('furniture', 10), 47000);
});

test('estimatePrice falls back to the general rate for an unknown category', () => {
  const known = pricingService.estimatePrice('general', 5);
  const unknown = pricingService.estimatePrice('not-a-real-category', 5);
  assert.equal(unknown, known);
});

test('estimatePrice rounds to the nearest 1000', () => {
  // general: base 15000 + 1500/km * 1.3km = 16950 -> rounds to 17000
  assert.equal(pricingService.estimatePrice('general', 1.3), 17000);
});

test('estimatePrice adds a surcharge for each required vehicle feature', () => {
  const base = pricingService.estimatePrice('general', 5);
  const withRefrigeration = pricingService.estimatePrice('general', 5, {
    refrigerated: true,
  });
  assert.equal(
    withRefrigeration,
    base + pricingService.FEATURE_SURCHARGES.refrigerated
  );
});

test('estimatePrice stacks surcharges for multiple required features', () => {
  const base = pricingService.estimatePrice('general', 5);
  const withBoth = pricingService.estimatePrice('general', 5, {
    refrigerated: true,
    lift: true,
  });
  assert.equal(
    withBoth,
    base +
      pricingService.FEATURE_SURCHARGES.refrigerated +
      pricingService.FEATURE_SURCHARGES.lift
  );
});

test('estimatePrice ignores features set to false', () => {
  const base = pricingService.estimatePrice('general', 5);
  const withFalseFeatures = pricingService.estimatePrice('general', 5, {
    refrigerated: false,
    lift: false,
  });
  assert.equal(withFalseFeatures, base);
});

test('fetchRouteDistanceKm fails clearly when no Mapbox token is configured', async () => {
  await assert.rejects(
    () =>
      pricingService.fetchRouteDistanceKm(
        { lat: 41.3, lng: 69.24 },
        { lat: 41.33, lng: 69.28 }
      ),
    /MAPBOX_ACCESS_TOKEN/
  );
});
