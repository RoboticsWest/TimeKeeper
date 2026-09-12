use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::team_members;

use crate::auth::auth_helpers::get_auth;
use crate::auth::permissions::PermissionLevel;

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
  /// The member's quick sign-in PIN, or `None` for callers without
  /// `team_members` write access.
  ///
  /// Returns `None` rather than erroring on purpose: kiosks and the admin UI
  /// share one selection set, so erroring here would break every read-only
  /// client's team-member query instead of just omitting a field it can't see.
  async fn quick_pin(&self, ctx: &Context<'_>) -> Result<Option<String>> {
    let permitted =
      get_auth(ctx).is_some_and(|claims| claims.has_permission("team_members", PermissionLevel::Write));

    Ok(if permitted { self.quick_pin.clone() } else { None })
  }
}
