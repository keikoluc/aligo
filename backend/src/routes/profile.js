const express = require('express');

const { requireAuth } = require('../middleware/auth');
const profileService = require('../services/profileService');
const userService = require('../services/userService');
const telegramLinkService = require('../services/telegramLinkService');
const telegramClient = require('../services/telegramClient');
const { t } = require('../i18n');

const router = express.Router();

router.put('/', requireAuth, async (req, res) => {
  const { role, fullName, phone, address, age, vehicle, lat, lng } =
    req.body || {};

  const result = await profileService.saveProfile(req.userId, {
    role,
    fullName,
    phone,
    address,
    age,
    vehicle,
    lat,
    lng,
  });

  if (!result.ok) {
    return res.status(400).json({ error: t(result.error, req.locale) });
  }

  return res.json({ user: userService.toPublicUser(result.user) });
});

router.put('/push-token', requireAuth, async (req, res) => {
  const { fcmToken } = req.body || {};
  const result = await profileService.savePushToken(req.userId, fcmToken);
  if (!result.ok) {
    return res.status(400).json({ error: t(result.error, req.locale) });
  }
  return res.json({ ok: true });
});

router.get('/telegram/status', requireAuth, async (req, res) => {
  const user = await userService.findById(req.userId);
  return res.json({ linked: !!user.telegram_chat_id });
});

router.post('/telegram/link-code', requireAuth, async (req, res) => {
  const { code, ttlMinutes } = await telegramLinkService.createLinkCode(req.userId);
  const botUsername = await telegramClient.getBotUsername();
  return res.json({
    code,
    ttlMinutes,
    botUsername,
    deepLink: botUsername ? `https://t.me/${botUsername}?start=link_${code}` : null,
  });
});

router.post('/telegram/unlink', requireAuth, async (req, res) => {
  await telegramLinkService.unlink(req.userId);
  return res.json({ ok: true });
});

module.exports = router;
