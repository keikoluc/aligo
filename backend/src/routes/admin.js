const express = require('express');
const jwt = require('jsonwebtoken');

const { requireAdmin } = require('../middleware/adminAuth');
const adminService = require('../services/adminService');
const { t } = require('../i18n');

const router = express.Router();

router.post('/login', (req, res) => {
  if (!process.env.ADMIN_PASSWORD) {
    return res
      .status(503)
      .json({ error: t('Admin login is not configured.', req.locale) });
  }

  const { password } = req.body || {};
  if (typeof password !== 'string' || password !== process.env.ADMIN_PASSWORD) {
    return res.status(401).json({ error: t('Incorrect password.', req.locale) });
  }

  const token = jwt.sign({ role: 'admin' }, process.env.JWT_SECRET, {
    expiresIn: '12h',
  });
  return res.json({ token });
});

router.get('/stats', requireAdmin, async (req, res) => {
  return res.json(await adminService.getStats());
});

router.get('/users', requireAdmin, async (req, res) => {
  const users = await adminService.listUsers(req.query.search);
  return res.json({ users });
});

router.get('/listings', requireAdmin, async (req, res) => {
  const listings = await adminService.listListings(req.query.status);
  return res.json({ listings });
});

router.post('/listings/:id/cancel', requireAdmin, async (req, res) => {
  const listingId = Number(req.params.id);
  if (!Number.isInteger(listingId)) {
    return res.status(400).json({ error: t('Invalid listing id.', req.locale) });
  }

  const result = await adminService.forceCancelListing(listingId);
  if (!result.ok) {
    return res.status(404).json({
      error: t('Listing not found or already completed.', req.locale),
    });
  }
  return res.json({ ok: true });
});

module.exports = router;
