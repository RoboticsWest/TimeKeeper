use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::locations};

use super::model::Location;

#[async_trait]
pub trait LocationRepository: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Location>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Location>>;
  /// Used by CSV/ICS schedule import to check whether a location already exists by name.
  async fn get_by_name(&self, location: &str) -> anyhow::Result<Vec<Location>>;
  async fn add(&self, location: &str) -> anyhow::Result<Location>;
  async fn update(&self, id: Uuid, location: &str) -> anyhow::Result<Option<Location>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgLocationRepository {
  pool: DbPool,
}

impl PgLocationRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl LocationRepository for PgLocationRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Location>> {
    let mut conn = self.pool.get().await?;
    Ok(locations::table.filter(locations::id.eq(id)).select(Location::as_select()).first(&mut conn).await.optional()?)
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Location>> {
    let mut conn = self.pool.get().await?;
    Ok(locations::table.select(Location::as_select()).load(&mut conn).await?)
  }

  async fn get_by_name(&self, location: &str) -> anyhow::Result<Vec<Location>> {
    let mut conn = self.pool.get().await?;
    Ok(locations::table.filter(locations::location.eq(location)).select(Location::as_select()).load(&mut conn).await?)
  }

  async fn add(&self, location: &str) -> anyhow::Result<Location> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(locations::table)
        .values((locations::id.eq(id), locations::location.eq(location)))
        .returning(Location::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(&self, id: Uuid, location: &str) -> anyhow::Result<Option<Location>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(locations::table.filter(locations::id.eq(id)))
        .set(locations::location.eq(location))
        .returning(Location::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(locations::table.filter(locations::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(locations::table).execute(&mut conn).await?;
    Ok(())
  }
}
