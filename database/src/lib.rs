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

/// Connections the pool will open. Above bb8's default of 10, which was a real ceiling: the
/// GraphQL API, the change-notify republisher, the Discord bot and the session scheduler all draw
/// from this one pool, and a handful of concurrent aggregate requests (the achievements board
/// reads five tables at once) could hold every connection while the rest queued.
///
/// Postgres defaults to `max_connections = 100`, so this leaves plenty of headroom for the
/// embedded instance and for a deploy sharing a database container.
const POOL_MAX_SIZE: u32 = 48;

/// How long a request waits for a free connection before failing.
///
/// bb8 defaults to 30 seconds, which is long enough that a starved request looks like a hang and
/// then surfaces as an ordinary query error far from its cause — the achievements page spent half
/// a minute loading and then reported "no team members". Ten seconds is still generous for a
/// checkout and fails while the reason is still obvious.
const POOL_CONNECTION_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(10);

pub async fn open(database_url: &str) -> anyhow::Result<DbPool> {
  let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
  let pool = Pool::builder().max_size(POOL_MAX_SIZE).connection_timeout(POOL_CONNECTION_TIMEOUT).build(config).await?;
  Ok(pool)
}
