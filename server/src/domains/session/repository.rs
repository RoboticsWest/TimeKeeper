use async_trait::async_trait;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::sessions};

use super::model::Session;

/// Narrows a session query. An empty list means "no constraint".
#[derive(Debug, Clone, Default)]
pub struct SessionFilter {
  /// Sessions starting at or after this instant.
  pub from: Option<DateTime<Utc>>,
  /// Sessions starting strictly before this instant.
  pub to: Option<DateTime<Utc>>,
  pub location_ids: Vec<Uuid>,
  /// `Some(true)` for finished sessions only, `Some(false)` for unfinished.
  pub finished: Option<bool>,
}

macro_rules! filtered_sessions {
  ($filter:expr) => {{
    let mut query = sessions::table.into_boxed();

    if let Some(from) = $filter.from {
      query = query.filter(sessions::start_time.ge(from));
    }
    if let Some(to) = $filter.to {
      query = query.filter(sessions::start_time.lt(to));
    }
    if !$filter.location_ids.is_empty() {
      query = query.filter(sessions::location_id.eq_any($filter.location_ids.clone()));
    }
    if let Some(finished) = $filter.finished {
      query = query.filter(sessions::finished.eq(finished));
    }

    query
  }};
}

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
  /// One page of sessions matching `filter`, newest start first, with the total match count.
  async fn query_page(&self, filter: &SessionFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Session>, i64)>;

  /// Recomputes `actual_start_time`/`actual_end_time` from the session's attendance rows.
  ///
  /// Done in SQL rather than in logic so it stays a single statement and cannot drift from the
  /// backfill in migration 0008, which computes exactly the same thing.
  async fn refresh_actual_times(&self, id: Uuid) -> anyhow::Result<Option<Session>>;
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

  async fn query_page(&self, filter: &SessionFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Session>, i64)> {
    let mut conn = self.pool.get().await?;

    let total: i64 = filtered_sessions!(filter).count().get_result(&mut conn).await?;

    // Id as a tiebreaker so the ordering is total: two sessions can share a start time, and
    // without it the same row can land on two pages or on neither.
    let items = filtered_sessions!(filter)
      .order((sessions::start_time.desc(), sessions::id.desc()))
      .limit(limit)
      .offset(offset)
      .select(Session::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }

  async fn refresh_actual_times(&self, id: Uuid) -> anyhow::Result<Option<Session>> {
    use diesel::sql_types::Uuid as SqlUuid;

    let mut conn = self.pool.get().await?;
    // `actual_end_time` stays NULL while anyone is still checked in: MAX() over the closed rows
    // would otherwise report whoever left first as the end of the whole session.
    let updated = diesel::sql_query(
      "
      UPDATE sessions s
      SET actual_start_time = agg.first_in,
          actual_end_time   = agg.last_out
      FROM (
          SELECT MIN(check_in_time) AS first_in,
                 CASE
                     WHEN COUNT(*) FILTER (WHERE check_out_time IS NULL) > 0 THEN NULL
                     ELSE MAX(check_out_time)
                 END AS last_out
          FROM team_member_sessions
          WHERE session_id = $1
      ) agg
      WHERE s.id = $1
      ",
    )
    .bind::<SqlUuid, _>(id)
    .execute(&mut conn)
    .await?;

    if updated == 0 {
      return Ok(None);
    }
    self.get(id).await
  }
}
