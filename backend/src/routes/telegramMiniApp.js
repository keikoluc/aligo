const express = require('express');

const telegramAuthService = require('../services/telegramAuthService');
const telegramLinkService = require('../services/telegramLinkService');
const userService = require('../services/userService');
const { issueToken } = require('../services/tokenService');
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

module.exports = router;
