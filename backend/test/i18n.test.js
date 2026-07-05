require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const { t, localeFromRequest } = require('../src/i18n');

test('t returns the original English message when locale is en or unset', () => {
  assert.equal(t('Listing not found.', 'en'), 'Listing not found.');
  assert.equal(t('Listing not found.', undefined), 'Listing not found.');
});

test('t translates a known message into uz and ru', () => {
  assert.equal(t('Listing not found.', 'uz'), "E'lon topilmadi.");
  assert.equal(t('Listing not found.', 'ru'), 'Объявление не найдено.');
});

test('t falls back to the English message for an unknown string', () => {
  assert.equal(t('Some brand-new message.', 'uz'), 'Some brand-new message.');
});

test('localeFromRequest reads X-App-Locale and only accepts supported values', () => {
  assert.equal(localeFromRequest({ headers: { 'x-app-locale': 'ru' } }), 'ru');
  assert.equal(localeFromRequest({ headers: { 'x-app-locale': 'uz' } }), 'uz');
  assert.equal(localeFromRequest({ headers: { 'x-app-locale': 'fr' } }), 'en');
  assert.equal(localeFromRequest({ headers: {} }), 'en');
});
