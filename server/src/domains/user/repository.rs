use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::users};

use super::model::User;

#[async_trait]
pub trait UserRepository: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>>;
  async fn get_all(&self) -> anyhow::Result<Vec<User>>;
  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>>;
  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User>;
  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgUserRepository {
  pool: DbPool,
}

impl PgUserRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl UserRepository for PgUserRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.filter(users::id.eq(id)).select(User::as_select()).first(&mut conn).await.optional()?)
  }

  async fn get_all(&self) -> anyhow::Result<Vec<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.select(User::as_select()).load(&mut conn).await?)
  }

  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.filter(users::username.eq(username)).select(User::as_select()).first(&mut conn).await.optional()?)
  }

  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(users::table)
        .values((users::id.eq(id), users::username.eq(username), users::password.eq(password)))
        .returning(User::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(users::table.filter(users::id.eq(id)))
        .set((users::username.eq(username), users::password.eq(password)))
        .returning(User::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(users::table.filter(users::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(users::table).execute(&mut conn).await?;
    Ok(())
  }
}
