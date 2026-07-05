const db = require('../db');
const userService = require('./userService');

const VALID_ROLES = ['driver', 'shipper'];
const VEHICLE_FIELDS = ['brandModel', 'color', 'plateNumber', 'sizeLabel'];

function validate({ role, fullName, phone, address, age, vehicle }) {
  if (!VALID_ROLES.includes(role)) {
    return 'Role must be "driver" or "shipper".';
  }
  if (typeof fullName !== 'string' || !fullName.trim()) {
    return 'Full name is required.';
  }
  if (typeof phone !== 'string' || !phone.trim()) {
    return 'Phone number is required.';
  }
  if (typeof address !== 'string' || !address.trim()) {
    return 'Address is required.';
  }
  if (!Number.isInteger(age) || age < 16 || age > 100) {
    return 'A valid age is required.';
  }
  if (role === 'driver') {
    if (!vehicle || typeof vehicle !== 'object') {
      return 'Vehicle information is required for drivers.';
    }
    for (const field of VEHICLE_FIELDS) {
      if (typeof vehicle[field] !== 'string' || !vehicle[field].trim()) {
        return `Vehicle ${field} is required.`;
      }
    }
  }
  return null;
}

async function saveVehicle(userId, vehicle) {
  const amenities = vehicle.amenities || {};
  const params = [
    vehicle.brandModel,
    vehicle.color,
    vehicle.plateNumber,
    vehicle.sizeLabel,
    amenities.refrigerated ? 1 : 0,
    amenities.sideRearTent ? 1 : 0,
    amenities.lift ? 1 : 0,
    amenities.tieDownStraps ? 1 : 0,
  ];

  const updateResult = await db.run(
    `UPDATE driver_vehicles
     SET brand_model = ?, color = ?, plate_number = ?, size_label = ?,
         has_refrigeration = ?, has_side_rear_tent = ?, has_lift = ?, has_tie_down_straps = ?
     WHERE user_id = ?`,
    [...params, userId]
  );

  if (updateResult.changes === 0) {
    await db.run(
      `INSERT INTO driver_vehicles
         (user_id, brand_model, color, plate_number, size_label,
          has_refrigeration, has_side_rear_tent, has_lift, has_tie_down_straps)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [userId, ...params]
    );
  }
}

async function saveProfile(userId, payload) {
  const error = validate(payload);
  if (error) {
    return { ok: false, error };
  }

  const { role, fullName, phone, address, age, vehicle, lat, lng } = payload;

  await db.run(
    'UPDATE users SET role = ?, full_name = ?, phone = ?, address = ?, age = ?, lat = ?, lng = ? WHERE id = ?',
    [
      role,
      fullName.trim(),
      phone.trim(),
      address.trim(),
      age,
      typeof lat === 'number' ? lat : null,
      typeof lng === 'number' ? lng : null,
      userId,
    ]
  );

  if (role === 'driver') {
    await saveVehicle(userId, vehicle);
  }

  const user = await userService.findById(userId);
  return { ok: true, user };
}

async function savePushToken(userId, fcmToken) {
  if (typeof fcmToken !== 'string' || !fcmToken.trim()) {
    return { ok: false, error: 'A valid FCM token is required.' };
  }
  await db.run('UPDATE users SET fcm_token = ? WHERE id = ?', [
    fcmToken.trim(),
    userId,
  ]);
  return { ok: true };
}

module.exports = { saveProfile, savePushToken };
