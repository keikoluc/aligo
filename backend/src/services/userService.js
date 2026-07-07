const db = require('../db');

async function findByEmail(email) {
  return db.get('SELECT * FROM users WHERE email = ?', [email]);
}

async function createUser({ email, fullName, avatarUrl, authProvider, isVerified }) {
  const info = await db.run(
    `INSERT INTO users (email, full_name, avatar_url, auth_provider, is_verified)
     VALUES (?, ?, ?, ?, ?)`,
    [email, fullName || null, avatarUrl || null, authProvider, isVerified ? 1 : 0]
  );

  return findById(info.lastInsertRowid);
}

async function findById(id) {
  return db.get('SELECT * FROM users WHERE id = ?', [id]);
}

async function markVerified(email) {
  await db.run('UPDATE users SET is_verified = 1 WHERE email = ?', [email]);
}

function toPublicUser(user) {
  return {
    id: user.id,
    email: user.email,
    fullName: user.full_name,
    avatarUrl: user.avatar_url,
    authProvider: user.auth_provider,
    isVerified: !!user.is_verified,
    role: user.role,
    phoneNumber: user.phone,
    address: user.address,
    age: user.age,
    lat: user.lat,
    lng: user.lng,
    telegramLanguage: user.telegram_language,
  };
}

module.exports = { findByEmail, createUser, findById, markVerified, toPublicUser };
