#![forbid(unsafe_code)]

pub mod schema;
pub mod views;

use diesel::connection::SimpleConnection;
use diesel::{Connection, PgConnection};
use diesel_async::AsyncPgConnection;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use diesel_async::pooled_connection::bb8::Pool;
use diesel_migrations::{EmbeddedMigrations, MigrationHarness, embed_migrations};

pub type DbPool = Pool<AsyncPgConnection>;

const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

/// Sync connection: diesel_migrations doesn't support async, and this only runs once at startup.
pub fn migrate(database_url: &str) -> anyhow::Result<()> {
  let mut conn = PgConnection::establish(database_url)?;
  conn.batch_execute("CREATE SCHEMA IF NOT EXISTS public;")?;
  conn.run_pending_migrations(MIGRATIONS).map_err(|e| anyhow::anyhow!(e))?;
  Ok(())
}

pub async fn open(database_url: &str) -> anyhow::Result<DbPool> {
  let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
  let pool = Pool::builder().build(config).await?;
  Ok(pool)
}
