use async_trait::async_trait;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{locations, notifications, sessions, team_members},
};

use super::model::{Notification, STATUS_PENDING, STATUS_SENT};

/// Narrows a notification query. Every field is optional; an empty list means "no constraint"
/// rather than "match nothing", matching a filter UI with no chips selected.
///
/// Applied in SQL rather than after loading: notifications accumulate a handful of rows per
/// session, so this table grows with the season the same way attendance does.
#[derive(Debug, Clone, Default)]
pub struct NotificationFilter {
  /// Only notifications belonging to this session.
  pub session_id: Option<Uuid>,
  /// Only the per-member kinds aimed at this member.
  pub team_member_id: Option<Uuid>,
  /// `session_start_reminder` / `session_end_reminder` / `overtime` / `auto_checkout`.
  pub notification_types: Vec<String>,
  /// `pending` / `sent` / `skipped` / `cancelled` / `failed`.
  pub statuses: Vec<String>,
  /// Scheduled at or after this instant. Rows with no `scheduled_for` are excluded once either
  /// bound is set, since an unscheduled row has no place on a timeline.
  pub from: Option<DateTime<Utc>>,
  /// Scheduled strictly before this instant.
  pub to: Option<DateTime<Utc>>,
  /// Case-insensitive substring over the notification's location name, the member's first, last
  /// and display name, and the raw type and status values.
  ///
  /// The list renders labels built from other tables, so the search has to join them; matching
  /// only the notifications table would silently stop finding rows by location or member.
  pub search: Option<String>,
}

/// Builds the filtered notifications query.
///
/// A macro rather than a function for the same reason as `filtered_attendance!`: the boxed query
/// type is named differently in the `select` and `count` positions, and a
/// `BoxedSelectStatement` is not `Clone`, so the query is rebuilt rather than reused.
macro_rules! filtered_notifications {
  ($filter:expr) => {{
    // Joined so the search can reach the location and member names the list actually displays.
    // `session_id` is NOT NULL so sessions/locations are inner joins; `team_member_id` is set
    // only for the per-member kinds, so team_members is a left join and must stay one — an
    // inner join here would silently drop every session-wide reminder.
    let mut query = notifications::table
      .inner_join(sessions::table.on(sessions::id.eq(notifications::session_id)))
      .inner_join(locations::table.on(locations::id.eq(sessions::location_id)))
      .left_join(team_members::table.on(team_members::id.nullable().eq(notifications::team_member_id)))
      .into_boxed();

    if let Some(session_id) = $filter.session_id {
      query = query.filter(notifications::session_id.eq(session_id));
    }
    if let Some(team_member_id) = $filter.team_member_id {
      query = query.filter(notifications::team_member_id.eq(team_member_id));
    }
    if !$filter.notification_types.is_empty() {
      query = query.filter(notifications::notification_type.eq_any($filter.notification_types.clone()));
    }
    if !$filter.statuses.is_empty() {
      query = query.filter(notifications::status.eq_any($filter.statuses.clone()));
    }
    if let Some(from) = $filter.from {
      query = query.filter(notifications::scheduled_for.ge(from));
    }
    if let Some(to) = $filter.to {
      query = query.filter(notifications::scheduled_for.lt(to));
    }
    if let Some(search) = $filter.search.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
      let pattern = format!("%{search}%");
      query = query.filter(
        locations::location
          .ilike(pattern.clone())
          .or(team_members::first_name.nullable().ilike(pattern.clone()))
          .or(team_members::last_name.nullable().ilike(pattern.clone()))
          .or(team_members::display_name.nullable().ilike(pattern.clone()))
          .or(notifications::notification_type.ilike(pattern.clone()))
          .or(notifications::status.ilike(pattern)),
      );
    }

    query
  }};
}

/// Fields needed to schedule a notification. A struct rather than eight positional arguments,
/// which is what `#[allow(clippy::too_many_arguments)]` was papering over before.
#[derive(Debug, Clone)]
pub struct NewNotification<'a> {
  pub notification_type: &'a str,
  pub session_id: Uuid,
  pub team_member_id: Option<Uuid>,
  pub scheduled_for: Option<DateTime<Utc>>,
  pub status: &'a str,
}

#[async_trait]
pub trait NotificationRepository: Send + Sync {
  /// One page of notifications matching `filter`, soonest-scheduled last, with the total match
  /// count.
  async fn query_page(
    &self,
    filter: &NotificationFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<Notification>, i64)>;
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Notification>>;

  /// Inserts a scheduled notification.
  ///
  /// A conflict on the "one of this kind per session (per member)" indexes from `0008` is not an
  /// error: it means the row is already scheduled, which is exactly the desired end state. The
  /// existing row is returned untouched, so a re-run never resurrects something already sent,
  /// cancelled or skipped.
  async fn schedule(&self, new: NewNotification<'_>) -> anyhow::Result<Notification>;

  async fn set_status(&self, id: Uuid, status: &str) -> anyhow::Result<Option<Notification>>;

  /// Marks a notification sent, stamping `sent_at` and recording the Discord message id so the
  /// message can be deleted again later.
  async fn mark_sent(&self, id: Uuid, discord_message_id: Option<&str>) -> anyhow::Result<Option<Notification>>;

  /// Clears a stored Discord message id (after the message has been deleted).
  async fn clear_message_id(&self, id: Uuid) -> anyhow::Result<()>;

  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;

  /// All notifications belonging to a given session.
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>>;

  /// Everything still `pending` whose `scheduled_for` has arrived (or is null).
  async fn get_due(&self, now: DateTime<Utc>) -> anyhow::Result<Vec<Notification>>;

  /// Whether a notification of this type/session/team-member combination already exists, in
  /// *any* status. Used to avoid re-scheduling one that was deliberately cancelled.
  async fn exists(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
  ) -> anyhow::Result<bool>;
}

pub struct PgNotificationRepository {
  pool: DbPool,
}

impl PgNotificationRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl NotificationRepository for PgNotificationRepository {
  async fn query_page(
    &self,
    filter: &NotificationFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<Notification>, i64)> {
    let mut conn = self.pool.get().await?;

    // Counted with the same narrowing as the page but without the page bounds, so the pager
    // reports how many rows it is paging through rather than how many it received.
    let total: i64 = filtered_notifications!(filter).count().get_result(&mut conn).await?;

    let items = filtered_notifications!(filter)
      // Newest first. `scheduled_for` is nullable, and Postgres sorts NULLs first under DESC,
      // which would float the condition-driven kinds (overtime, auto-checkout) above every
      // scheduled reminder; `nulls_last` keeps them at the end where the UI expects them.
      // `id` is a v7 UUID, so it breaks ties in creation order rather than arbitrarily.
      .order((notifications::scheduled_for.desc().nulls_last(), notifications::id.desc()))
      .limit(limit)
      .offset(offset)
      .select(Notification::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }

  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::id.eq(id))
        .select(Notification::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(notifications::table.select(Notification::as_select()).load(&mut conn).await?)
  }

  async fn schedule(&self, new: NewNotification<'_>) -> anyhow::Result<Notification> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();

    let inserted = diesel::insert_into(notifications::table)
      .values((
        notifications::id.eq(id),
        notifications::notification_type.eq(new.notification_type),
        notifications::session_id.eq(new.session_id),
        notifications::team_member_id.eq(new.team_member_id),
        notifications::scheduled_for.eq(new.scheduled_for),
        notifications::status.eq(new.status),
      ))
      .on_conflict_do_nothing()
      .returning(Notification::as_select())
      .get_result(&mut conn)
      .await
      .optional()?;

    if let Some(record) = inserted {
      return Ok(record);
    }

    // Conflict: a row for this kind already exists. Return it rather than failing.
    let existing = match new.team_member_id {
      Some(member_id) => notifications::table
        .filter(notifications::notification_type.eq(new.notification_type))
        .filter(notifications::session_id.eq(new.session_id))
        .filter(notifications::team_member_id.eq(member_id))
        .select(Notification::as_select())
        .first(&mut conn)
        .await
        .optional()?,
      None => notifications::table
        .filter(notifications::notification_type.eq(new.notification_type))
        .filter(notifications::session_id.eq(new.session_id))
        .filter(notifications::team_member_id.is_null())
        .select(Notification::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    };

    existing.ok_or_else(|| anyhow::anyhow!("Notification insert conflicted but no existing row was found"))
  }

  async fn set_status(&self, id: Uuid, status: &str) -> anyhow::Result<Option<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(notifications::table.filter(notifications::id.eq(id)))
        .set(notifications::status.eq(status))
        .returning(Notification::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn mark_sent(&self, id: Uuid, discord_message_id: Option<&str>) -> anyhow::Result<Option<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(notifications::table.filter(notifications::id.eq(id)))
        .set((
          notifications::status.eq(STATUS_SENT),
          notifications::sent_at.eq(Utc::now()),
          notifications::discord_message_id.eq(discord_message_id),
        ))
        .returning(Notification::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn clear_message_id(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::update(notifications::table.filter(notifications::id.eq(id)))
      .set(notifications::discord_message_id.eq(None::<String>))
      .execute(&mut conn)
      .await?;
    Ok(())
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(notifications::table.filter(notifications::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(notifications::table).execute(&mut conn).await?;
    Ok(())
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::session_id.eq(session_id))
        .select(Notification::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_due(&self, now: DateTime<Utc>) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::status.eq(STATUS_PENDING))
        .filter(notifications::scheduled_for.is_null().or(notifications::scheduled_for.le(now)))
        .select(Notification::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn exists(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
  ) -> anyhow::Result<bool> {
    let mut conn = self.pool.get().await?;
    let count: i64 = match team_member_id {
      Some(team_member_id) => {
        notifications::table
          .filter(notifications::notification_type.eq(notification_type))
          .filter(notifications::session_id.eq(session_id))
          .filter(notifications::team_member_id.eq(team_member_id))
          .count()
          .get_result(&mut conn)
          .await?
      }
      None => {
        notifications::table
          .filter(notifications::notification_type.eq(notification_type))
          .filter(notifications::session_id.eq(session_id))
          .filter(notifications::team_member_id.is_null())
          .count()
          .get_result(&mut conn)
          .await?
      }
    };
    Ok(count > 0)
  }
}
