const crypto = require('crypto');

// Mirrors the HMAC algorithm in src/services/telegramAuthService.js so
// tests can produce initData a real Telegram client would also produce —
// see https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
function buildInitData({ user, authDate = Math.floor(Date.now() / 1000), token }) {
  const params = new URLSearchParams({
    auth_date: String(authDate),
    query_id: 'AAEmockquery',
    user: JSON.stringify(user),
  });

  const dataCheckString = [...params.entries()]
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([key, value]) => `${key}=${value}`)
    .join('\n');

  const secretKey = crypto.createHmac('sha256', 'WebAppData').update(token).digest();
  const hash = crypto.createHmac('sha256', secretKey).update(dataCheckString).digest('hex');

  params.set('hash', hash);
  return params.toString();
}

module.exports = { buildInitData };
