use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::team_members;

use crate::auth::auth_helpers::get_auth;
use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::notification::Notification;
use crate::domains::rfid_tag::RfidTag;
use crate::domains::session_rsvp::SessionRsvp;
use crate::domains::statistics::TeamMemberStats;
use crate::domains::team_member_session::TeamMemberSession;
use crate::gql_common::capped;
use crate::loaders::{
  MemberAttendanceLoader, MemberNotificationsLoader, MemberRfidTagsLoader, MemberRsvpsLoader, MemberStatsLoader,
};

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = team_members)]
#[diesel(check_for_backend(diesel::pg::Pg))]
#[graphql(complex)]
pub struct TeamMember {
  pub id: Uuid,
  pub first_name: String,
  pub last_name: String,
  /// Plain string holding one of the lowercase values enforced by the DB CHECK constraint:
  /// `'student'` | `'mentor'`.
  pub member_type: String,
  pub display_name: Option<String>,
  pub mobile_number: Option<String>,
  pub discord_id: Option<String>,
  /// Plaintext quick-sign-in PIN.
  ///
  /// Skipped from the derived object and re-exposed through the resolver below,
  /// so it is never included in the replicated `teamMembers` payload that
  /// read-only kiosks receive.
  #[graphql(skip)]
  pub quick_pin: Option<String>,
}

#[ComplexObject]
impl TeamMember {
  /// Every visit this member has made, newest activity first.
  async fn attendance(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<TeamMemberSession>> {
    require_permission(ctx, "team_member_sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<MemberAttendanceLoader>>()?;
    let mut rows = loader.load_one(self.id).await?.unwrap_or_default();
    rows.sort_by(|a, b| {
      let (a_at, b_at) = (a.check_out_time.unwrap_or(a.check_in_time), b.check_out_time.unwrap_or(b.check_in_time));
      b_at.cmp(&a_at).then_with(|| b.id.cmp(&a.id))
    });
    Ok(capped(rows, limit))
  }

  /// The RFID cards linked to this member.
  async fn rfid_tags(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<RfidTag>> {
    require_permission(ctx, "rfid_tags", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<MemberRfidTagsLoader>>()?;
    Ok(capped(loader.load_one(self.id).await?.unwrap_or_default(), limit))
  }

  /// This member's RSVPs.
  async fn rsvps(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<SessionRsvp>> {
    require_permission(ctx, "session_rsvps", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<MemberRsvpsLoader>>()?;
    Ok(capped(loader.load_one(self.id).await?.unwrap_or_default(), limit))
  }

  /// The per-member notifications aimed at this member (overtime and auto-checkout DMs).
  async fn notifications(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<Notification>> {
    require_permission(ctx, "notifications", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<MemberNotificationsLoader>>()?;
    Ok(capped(loader.load_one(self.id).await?.unwrap_or_default(), limit))
  }

  /// Counters recorded about this member that attendance rows cannot answer — lifetime check-ins,
  /// overtime warnings delivered, when they joined. `None` until the first one is recorded.
  async fn stats(&self, ctx: &Context<'_>) -> Result<Option<TeamMemberStats>> {
    require_permission(ctx, "statistics", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<MemberStatsLoader>>()?;
    Ok(loader.load_one(self.id).await?)
  }

  /// The member's quick sign-in PIN, or `None` for callers without
  /// `team_members` write access.
  ///
  /// Returns `None` rather than erroring on purpose: kiosks and the admin UI
  /// share one selection set, so erroring here would break every read-only
  /// client's team-member query instead of just omitting a field it can't see.
  async fn quick_pin(&self, ctx: &Context<'_>) -> Result<Option<String>> {
    let permitted = get_auth(ctx).is_some_and(|claims| claims.has_permission("team_members", PermissionLevel::Write));

    Ok(if permitted { self.quick_pin.clone() } else { None })
  }
}
