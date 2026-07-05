require('./helpers/testEnv');
const test = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');

const app = require('../src/app');
const db = require('../src/db');
const otpService = require('../src/services/otpService');
const userService = require('../src/services/userService');
const { issueToken } = require('../src/services/tokenService');

async function makeAuthedUser(role) {
  const user = await userService.createUser({
    email: `${role}-route-${Math.random().toString(36).slice(2)}@test.com`,
    authProvider: 'email',
    isVerified: true,
  });
  await db.run('UPDATE users SET role = ? WHERE id = ?', [role, user.id]);
  const fresh = await userService.findById(user.id);
  return { user: fresh, token: issueToken(fresh) };
}

test('GET /health responds ok', async () => {
  const res = await request(app).get('/health');
  assert.equal(res.status, 200);
  assert.equal(res.body.status, 'ok');
});

test('POST /api/auth/otp/verify creates a new user on first verification', async () => {
  const email = 'newuser-route@test.com';
  const code = await otpService.createOtp(email);

  const res = await request(app)
    .post('/api/auth/otp/verify')
    .send({ email, code, fullName: 'New User' });

  assert.equal(res.status, 200);
  assert.equal(res.body.user.email, email);
  assert.ok(res.body.token);
});

test('POST /api/auth/otp/verify rejects an incorrect code', async () => {
  const email = 'baduser-route@test.com';
  await otpService.createOtp(email);

  const res = await request(app)
    .post('/api/auth/otp/verify')
    .send({ email, code: '000000' });

  assert.equal(res.status, 400);
});

test('cargo routes require authentication', async () => {
  const res = await request(app).get('/api/cargo/nearby');
  assert.equal(res.status, 401);
});

test('GET /api/cargo/nearby is forbidden for a shipper account', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .get('/api/cargo/nearby')
    .set('Authorization', `Bearer ${token}`);
  assert.equal(res.status, 403);
});

test('error messages are translated when X-App-Locale is set', async () => {
  const { token } = await makeAuthedUser('shipper');

  const enRes = await request(app)
    .get('/api/cargo/nearby')
    .set('Authorization', `Bearer ${token}`)
    .set('X-App-Locale', 'en');
  assert.equal(enRes.body.error, 'Only drivers can perform this action.');

  const uzRes = await request(app)
    .get('/api/cargo/nearby')
    .set('Authorization', `Bearer ${token}`)
    .set('X-App-Locale', 'uz');
  assert.equal(uzRes.body.error, 'Bu amalni faqat haydovchilar bajara oladi.');

  const ruRes = await request(app)
    .get('/api/cargo/nearby')
    .set('Authorization', `Bearer ${token}`)
    .set('X-App-Locale', 'ru');
  assert.equal(
    ruRes.body.error,
    'Это действие могут выполнять только водители.'
  );
});

test('POST /api/cargo creates a listing for an authenticated shipper', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .post('/api/cargo')
    .set('Authorization', `Bearer ${token}`)
    .send({
      cargoType: 'general',
      pickup: { label: 'A', lat: 41.3, lng: 69.24 },
      dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
      price: 50000,
    });

  assert.equal(res.status, 201);
  assert.equal(res.body.listing.status, 'open');
});

test('PUT /api/cargo/:id updates a listing owned by the requester', async () => {
  const { token } = await makeAuthedUser('shipper');
  const createRes = await request(app)
    .post('/api/cargo')
    .set('Authorization', `Bearer ${token}`)
    .send({
      cargoType: 'general',
      pickup: { label: 'A', lat: 41.3, lng: 69.24 },
      dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
      price: 50000,
    });

  const res = await request(app)
    .put(`/api/cargo/${createRes.body.listing.id}`)
    .set('Authorization', `Bearer ${token}`)
    .send({
      cargoType: 'furniture',
      pickup: { label: 'A', lat: 41.3, lng: 69.24 },
      dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
      price: 75000,
    });

  assert.equal(res.status, 200);
  assert.equal(res.body.listing.cargoType, 'furniture');
  assert.equal(res.body.listing.price, 75000);
});

test('PUT /api/cargo/:id is rejected for a listing owned by someone else', async () => {
  const owner = await makeAuthedUser('shipper');
  const intruder = await makeAuthedUser('shipper');
  const createRes = await request(app)
    .post('/api/cargo')
    .set('Authorization', `Bearer ${owner.token}`)
    .send({
      cargoType: 'general',
      pickup: { label: 'A', lat: 41.3, lng: 69.24 },
      dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
      price: 50000,
    });

  const res = await request(app)
    .put(`/api/cargo/${createRes.body.listing.id}`)
    .set('Authorization', `Bearer ${intruder.token}`)
    .send({
      cargoType: 'furniture',
      pickup: { label: 'A', lat: 41.3, lng: 69.24 },
      dropoff: { label: 'B', lat: 41.33, lng: 69.28 },
      price: 99999,
    });

  assert.equal(res.status, 409);
});

test('GET /api/profile/telegram/status reports unlinked for a fresh user', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .get('/api/profile/telegram/status')
    .set('Authorization', `Bearer ${token}`);
  assert.equal(res.status, 200);
  assert.equal(res.body.linked, false);
});

test('POST /api/profile/telegram/link-code issues a 6-character code', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .post('/api/profile/telegram/link-code')
    .set('Authorization', `Bearer ${token}`);
  assert.equal(res.status, 200);
  assert.equal(res.body.code.length, 6);
  assert.equal(res.body.ttlMinutes, 10);
  // No TELEGRAM_BOT_TOKEN in the test env, so the bot never starts and
  // there's no username to build a deep link from.
  assert.equal(res.body.botUsername, null);
  assert.equal(res.body.deepLink, null);
});

test('POST /api/profile/telegram/unlink is a no-op for an unlinked user', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .post('/api/profile/telegram/unlink')
    .set('Authorization', `Bearer ${token}`);
  assert.equal(res.status, 200);
  assert.equal(res.body.ok, true);
});

test('admin routes require login', async () => {
  const res = await request(app).get('/api/admin/stats');
  assert.equal(res.status, 401);
});

test('admin login with the wrong password is rejected', async () => {
  const res = await request(app)
    .post('/api/admin/login')
    .send({ password: 'wrong-password' });
  assert.equal(res.status, 401);
});

test('admin login with the right password unlocks the stats endpoint', async () => {
  const loginRes = await request(app)
    .post('/api/admin/login')
    .send({ password: 'test-admin-password' });
  assert.equal(loginRes.status, 200);
  assert.ok(loginRes.body.token);

  const statsRes = await request(app)
    .get('/api/admin/stats')
    .set('Authorization', `Bearer ${loginRes.body.token}`);
  assert.equal(statsRes.status, 200);
  assert.ok('usersByRole' in statsRes.body);
  assert.ok('listingsByStatus' in statsRes.body);
});

test('a regular user token cannot access admin routes', async () => {
  const { token } = await makeAuthedUser('shipper');
  const res = await request(app)
    .get('/api/admin/stats')
    .set('Authorization', `Bearer ${token}`);
  assert.equal(res.status, 401);
});
