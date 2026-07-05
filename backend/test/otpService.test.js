require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');

const otpService = require('../src/services/otpService');

test('createOtp generates a 6-digit code and verifyOtp accepts it', async () => {
  const code = await otpService.createOtp('user@test.com');
  assert.match(code, /^\d{6}$/);

  const result = await otpService.verifyOtp('user@test.com', code);
  assert.equal(result.ok, true);
});

test('verifyOtp rejects a wrong code', async () => {
  await otpService.createOtp('user2@test.com');
  const result = await otpService.verifyOtp('user2@test.com', '000000');
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'invalid');
});

test('verifyOtp rejects when no code was ever requested', async () => {
  const result = await otpService.verifyOtp('never-requested@test.com', '123456');
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'not_found');
});

test('verifyOtp locks out after too many wrong attempts', async () => {
  const code = await otpService.createOtp('user3@test.com');
  for (let i = 0; i < 5; i++) {
    await otpService.verifyOtp('user3@test.com', '000000');
  }
  const result = await otpService.verifyOtp('user3@test.com', code);
  assert.equal(result.ok, false);
  assert.equal(result.reason, 'too_many_attempts');
});
