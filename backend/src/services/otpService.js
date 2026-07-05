const crypto = require('crypto');
const db = require('../db');

function hashCode(code) {
  return crypto.createHash('sha256').update(code).digest('hex');
}

function generateCode() {
  return crypto.randomInt(100000, 999999).toString();
}

async function createOtp(email) {
  const code = generateCode();
  const ttlMinutes = Number(process.env.OTP_TTL_MINUTES || 5);
  const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000).toISOString();

  await db.run(
    'INSERT INTO otp_codes (email, code_hash, expires_at) VALUES (?, ?, ?)',
    [email, hashCode(code), expiresAt]
  );

  return code;
}

const MAX_ATTEMPTS = 5;

async function verifyOtp(email, code) {
  const record = await db.get(
    `SELECT * FROM otp_codes
     WHERE email = ? AND consumed = 0
     ORDER BY id DESC LIMIT 1`,
    [email]
  );

  if (!record) {
    return { ok: false, reason: 'not_found' };
  }
  if (record.attempts >= MAX_ATTEMPTS) {
    return { ok: false, reason: 'too_many_attempts' };
  }
  if (new Date(record.expires_at).getTime() < Date.now()) {
    return { ok: false, reason: 'expired' };
  }

  await db.run('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = ?', [record.id]);

  if (record.code_hash !== hashCode(code)) {
    return { ok: false, reason: 'invalid' };
  }

  await db.run('UPDATE otp_codes SET consumed = 1 WHERE id = ?', [record.id]);
  return { ok: true };
}

module.exports = { createOtp, verifyOtp };
