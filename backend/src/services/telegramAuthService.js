const crypto = require('crypto');

// Telegram Mini Apps hand us `initData`, a query string signed with an
// HMAC keyed off the bot token — verifying it here lets the Mini App
// trust the embedded Telegram user id without asking for a password.
// Algorithm: https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
const MAX_AUTH_AGE_SECONDS = 24 * 60 * 60;

function verifyInitData(initData) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token || typeof initData !== 'string' || !initData) {
    return { ok: false };
  }

  const params = new URLSearchParams(initData);
  const hash = params.get('hash');
  if (!hash) {
    return { ok: false };
  }
  params.delete('hash');

  const dataCheckString = [...params.entries()]
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([key, value]) => `${key}=${value}`)
    .join('\n');

  const secretKey = crypto.createHmac('sha256', 'WebAppData').update(token).digest();
  const computedHash = crypto
    .createHmac('sha256', secretKey)
    .update(dataCheckString)
    .digest('hex');

  if (computedHash !== hash) {
    return { ok: false };
  }

  const authDate = Number(params.get('auth_date'));
  if (!authDate || Date.now() / 1000 - authDate > MAX_AUTH_AGE_SECONDS) {
    return { ok: false };
  }

  let telegramUser;
  try {
    telegramUser = JSON.parse(params.get('user') || 'null');
  } catch {
    telegramUser = null;
  }
  if (!telegramUser || !telegramUser.id) {
    return { ok: false };
  }

  return { ok: true, telegramUserId: telegramUser.id, telegramUser };
}

module.exports = { verifyInitData };
