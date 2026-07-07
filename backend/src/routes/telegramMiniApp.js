const express = require('express');

const telegramAuthService = require('../services/telegramAuthService');
const telegramLinkService = require('../services/telegramLinkService');
const userService = require('../services/userService');
const { issueToken } = require('../services/tokenService');
const { requireAuth } = require('../middleware/auth');
const { t } = require('../i18n');

const router = express.Router();

// The Mini App re-sends Telegram's `initData` on every launch instead of
// storing its own session — same trust boundary as a Telegram bot chat,
// just over HTTP instead of long-polling (see telegramAuthService.js).
router.post('/auth', async (req, res) => {
  const { initData } = req.body || {};
  const verified = telegramAuthService.verifyInitData(initData);
  if (!verified.ok) {
    return res.status(401).json({ error: t('Invalid Telegram session.', req.locale) });
  }

  const user = await telegramLinkService.findByChatId(verified.telegramUserId);
  if (!user) {
    return res.json({ linked: false });
  }
  return res.json({
    linked: true,
    token: issueToken(user),
    user: userService.toPublicUser(user),
  });
});

// Lets a Telegram user link their Aligo account without leaving the
// Mini App — same 6-character code the app/bot flow already issues
// (see telegramLinkService.createLinkCode), just consumed here instead
// of via a /link chat command.
router.post('/link', async (req, res) => {
  const { initData, code } = req.body || {};
  const verified = telegramAuthService.verifyInitData(initData);
  if (!verified.ok) {
    return res.status(401).json({ error: t('Invalid Telegram session.', req.locale) });
  }

  const result = await telegramLinkService.consumeLinkCode(code, verified.telegramUserId);
  if (!result.ok) {
    return res
      .status(400)
      .json({ error: t('This code is invalid or has expired.', req.locale) });
  }
  return res.json({
    linked: true,
    token: issueToken(result.user),
    user: userService.toPublicUser(result.user),
  });
});

// Shared by the Mini App's settings screen and the bot's /language
// command (telegramLinkService.setLanguage), so switching it in either
// place keeps both in sync for the same linked account.
router.put('/language', requireAuth, async (req, res) => {
  const { language } = req.body || {};
  if (!telegramLinkService.SUPPORTED_LANGUAGES.has(language)) {
    return res.status(400).json({ error: t('Unsupported language.', req.locale) });
  }
  await telegramLinkService.setLanguage(req.userId, language);
  return res.json({ ok: true });
});

// Lets the Mini App's settings screen unlink the account without needing
// to leave and send /unlink to the bot chat.
router.post('/unlink', requireAuth, async (req, res) => {
  await telegramLinkService.unlink(req.userId);
  return res.json({ ok: true });
});

module.exports = router;
