const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const cargoRoutes = require('./routes/cargo');
const adminRoutes = require('./routes/admin');
const telegramMiniAppRoutes = require('./routes/telegramMiniApp');
const { localeFromRequest } = require('./i18n');

const app = express();

app.use(cors());
app.use(express.json());

// The Flutter app sends its active language in X-App-Locale (see
// core/network/*_api.dart); routes use req.locale to translate error
// messages via src/i18n.js's t().
app.use((req, res, next) => {
  req.locale = localeFromRequest(req);
  next();
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/health/smtp-diag', async (req, res) => {
  const net = require('net');
  const dns = require('dns').promises;
  const results = {};
  try {
    results.resolve4 = await dns.resolve4('smtp.gmail.com').catch(e => `ERR: ${e.message}`);
  } catch (e) {
    results.resolve4 = `ERR: ${e.message}`;
  }
  try {
    results.resolve6 = await dns.resolve6('smtp.gmail.com').catch(e => `ERR: ${e.message}`);
  } catch (e) {
    results.resolve6 = `ERR: ${e.message}`;
  }

  function tryConnect(family, host, port) {
    return new Promise(resolve => {
      const start = Date.now();
      const socket = net.createConnection({ host, port, family, timeout: 8000 });
      socket.on('connect', () => {
        resolve({ ok: true, ms: Date.now() - start });
        socket.destroy();
      });
      socket.on('timeout', () => {
        resolve({ ok: false, error: 'timeout', ms: Date.now() - start });
        socket.destroy();
      });
      socket.on('error', err => {
        resolve({ ok: false, error: err.message, ms: Date.now() - start });
      });
    });
  }

  results.ipv4_465 = await tryConnect(4, 'smtp.gmail.com', 465);
  results.ipv4_587 = await tryConnect(4, 'smtp.gmail.com', 587);
  results.ipv6_465 = await tryConnect(6, 'smtp.gmail.com', 465);

  res.json(results);
});

app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/cargo', cargoRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/telegram-miniapp', telegramMiniAppRoutes);
app.use('/admin', express.static(`${__dirname}/../admin-panel`));
app.use('/miniapp', express.static(`${__dirname}/../miniapp`));

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error.' });
});

module.exports = app;
