#![forbid(unsafe_code)]

pub mod schema;
pub mod views;

use diesel::connection::SimpleConnection;
use diesel_async::async_connection_wrapper::AsyncConnectionWrapper;
use diesel_async::pooled_connection::AsyncDieselConnectionManager;
use diesel_async::pooled_connection::bb8::Pool;
use diesel_async::{AsyncConnection, AsyncPgConnection};
use diesel_migrations::{EmbeddedMigrations, MigrationHarness, embed_migrations};

pub type DbPool = Pool<AsyncPgConnection>;

const MIGRATIONS: EmbeddedMigrations = embed_migrations!("migrations");

/// Runs pending migrations once at startup.
///
/// diesel_migrations is sync-only, so the async connection is wrapped in an
/// `AsyncConnectionWrapper` and driven from a blocking task rather than opening a second,
/// libpq-backed `diesel::PgConnection`. That keeps the whole crate on the pure-Rust
/// tokio-postgres backend - linking libpq for this one call was the only thing forcing a C
/// toolchain (and a vendored libpq/OpenSSL) onto every cross-compiled release target.
pub async fn migrate(database_url: &str) -> anyhow::Result<()> {
  let conn = AsyncPgConnection::establish(database_url).await?;
  let mut conn = AsyncConnectionWrapper::<AsyncPgConnection>::from(conn);

  tokio::task::spawn_blocking(move || {
    conn.batch_execute("CREATE SCHEMA IF NOT EXISTS public;")?;
    conn.run_pending_migrations(MIGRATIONS).map_err(|e| anyhow::anyhow!(e))?;
    Ok::<(), anyhow::Error>(())
  })
  .await??;

  Ok(())
}

pub async fn open(database_url: &str) -> anyhow::Result<DbPool> {
  let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
  let pool = Pool::builder().build(config).await?;
  Ok(pool)
}
