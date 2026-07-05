// Required at the very top of every test file, before any app code —
// db/sqlite.js and tokenService read these at require-time, so the env
// must be set first. Each test file runs in its own process under
// `node --test`, so this in-memory DB is isolated per file.
process.env.SQLITE_PATH = ':memory:';
process.env.JWT_SECRET = 'test-secret-key-do-not-use-in-prod';
process.env.JWT_EXPIRES_IN = '10m';
process.env.OTP_TTL_MINUTES = '5';
process.env.ADMIN_PASSWORD = 'test-admin-password';
delete process.env.DATABASE_URL;
delete process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
delete process.env.MAPBOX_ACCESS_TOKEN;
delete process.env.TELEGRAM_BOT_TOKEN;
