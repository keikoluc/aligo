const path = require('path');
const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging: getFirebaseMessaging } = require('firebase-admin/messaging');

let messaging = null;

// Lazily initialized so the backend still runs fine (just skipping
// pushes) if FIREBASE_SERVICE_ACCOUNT_PATH isn't set yet — the service
// account key is a manual step in the Firebase console.
function getMessaging() {
  if (messaging !== null) return messaging;

  const keyPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (!keyPath) {
    messaging = false;
    return messaging;
  }

  const app = initializeApp({
    credential: cert(require(path.resolve(keyPath))),
  });
  messaging = getFirebaseMessaging(app);
  return messaging;
}

async function sendPush(token, { title, body, data = {} }) {
  if (!token) return;
  const m = getMessaging();
  if (!m) return;

  try {
    await m.send({
      token,
      notification: { title, body },
      data,
    });
  } catch (err) {
    console.error('Push notification failed:', err.message);
  }
}

module.exports = { sendPush };
