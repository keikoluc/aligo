require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const db = require('../src/db');
const userService = require('../src/services/userService');
const telegramLinkService = require('../src/services/telegramLinkService');

let userCounter = 0;
async function makeUser() {
  userCounter += 1;
  return userService.createUser({
    email: `tguser${userCounter}@test.com`,
    authProvider: 'email',
    isVerified: true,
  });
}

test('createLinkCode stores a fresh code on the user row', async () => {
  const user = await makeUser();
  const { code, ttlMinutes } = await telegramLinkService.createLinkCode(user.id);

  assert.equal(code.length, 6);
  assert.equal(ttlMinutes, 10);
  const fresh = await userService.findById(user.id);
  assert.equal(fresh.telegram_link_code, code);
  assert.ok(fresh.telegram_link_code_expires_at);
});

test('consumeLinkCode links the chat id to the matching user and clears the code', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);

  const result = await telegramLinkService.consumeLinkCode(code, 555111);

  assert.equal(result.ok, true);
  assert.equal(result.user.id, user.id);
  assert.equal(result.user.telegram_chat_id, '555111');
  assert.equal(result.user.telegram_link_code, null);
});

test('consumeLinkCode is case-insensitive', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);

  const result = await telegramLinkService.consumeLinkCode(code.toLowerCase(), 42);

  assert.equal(result.ok, true);
  assert.equal(result.user.id, user.id);
});

test('consumeLinkCode rejects an unknown code', async () => {
  const result = await telegramLinkService.consumeLinkCode('NOPE99', 123);
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'invalid');
});

test('consumeLinkCode rejects an expired code', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);
  await db.run('UPDATE users SET telegram_link_code_expires_at = ? WHERE id = ?', [
    new Date(Date.now() - 1000).toISOString(),
    user.id,
  ]);

  const result = await telegramLinkService.consumeLinkCode(code, 123);
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'invalid');
});

test('consumeLinkCode moves a chat id away from its previous owner when re-linked', async () => {
  const firstUser = await makeUser();
  const secondUser = await makeUser();
  const chatId = 999888;

  const firstCode = await telegramLinkService.createLinkCode(firstUser.id);
  await telegramLinkService.consumeLinkCode(firstCode.code, chatId);

  const secondCode = await telegramLinkService.createLinkCode(secondUser.id);
  await telegramLinkService.consumeLinkCode(secondCode.code, chatId);

  const staleFirstUser = await userService.findById(firstUser.id);
  const freshSecondUser = await userService.findById(secondUser.id);
  assert.equal(staleFirstUser.telegram_chat_id, null);
  assert.equal(freshSecondUser.telegram_chat_id, String(chatId));
});

test('unlink clears the chat id', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);
  await telegramLinkService.consumeLinkCode(code, 777);

  await telegramLinkService.unlink(user.id);

  const fresh = await userService.findById(user.id);
  assert.equal(fresh.telegram_chat_id, null);
});

test('findByChatId looks up the linked user', async () => {
  const user = await makeUser();
  const { code } = await telegramLinkService.createLinkCode(user.id);
  await telegramLinkService.consumeLinkCode(code, 321);

  const found = await telegramLinkService.findByChatId(321);
  assert.equal(found.id, user.id);

  const notFound = await telegramLinkService.findByChatId(11111);
  assert.equal(notFound, undefined);
});
