const crypto = require('crypto');
const db = require('../db');

const CODE_TTL_MINUTES = 10;

function generateCode() {
  // Short, easy to type into the bot by hand: 6 uppercase base32-ish chars.
  return crypto.randomBytes(4).toString('hex').slice(0, 6).toUpperCase();
}

// A user taps "Connect Telegram" in the app; we hand them a short-lived
// code (or a t.me deep link carrying the same code) to send the bot.
async function createLinkCode(userId) {
  const code = generateCode();
  const expiresAt = new Date(Date.now() + CODE_TTL_MINUTES * 60 * 1000).toISOString();
  await db.run(
    'UPDATE users SET telegram_link_code = ?, telegram_link_code_expires_at = ? WHERE id = ?',
    [code, expiresAt, userId]
  );
  return { code, ttlMinutes: CODE_TTL_MINUTES };
}

// The bot calls this once the user sends /start link_<code> or /link <code>.
// A chat can only ever be linked to one account, so re-linking clears any
// previous owner of that chat id first.
async function consumeLinkCode(code, chatId) {
  const trimmed = String(code || '').trim().toUpperCase();
  if (!trimmed) {
    return { ok: false, reason: 'invalid' };
  }

  const user = await db.get(
    'SELECT * FROM users WHERE telegram_link_code = ?',
    [trimmed]
  );
  if (!user || new Date(user.telegram_link_code_expires_at).getTime() < Date.now()) {
    return { ok: false, reason: 'invalid' };
  }

  await db.run(
    'UPDATE users SET telegram_chat_id = NULL WHERE telegram_chat_id = ? AND id != ?',
    [String(chatId), user.id]
  );
  await db.run(
    `UPDATE users
     SET telegram_chat_id = ?, telegram_link_code = NULL, telegram_link_code_expires_at = NULL
     WHERE id = ?`,
    [String(chatId), user.id]
  );

  return { ok: true, user: await db.get('SELECT * FROM users WHERE id = ?', [user.id]) };
}

async function unlink(userId) {
  await db.run('UPDATE users SET telegram_chat_id = NULL WHERE id = ?', [userId]);
}

async function findByChatId(chatId) {
  return db.get('SELECT * FROM users WHERE telegram_chat_id = ?', [String(chatId)]);
}

const SUPPORTED_LANGUAGES = new Set(['uz', 'ru', 'en']);

// Shared by the bot's /language command and the Mini App's settings
// screen, so switching it in either place keeps both in sync.
async function setLanguage(userId, language) {
  if (!SUPPORTED_LANGUAGES.has(language)) {
    throw new Error(`Unsupported language: ${language}`);
  }
  await db.run('UPDATE users SET telegram_language = ? WHERE id = ?', [language, userId]);
}

module.exports = {
  createLinkCode,
  consumeLinkCode,
  unlink,
  findByChatId,
  setLanguage,
  SUPPORTED_LANGUAGES,
};
