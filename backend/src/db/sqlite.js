const path = require('path');
const Database = require('better-sqlite3');

// Tests set SQLITE_PATH=:memory: so they get a fresh, isolated database
// instead of touching the real dev data in aligo.sqlite.
const dbPath =
  process.env.SQLITE_PATH || path.join(__dirname, '..', '..', 'aligo.sqlite');
const db = new Database(dbPath);

// WAL mode isn't supported for in-memory databases (used in tests).
if (dbPath !== ':memory:') {
  db.pragma('journal_mode = WAL');
}

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    auth_provider TEXT NOT NULL,
    is_verified INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS otp_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL,
    code_hash TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    consumed INTEGER NOT NULL DEFAULT 0,
    attempts INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  );

  CREATE INDEX IF NOT EXISTS idx_otp_email ON otp_codes(email);

  CREATE TABLE IF NOT EXISTS driver_vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id),
    brand_model TEXT,
    color TEXT,
    plate_number TEXT,
    size_label TEXT,
    has_refrigeration INTEGER NOT NULL DEFAULT 0,
    has_side_rear_tent INTEGER NOT NULL DEFAULT 0,
    has_lift INTEGER NOT NULL DEFAULT 0,
    has_tie_down_straps INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS cargo_listings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipper_id INTEGER NOT NULL REFERENCES users(id),
    cargo_type TEXT NOT NULL,
    description TEXT,
    pickup_label TEXT NOT NULL,
    pickup_lat REAL NOT NULL,
    pickup_lng REAL NOT NULL,
    dropoff_label TEXT NOT NULL,
    dropoff_lat REAL NOT NULL,
    dropoff_lng REAL NOT NULL,
    price REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    driver_id INTEGER REFERENCES users(id),
    driver_lat REAL,
    driver_lng REAL,
    driver_location_updated_at TEXT,
    requires_refrigeration INTEGER NOT NULL DEFAULT 0,
    requires_side_rear_tent INTEGER NOT NULL DEFAULT 0,
    requires_lift INTEGER NOT NULL DEFAULT 0,
    requires_tie_down_straps INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  );

  CREATE INDEX IF NOT EXISTS idx_cargo_status ON cargo_listings(status);

  CREATE TABLE IF NOT EXISTS ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    listing_id INTEGER NOT NULL REFERENCES cargo_listings(id),
    rater_id INTEGER NOT NULL REFERENCES users(id),
    ratee_id INTEGER NOT NULL REFERENCES users(id),
    stars INTEGER NOT NULL,
    comment TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(listing_id, rater_id)
  );

  CREATE INDEX IF NOT EXISTS idx_ratings_ratee ON ratings(ratee_id);
`);

// CREATE TABLE IF NOT EXISTS doesn't retroactively add columns to a users
// table that already existed on disk, so migrate any that are missing.
const existingUserColumns = new Set(
  db.prepare('PRAGMA table_info(users)').all().map((c) => c.name)
);
for (const [name, type] of Object.entries({
  role: 'TEXT',
  phone: 'TEXT',
  address: 'TEXT',
  age: 'INTEGER',
  lat: 'REAL',
  lng: 'REAL',
  fcm_token: 'TEXT',
  telegram_chat_id: 'TEXT',
  telegram_link_code: 'TEXT',
  telegram_link_code_expires_at: 'TEXT',
})) {
  if (!existingUserColumns.has(name)) {
    db.exec(`ALTER TABLE users ADD COLUMN ${name} ${type}`);
  }
}

const existingCargoColumns = new Set(
  db.prepare('PRAGMA table_info(cargo_listings)').all().map((c) => c.name)
);
for (const [name, type] of Object.entries({
  driver_lat: 'REAL',
  driver_lng: 'REAL',
  driver_location_updated_at: 'TEXT',
  requires_refrigeration: 'INTEGER NOT NULL DEFAULT 0',
  requires_side_rear_tent: 'INTEGER NOT NULL DEFAULT 0',
  requires_lift: 'INTEGER NOT NULL DEFAULT 0',
  requires_tie_down_straps: 'INTEGER NOT NULL DEFAULT 0',
})) {
  if (!existingCargoColumns.has(name)) {
    db.exec(`ALTER TABLE cargo_listings ADD COLUMN ${name} ${type}`);
  }
}

async function get(sql, params = []) {
  return db.prepare(sql).get(...params);
}

async function all(sql, params = []) {
  return db.prepare(sql).all(...params);
}

async function run(sql, params = []) {
  const info = db.prepare(sql).run(...params);
  return { lastInsertRowid: info.lastInsertRowid, changes: info.changes };
}

module.exports = { get, all, run };
