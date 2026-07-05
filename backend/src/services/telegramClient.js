const { Telegraf } = require('telegraf');

let bot = null; // null = not yet checked, false = no token configured, else Telegraf instance
let botUsername = null;

// Lazily initialized so the backend still runs fine (just skipping the
// bot, same as pushService does for Firebase) if TELEGRAM_BOT_TOKEN isn't
// set — the token is a manual step via @BotFather.
function getBot() {
  if (bot !== null) return bot;
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token) {
    bot = false;
    return bot;
  }
  bot = new Telegraf(token);
  return bot;
}

// Points the bot's persistent menu button (bottom-left, next to the
// text field) at the Mini App. Telegram requires this URL to be public
// HTTPS, so this is a no-op in local/dev setups without one configured
// — the bot still works fine via its chat commands either way.
function setupMenuButton() {
  const b = getBot();
  const url = process.env.TELEGRAM_MINIAPP_URL;
  if (!b || !url) return;
  b.telegram
    .setChatMenuButton({ menuButton: { type: 'web_app', text: 'Aligo', web_app: { url } } })
    .catch((err) => {
      console.error('Telegram setChatMenuButton failed:', err.message);
    });
}

// Starts long-polling. Safe to call even without a token (no-op then).
// Call once, at process bootstrap — never in tests/request handlers.
function start() {
  const b = getBot();
  if (!b) return;
  b.telegram.getMe().then((me) => {
    botUsername = me.username;
  }).catch((err) => {
    console.error('Telegram bot getMe failed:', err.message);
  });
  setupMenuButton();
  b.launch().catch((err) => {
    console.error('Telegram bot failed to start:', err.message);
  });
  process.once('SIGINT', () => b.stop('SIGINT'));
  process.once('SIGTERM', () => b.stop('SIGTERM'));
}

async function getBotUsername() {
  const b = getBot();
  if (!b) return null;
  if (botUsername) return botUsername;
  const me = await b.telegram.getMe();
  botUsername = me.username;
  return botUsername;
}

async function sendMessage(chatId, text, extra = {}) {
  if (!chatId) return;
  const b = getBot();
  if (!b) return;
  try {
    await b.telegram.sendMessage(chatId, text, extra);
  } catch (err) {
    console.error('Telegram sendMessage failed:', err.message);
  }
}

function getMiniAppUrl() {
  return process.env.TELEGRAM_MINIAPP_URL || null;
}

module.exports = { getBot, start, getBotUsername, sendMessage, getMiniAppUrl };
