require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const { buildInitData } = require('./helpers/telegramInitData');

process.env.TELEGRAM_BOT_TOKEN = 'test-bot-token-123';
const telegramAuthService = require('../src/services/telegramAuthService');

test('verifyInitData accepts correctly signed data', () => {
  const initData = buildInitData({
    user: { id: 555, first_name: 'Aziz' },
    token: process.env.TELEGRAM_BOT_TOKEN,
  });
  const result = telegramAuthService.verifyInitData(initData);
  assert.equal(result.ok, true);
  assert.equal(result.telegramUserId, 555);
});

test('verifyInitData rejects a tampered hash', () => {
  const initData = buildInitData({
    user: { id: 555, first_name: 'Aziz' },
    token: process.env.TELEGRAM_BOT_TOKEN,
  });
  const tampered = initData.replace(
    /hash=[0-9a-f]+/,
    'hash=0000000000000000000000000000000000000000000000000000000000000000'
  );
  const result = telegramAuthService.verifyInitData(tampered);
  assert.equal(result.ok, false);
});

test('verifyInitData rejects data signed with a different bot token', () => {
  const initData = buildInitData({ user: { id: 555 }, token: 'a-different-token' });
  const result = telegramAuthService.verifyInitData(initData);
  assert.equal(result.ok, false);
});

test('verifyInitData rejects stale auth_date', () => {
  const oldDate = Math.floor(Date.now() / 1000) - 25 * 60 * 60;
  const initData = buildInitData({
    user: { id: 555 },
    authDate: oldDate,
    token: process.env.TELEGRAM_BOT_TOKEN,
  });
  const result = telegramAuthService.verifyInitData(initData);
  assert.equal(result.ok, false);
});

test('verifyInitData rejects when TELEGRAM_BOT_TOKEN is unset', () => {
  const initData = buildInitData({
    user: { id: 555 },
    token: process.env.TELEGRAM_BOT_TOKEN,
  });
  const original = process.env.TELEGRAM_BOT_TOKEN;
  delete process.env.TELEGRAM_BOT_TOKEN;
  const result = telegramAuthService.verifyInitData(initData);
  process.env.TELEGRAM_BOT_TOKEN = original;
  assert.equal(result.ok, false);
});

test('verifyInitData rejects an empty string', () => {
  const result = telegramAuthService.verifyInitData('');
  assert.equal(result.ok, false);
});
