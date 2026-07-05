// Placeholder per-category rates in UZS. Tune these to real-world
// economics once we have data — they're a starting estimate, not a
// pricing policy decision baked in from research.
const RATE_TABLE = {
  general: { label: 'Umumiy yuk', baseFare: 15000, perKm: 1500 },
  furniture: { label: 'Mebel', baseFare: 25000, perKm: 2200 },
  construction: { label: 'Qurilish materiallari', baseFare: 30000, perKm: 2500 },
  perishable: { label: 'Oziq-ovqat / tez buziluvchi', baseFare: 20000, perKm: 1800 },
  equipment: { label: 'Texnika / uskuna', baseFare: 25000, perKm: 2000 },
};

const DEFAULT_RATE = RATE_TABLE.general;

// Flat surcharges for special vehicle capabilities the shipper requires
// (not just whatever the eventual driver's truck happens to have — see
// cargoListingService's matching filter). Keys match VehicleAmenity.apiKey
// on the Flutter side and driver_vehicles' has_* columns on the backend.
const FEATURE_SURCHARGES = {
  refrigerated: 15000,
  sideRearTent: 8000,
  lift: 10000,
  tieDownStraps: 5000,
};

function rateFor(cargoType) {
  return RATE_TABLE[cargoType] || DEFAULT_RATE;
}

// Rounds to the nearest 1000 UZS so suggested prices don't look like a
// raw formula output (e.g. 47500 -> 48000).
function roundPrice(amount) {
  return Math.round(amount / 1000) * 1000;
}

function estimatePrice(cargoType, distanceKm, requiredFeatures = {}) {
  const rate = rateFor(cargoType);
  let total = rate.baseFare + rate.perKm * distanceKm;
  for (const [feature, surcharge] of Object.entries(FEATURE_SURCHARGES)) {
    if (requiredFeatures[feature]) total += surcharge;
  }
  return roundPrice(total);
}

async function fetchRouteDistanceKm(pickup, dropoff) {
  const token = process.env.MAPBOX_ACCESS_TOKEN;
  if (!token) {
    throw new Error('MAPBOX_ACCESS_TOKEN is not configured on the backend.');
  }

  const coords = `${pickup.lng},${pickup.lat};${dropoff.lng},${dropoff.lat}`;
  const url =
    `https://api.mapbox.com/directions/v5/mapbox/driving/${coords}` +
    `?alternatives=false&overview=false&access_token=${token}`;

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Mapbox Directions request failed (${response.status}).`);
  }

  const body = await response.json();
  const route = body.routes && body.routes[0];
  if (!route) {
    throw new Error('No driving route found between these points.');
  }

  return {
    distanceKm: route.distance / 1000,
    durationMin: route.duration / 60,
  };
}

module.exports = {
  RATE_TABLE,
  FEATURE_SURCHARGES,
  estimatePrice,
  fetchRouteDistanceKm,
};
