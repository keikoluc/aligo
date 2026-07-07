const { Pool } = require('pg');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    auth_provider TEXT NOT NULL,
    is_verified INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS otp_codes (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    code_hash TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    consumed INTEGER NOT NULL DEFAULT 0,
    attempts INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE INDEX IF NOT EXISTS idx_otp_email ON otp_codes(email);

  ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS age INTEGER;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS lat DOUBLE PRECISION;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS lng DOUBLE PRECISION;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS telegram_chat_id TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS telegram_link_code TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS telegram_link_code_expires_at TEXT;
  ALTER TABLE users ADD COLUMN IF NOT EXISTS telegram_language TEXT;

  CREATE TABLE IF NOT EXISTS driver_vehicles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id),
    brand_model TEXT,
    color TEXT,
    plate_number TEXT,
    size_label TEXT,
    has_refrigeration INTEGER NOT NULL DEFAULT 0,
    has_side_rear_tent INTEGER NOT NULL DEFAULT 0,
    has_lift INTEGER NOT NULL DEFAULT 0,
    has_tie_down_straps INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS cargo_listings (
    id SERIAL PRIMARY KEY,
    shipper_id INTEGER NOT NULL REFERENCES users(id),
    cargo_type TEXT NOT NULL,
    description TEXT,
    pickup_label TEXT NOT NULL,
    pickup_lat DOUBLE PRECISION NOT NULL,
    pickup_lng DOUBLE PRECISION NOT NULL,
    dropoff_label TEXT NOT NULL,
    dropoff_lat DOUBLE PRECISION NOT NULL,
    dropoff_lng DOUBLE PRECISION NOT NULL,
    price DOUBLE PRECISION NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    driver_id INTEGER REFERENCES users(id),
    driver_lat DOUBLE PRECISION,
    driver_lng DOUBLE PRECISION,
    driver_location_updated_at TIMESTAMPTZ,
    requires_refrigeration INTEGER NOT NULL DEFAULT 0,
    requires_side_rear_tent INTEGER NOT NULL DEFAULT 0,
    requires_lift INTEGER NOT NULL DEFAULT 0,
    requires_tie_down_straps INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS driver_lat DOUBLE PRECISION;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS driver_lng DOUBLE PRECISION;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS driver_location_updated_at TIMESTAMPTZ;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS requires_refrigeration INTEGER NOT NULL DEFAULT 0;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS requires_side_rear_tent INTEGER NOT NULL DEFAULT 0;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS requires_lift INTEGER NOT NULL DEFAULT 0;
  ALTER TABLE cargo_listings ADD COLUMN IF NOT EXISTS requires_tie_down_straps INTEGER NOT NULL DEFAULT 0;

  CREATE INDEX IF NOT EXISTS idx_cargo_status ON cargo_listings(status);

  CREATE TABLE IF NOT EXISTS ratings (
    id SERIAL PRIMARY KEY,
    listing_id INTEGER NOT NULL REFERENCES cargo_listings(id),
    rater_id INTEGER NOT NULL REFERENCES users(id),
    ratee_id INTEGER NOT NULL REFERENCES users(id),
    stars INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(listing_id, rater_id)
  );

  CREATE INDEX IF NOT EXISTS idx_ratings_ratee ON ratings(ratee_id);
`;

const ready = pool.query(SCHEMA).catch((err) => {
  console.error('Failed to initialize Postgres schema:', err.message);
  process.exit(1);
});

/** Converts sqlite-style `?` placeholders to Postgres `$1, $2, ...`. */
function toPositional(sql) {
  let i = 0;
  return sql.replace(/\?/g, () => `$${++i}`);
}

async function get(sql, params = []) {
  await ready;
  const result = await pool.query(toPositional(sql), params);
  return result.rows[0];
}

async function all(sql, params = []) {
  await ready;
  const result = await pool.query(toPositional(sql), params);
  return result.rows;
}

async function run(sql, params = []) {
  await ready;
  const isInsert = /^\s*INSERT INTO/i.test(sql) && !/RETURNING/i.test(sql);
  const finalSql = isInsert ? `${sql} RETURNING id` : sql;
  const result = await pool.query(toPositional(finalSql), params);
  return {
    lastInsertRowid: isInsert ? result.rows[0]?.id : undefined,
    changes: result.rowCount,
  };
}

module.exports = { get, all, run };
