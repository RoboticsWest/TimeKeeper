use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::locations};

use super::model::Location;

/// Narrowing for `query_page`. Every field is optional; the semantics mirror the other paged
/// resources: an absent constraint means "everything" rather than "nothing".
///
/// All filtering happens in SQL so the cost tracks the page, not the table.
#[derive(Debug, Clone, Default)]
pub struct LocationFilter {
  /// Case-insensitive substring match on the location name.
  pub search: Option<String>,
}

/// Builds the filtered locations query.
///
/// A macro rather than a function for the same reason as `filtered_attendance!`: the boxed query
/// type is named differently in the `select` and `count` positions, and a
/// `BoxedSelectStatement` is not `Clone`, so the query is rebuilt rather than reused.
macro_rules! filtered_locations {
  ($filter:expr) => {{
    let mut query = locations::table.into_boxed();

    if let Some(search) = $filter.search.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
      // ILIKE rather than lowercasing both sides: it keeps the comparison in the database and
      // reads the same way the admin typed it.
      query = query.filter(locations::location.ilike(format!("%{search}%")));
    }

    query
  }};
}

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
  /// One page of locations matching `filter`, ordered by name, with the total match count.
  async fn query_page(&self, filter: &LocationFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Location>, i64)>;
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

  async fn query_page(&self, filter: &LocationFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Location>, i64)> {
    let mut conn = self.pool.get().await?;

    // Counted with the same narrowing as the page but without the page bounds, so the pager
    // reports how many rows it is paging through rather than how many it received.
    let total: i64 = filtered_locations!(filter).count().get_result(&mut conn).await?;

    let items = filtered_locations!(filter)
      // `id` breaks ties so a duplicate name cannot make a row appear on two pages or none.
      .order((locations::location.asc(), locations::id.asc()))
      .limit(limit)
      .offset(offset)
      .select(Location::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }
}
