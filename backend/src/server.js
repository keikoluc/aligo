require('dotenv').config();

const http = require('http');
const app = require('./app');
const { initRealtime } = require('./realtime');
const telegramClient = require('./services/telegramClient');
const { registerHandlers } = require('./services/telegramBotHandlers');

const server = http.createServer(app);
initRealtime(server);

// No-ops if TELEGRAM_BOT_TOKEN isn't set (see telegramClient.js) — the
// token is a manual step via @BotFather, same as Firebase's service
// account key.
registerHandlers();
telegramClient.start();

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`Aligo backend listening on port ${PORT}`);
});
