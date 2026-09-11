use async_trait::async_trait;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::sessions};

use super::model::Session;

#[async_trait]
pub trait SessionRepository: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Session>>;
  async fn add(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session>;
  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Option<Session>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgSessionRepository {
  pool: DbPool,
}

impl PgSessionRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl SessionRepository for PgSessionRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>> {
    let mut conn = self.pool.get().await?;
    Ok(sessions::table.filter(sessions::id.eq(id)).select(Session::as_select()).first(&mut conn).await.optional()?)
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Session>> {
    let mut conn = self.pool.get().await?;
    Ok(sessions::table.select(Session::as_select()).load(&mut conn).await?)
  }

  async fn add(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(sessions::table)
        .values((
          sessions::id.eq(id),
          sessions::start_time.eq(start_time),
          sessions::end_time.eq(end_time),
          sessions::location_id.eq(location_id),
          sessions::finished.eq(finished),
        ))
        .returning(Session::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Option<Session>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(sessions::table.filter(sessions::id.eq(id)))
        .set((
          sessions::start_time.eq(start_time),
          sessions::end_time.eq(end_time),
          sessions::location_id.eq(location_id),
          sessions::finished.eq(finished),
        ))
        .returning(Session::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(sessions::table.filter(sessions::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(sessions::table).execute(&mut conn).await?;
    Ok(())
  }
}
