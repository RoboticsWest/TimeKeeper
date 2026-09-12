use std::path::PathBuf;

use anyhow::Result;
use database::DbPool;
use postgresql_embedded::{PostgreSQL, Settings};

use crate::config::ServerConfig;

const EMBEDDED_DB_NAME: &str = "timekeeper";

/// Default admin credentials used when no admin user exists yet, or when resetting the system
/// (e.g. purge-database) and no `--admin-password`/`TK_ADMIN_PASSWORD` override is configured.
pub const DEFAULT_ADMIN_USERNAME: &str = "admin";
pub const DEFAULT_ADMIN_PASSWORD: &str = "admin";

/// Holds the connection pool plus (if running without an external `DATABASE_URL`) the embedded
/// Postgres process, kept alive for the server's lifetime and stopped on graceful shutdown.
pub struct AppDb {
  pub pool: DbPool,
  pub database_url: String,
  embedded: Option<PostgreSQL>,
}

impl AppDb {
  pub async fn shutdown(self) {
    if let Some(pg) = self.embedded {
      log::info!("Stopping embedded Postgres");
      if let Err(e) = pg.stop().await {
        log::error!("Failed to stop embedded Postgres cleanly: {e}");
      }
    }
  }
}

pub async fn init(config: &ServerConfig) -> Result<AppDb> {
  let Some(url) = &config.database_url else {
    log::info!("DATABASE_URL not set, starting embedded Postgres under .pgdata/");
    let settings = Settings {
      data_dir: PathBuf::from(".pgdata"),
      temporary: false,
      username: "postgres".to_string(),
      password: "postgres".to_string(),
      ..Default::default()
    };

    let mut postgresql = PostgreSQL::new(settings);
    postgresql.setup().await?;
    postgresql.start().await?;

    if !postgresql.database_exists(EMBEDDED_DB_NAME).await? {
      postgresql.create_database(EMBEDDED_DB_NAME).await?;
    }

    let url = postgresql.settings().url(EMBEDDED_DB_NAME);
    database::migrate(&url).await?;
    let pool = database::open(&url).await?;

    return Ok(AppDb { pool, database_url: url, embedded: Some(postgresql) });
  };

  log::info!("Connecting to configured Postgres database");
  database::migrate(url).await?;
  let pool = database::open(url).await?;
  Ok(AppDb { pool, database_url: url.clone(), embedded: None })
}
