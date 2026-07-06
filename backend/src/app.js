const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const cargoRoutes = require('./routes/cargo');
const adminRoutes = require('./routes/admin');
const telegramMiniAppRoutes = require('./routes/telegramMiniApp');
const { localeFromRequest } = require('./i18n');
const appVersion = require('./config/appVersion');

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

app.get('/api/app/version', (req, res) => {
  res.json(appVersion);
});

app.get('/health/resend-diag', (req, res) => {
  const key = process.env.RESEND_API_KEY || '';
  res.json({
    length: key.length,
    prefix: key.slice(0, 6),
    suffix: key.slice(-4),
    hasWhitespace: /\s/.test(key),
  });
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
