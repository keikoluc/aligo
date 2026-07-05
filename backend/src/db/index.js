// Local development uses SQLite (zero setup). Deploying with a
// DATABASE_URL env var (Postgres connection string) switches the whole
// app over automatically — no code changes needed at deploy time.
module.exports = process.env.DATABASE_URL
  ? require('./postgres')
  : require('./sqlite');
