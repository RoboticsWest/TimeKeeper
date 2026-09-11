use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;

use database::{DbPool, schema::secrets};

use super::model::Secret;

/// Fixed singleton key the JWT secret is stored under.
const SECRET_KEY: &str = "jwt_secret";

fn generate_secret() -> Vec<u8> {
  rand::random::<[u8; 32]>().to_vec()
}

#[async_trait]
pub trait SecretRepository: Send + Sync {
  /// Returns the stored JWT secret, generating and persisting a new random one if none exists yet.
  async fn get(&self) -> anyhow::Result<Secret>;
  async fn set(&self, secret_bytes: &[u8]) -> anyhow::Result<Secret>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgSecretRepository {
  pool: DbPool,
}

impl PgSecretRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl SecretRepository for PgSecretRepository {
  async fn get(&self) -> anyhow::Result<Secret> {
    let mut conn = self.pool.get().await?;
    let existing = secrets::table
      .filter(secrets::key.eq(SECRET_KEY))
      .select(Secret::as_select())
      .first(&mut conn)
      .await
      .optional()?;
    drop(conn);

    let Some(secret) = existing else {
      log::warn!("JWT Secret not found in DB, generating new one...");
      return self.set(&generate_secret()).await;
    };

    Ok(secret)
  }

  async fn set(&self, secret_bytes: &[u8]) -> anyhow::Result<Secret> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::insert_into(secrets::table)
        .values((secrets::key.eq(SECRET_KEY), secrets::secret_bytes.eq(secret_bytes)))
        .on_conflict(secrets::key)
        .do_update()
        .set(secrets::secret_bytes.eq(secret_bytes))
        .returning(Secret::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(secrets::table).execute(&mut conn).await?;
    Ok(())
  }
}
