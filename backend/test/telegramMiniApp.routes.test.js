require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');

process.env.TELEGRAM_BOT_TOKEN = 'test-bot-token-123';

const app = require('../src/app');
const userService = require('../src/services/userService');
const telegramLinkService = require('../src/services/telegramLinkService');
const { buildInitData } = require('./helpers/telegramInitData');

let userCounter = 0;
async function makeUser() {
  userCounter += 1;
  return userService.createUser({
    email: `miniapp${userCounter}@test.com`,
    authProvider: 'email',
    isVerified: true,
  });
}

function initDataFor(telegramUserId) {
  return buildInitData({
    user: { id: telegramUserId, first_name: 'Aziz' },
    token: process.env.TELEGRAM_BOT_TOKEN,
  });
}

test('POST /api/telegram-miniapp/auth rejects an unsigned/invalid initData', async () => {
  const res = await request(app)
    .post('/api/telegram-miniapp/auth')
    .send({ initData: 'not-real-init-data' });
  assert.equal(res.status, 401);
});

test('POST /api/telegram-miniapp/auth reports linked:false for a chat with no linked account', async () => {
  const res = await request(app)
    .post('/api/telegram-miniapp/auth')
    .send({ initData: initDataFor(123456) });
  assert.equal(res.status, 200);
  assert.equal(res.body.linked, false);
});

test('POST /api/telegram-miniapp/auth issues a token for an already-linked chat', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);
  await telegramLinkService.consumeLinkCode(code, 777777);

  const res = await request(app)
    .post('/api/telegram-miniapp/auth')
    .send({ initData: initDataFor(777777) });

  assert.equal(res.status, 200);
  assert.equal(res.body.linked, true);
  assert.ok(res.body.token);
  assert.equal(res.body.user.id, user.id);
});

test('POST /api/telegram-miniapp/link links the account with a valid code', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);

  const res = await request(app)
    .post('/api/telegram-miniapp/link')
    .send({ initData: initDataFor(888888), code });

  assert.equal(res.status, 200);
  assert.equal(res.body.linked, true);
  assert.ok(res.body.token);
  assert.equal(res.body.user.id, user.id);
});

test('POST /api/telegram-miniapp/link rejects an invalid code', async () => {
  const res = await request(app)
    .post('/api/telegram-miniapp/link')
    .send({ initData: initDataFor(999999), code: 'BADCOD' });
  assert.equal(res.status, 400);
});
