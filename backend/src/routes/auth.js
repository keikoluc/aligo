const express = require('express');
const { rateLimit, ipKeyGenerator } = require('express-rate-limit');

const { createOtp, verifyOtp } = require('../services/otpService');
const { sendOtpEmail } = require('../services/mailer');
const { verifyGoogleIdToken } = require('../services/googleAuth');
const { issueToken } = require('../services/tokenService');
const userService = require('../services/userService');
const { t, localeFromRequest } = require('../i18n');

const router = express.Router();

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const otpSendLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: (req) => ({
    error: t('Too many code requests. Please try again later.', localeFromRequest(req)),
  }),
  keyGenerator: (req) => req.body?.email || ipKeyGenerator(req.ip),
});

const otpVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 15,
  message: (req) => ({
    error: t('Too many attempts. Please try again later.', localeFromRequest(req)),
  }),
  keyGenerator: (req) => req.body?.email || ipKeyGenerator(req.ip),
});

router.post('/otp/send', otpSendLimiter, async (req, res) => {
  const { email } = req.body || {};

  if (typeof email !== 'string' || !EMAIL_REGEX.test(email)) {
    return res
      .status(400)
      .json({ error: t('A valid email address is required.', req.locale) });
  }

  try {
    const code = await createOtp(email);
    await sendOtpEmail(email, code);
    return res.json({ message: 'Verification code sent.' });
  } catch (err) {
    console.error('Failed to send OTP email:', err.message);
    return res
      .status(502)
      .json({ error: t('Could not send verification email.', req.locale) });
  }
});

router.post('/otp/verify', otpVerifyLimiter, async (req, res) => {
  const { email, code, fullName } = req.body || {};

  if (typeof email !== 'string' || !EMAIL_REGEX.test(email)) {
    return res
      .status(400)
      .json({ error: t('A valid email address is required.', req.locale) });
  }
  if (typeof code !== 'string' || !/^\d{6}$/.test(code)) {
    return res
      .status(400)
      .json({ error: t('A valid 6-digit code is required.', req.locale) });
  }

  const result = await verifyOtp(email, code);
  if (!result.ok) {
    const messages = {
      not_found: 'No active code for this email. Request a new one.',
      expired: 'This code has expired. Request a new one.',
      invalid: 'Incorrect code.',
      too_many_attempts: 'Too many incorrect attempts. Request a new code.',
    };
    return res.status(400).json({
      error: t(messages[result.reason] || 'Verification failed.', req.locale),
    });
  }

  let user = await userService.findByEmail(email);
  if (!user) {
    user = await userService.createUser({
      email,
      fullName: typeof fullName === 'string' ? fullName : null,
      authProvider: 'email',
      isVerified: true,
    });
  } else {
    await userService.markVerified(email);
    user = await userService.findByEmail(email);
  }

  const token = issueToken(user);
  return res.json({ token, user: userService.toPublicUser(user) });
});

router.post('/google', async (req, res) => {
  const { idToken } = req.body || {};

  if (typeof idToken !== 'string' || idToken.length === 0) {
    return res.status(400).json({ error: t('idToken is required.', req.locale) });
  }

  try {
    const profile = await verifyGoogleIdToken(idToken);

    if (!profile.emailVerified) {
      return res
        .status(401)
        .json({ error: t('Google email is not verified.', req.locale) });
    }

    let user = await userService.findByEmail(profile.email);
    if (!user) {
      user = await userService.createUser({
        email: profile.email,
        fullName: profile.fullName,
        avatarUrl: profile.avatarUrl,
        authProvider: 'google',
        isVerified: profile.emailVerified,
      });
    }

    const token = issueToken(user);
    return res.json({ token, user: userService.toPublicUser(user) });
  } catch (err) {
    console.error('Google token verification failed:', err.message);
    return res
      .status(401)
      .json({ error: t('Invalid Google credential.', req.locale) });
  }
});

module.exports = router;
