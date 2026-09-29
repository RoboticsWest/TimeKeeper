use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::sessions;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::location::Location;
use crate::domains::notification::Notification;
use crate::domains::session_rsvp::SessionRsvp;
use crate::domains::team_member_session::TeamMemberSession;
use crate::gql_common::capped;
use crate::loaders::{LocationLoader, SessionAttendanceLoader, SessionNotificationsLoader, SessionRsvpsLoader};

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = sessions)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Session {
  pub id: Uuid,
  pub start_time: DateTime<Utc>,
  pub end_time: DateTime<Utc>,
  pub location_id: Uuid,
  pub finished: bool,
  /// When the session really began: the earliest check-in. `None` until somebody checks in.
  ///
  /// Kept beside the scheduled `start_time`/`end_time` rather than replacing it, because the
  /// gap between the two *is* the overtime. Session-level statistics read these; deriving them
  /// by summing per-member attendance answers a different question (man-hours, not hours).
  pub actual_start_time: Option<DateTime<Utc>>,
  /// When the session really ended: the latest check-out, and only once nobody is still
  /// checked in. `None` while anyone remains signed in - the session has no real end yet.
  pub actual_end_time: Option<DateTime<Utc>>,
}

#[ComplexObject]
impl Session {
  /// Who attended this session, newest activity first.
  async fn attendance(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<TeamMemberSession>> {
    require_permission(ctx, "team_member_sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionAttendanceLoader>>()?;
    let mut rows = loader.load_one(self.id).await?.unwrap_or_default();
    rows.sort_by(|a, b| {
      let (a_at, b_at) = (a.check_out_time.unwrap_or(a.check_in_time), b.check_out_time.unwrap_or(b.check_in_time));
      b_at.cmp(&a_at).then_with(|| b.id.cmp(&a.id))
    });
    Ok(capped(rows, limit))
  }

  /// The RSVPs members gave for this session.
  async fn rsvps(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<SessionRsvp>> {
    require_permission(ctx, "session_rsvps", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionRsvpsLoader>>()?;
    Ok(capped(loader.load_one(self.id).await?.unwrap_or_default(), limit))
  }

  /// The reminders and DMs scheduled against this session.
  async fn notifications(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<Notification>> {
    require_permission(ctx, "notifications", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionNotificationsLoader>>()?;
    Ok(capped(loader.load_one(self.id).await?.unwrap_or_default(), limit))
  }

  /// Where the session is held.
  ///
  /// Batched, so a page of sessions costs one query for every location on it rather than one each.
  async fn location(&self, ctx: &Context<'_>) -> Result<Option<Location>> {
    require_permission(ctx, "locations", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<LocationLoader>>()?;
    Ok(loader.load_one(self.location_id).await?)
  }
}
