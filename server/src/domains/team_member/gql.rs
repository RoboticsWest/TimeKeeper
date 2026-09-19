use std::sync::Arc;

use async_graphql::{Context, Error, ID, InputObject, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::{Change, Page, page_bounds};

use super::logic::TeamMemberLogic;
use super::model::TeamMember;
use super::repository::TeamMemberFilter;

const RESOURCE: &str = "team_members";
const TABLE: &str = "team_members";
const VALID_MEMBER_TYPES: &[&str] = &["student", "mentor"];

/// Matches the `team_members_quick_pin_length` CHECK constraint (migration 0009). Enforced here
/// as well as in the database so an over-long PIN comes back as a readable message rather than
/// a constraint-violation string.
const MAX_QUICK_PIN_LEN: usize = 50;

fn validate_member_type(value: &str) -> Result<()> {
  if VALID_MEMBER_TYPES.contains(&value) {
    Ok(())
  } else {
    Err(Error::new("Invalid member_type, expected 'student' or 'mentor'"))
  }
}

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn TeamMemberLogic>> {
  Ok(ctx.data::<Arc<dyn TeamMemberLogic>>()?.clone())
}

/// Treats a blank PIN as "no PIN", so clearing the field in the admin UI
/// releases the value for reuse instead of storing an empty string that would
/// collide with every other cleared PIN under the unique index.
fn normalize_quick_pin(quick_pin: Option<String>) -> Option<String> {
  quick_pin.map(|pin| pin.trim().to_string()).filter(|pin| !pin.is_empty())
}

/// Rejects a PIN longer than the column allows.
///
/// Counts characters rather than bytes, matching Postgres' `char_length`, so a multi-byte PIN
/// is measured the same way on both sides.
fn validate_quick_pin(quick_pin: Option<&String>) -> Result<()> {
  match quick_pin {
    Some(pin) if pin.chars().count() > MAX_QUICK_PIN_LEN => {
      Err(Error::new(format!("Quick PIN must be {MAX_QUICK_PIN_LEN} characters or fewer.")))
    }
    _ => Ok(()),
  }
}

/// Turns the unique-index violation into a message an admin can act on.
fn map_quick_pin_conflict(err: &anyhow::Error) -> Error {
  let text = err.to_string();
  if text.contains("team_members_quick_pin_key") {
    Error::new("That PIN is already in use by another team member.")
  } else {
    Error::new(text)
  }
}

/// Narrows `teamMemberPage`. Every field is optional; an empty list means "no constraint".
#[derive(InputObject, Default)]
pub struct TeamMemberFilterInput {
  /// Case-insensitive substring over first, last and display name.
  pub search: Option<String>,
  /// "student" / "mentor".
  pub member_types: Option<Vec<String>>,
  /// True for members with a linked Discord account, false for those without.
  pub has_discord: Option<bool>,
  /// True for members with a quick PIN set.
  pub has_quick_pin: Option<bool>,
}

impl From<TeamMemberFilterInput> for TeamMemberFilter {
  fn from(input: TeamMemberFilterInput) -> Self {
    Self {
      search: input.search,
      member_types: input.member_types.unwrap_or_default(),
      has_discord: input.has_discord,
      has_quick_pin: input.has_quick_pin,
    }
  }
}

#[derive(Default)]
pub struct TeamMemberQuery;

#[Object]
impl TeamMemberQuery {
  /// Pass `memberType` ("student"/"mentor") to filter, or omit for everyone.
  async fn team_members(&self, ctx: &Context<'_>, member_type: Option<String>) -> Result<Vec<TeamMember>> {
    let logic = logic(ctx)?;
    match member_type {
      Some(t) => {
        validate_member_type(&t)?;
        Ok(logic.get_by_member_type(&t).await?)
      }
      None => Ok(logic.get_all().await?),
    }
  }

  /// One filtered, paged slice of team members, ordered by name.
  ///
  /// The roster is small enough to load whole today, but the filters belong in SQL either way:
  /// the same query backs the search box, the type chips and the "unlinked Discord" view.
  async fn team_member_page(
    &self,
    ctx: &Context<'_>,
    filter: Option<TeamMemberFilterInput>,
    offset: Option<i32>,
    limit: Option<i32>,
  ) -> Result<Page<TeamMember>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    let (limit, offset) = page_bounds(offset, limit);
    let filter: TeamMemberFilter = filter.unwrap_or_default().into();
    let (items, total) = logic(ctx)?.query_page(&filter, offset, limit).await?;
    Ok(Page::new(items, total, offset, limit))
  }
}

#[derive(Default)]
pub struct TeamMemberMutation;

#[Object]
impl TeamMemberMutation {
  async fn upload_student_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_csv(&csv_data, "student").await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }

  async fn upload_mentor_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_csv(&csv_data, "mentor").await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }

  #[allow(clippy::too_many_arguments)]
  async fn create_team_member(
    &self,
    ctx: &Context<'_>,
    first_name: String,
    last_name: String,
    member_type: String,
    display_name: Option<String>,
    discord_id: Option<String>,
    quick_pin: Option<String>,
  ) -> Result<TeamMember> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_member_type(&member_type)?;
    let quick_pin = normalize_quick_pin(quick_pin);
    validate_quick_pin(quick_pin.as_ref())?;
    logic(ctx)?
      .add(
        &first_name,
        &last_name,
        &member_type,
        display_name.as_deref(),
        None,
        discord_id.as_deref(),
        quick_pin.as_deref(),
      )
      .await
      .map_err(|e| map_quick_pin_conflict(&e))
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_team_member(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    first_name: String,
    last_name: String,
    member_type: String,
    display_name: Option<String>,
    discord_id: Option<String>,
    quick_pin: Option<String>,
  ) -> Result<TeamMember> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_member_type(&member_type)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member not found"));
    }
    let quick_pin = normalize_quick_pin(quick_pin);
    validate_quick_pin(quick_pin.as_ref())?;
    logic
      .update(
        id,
        &first_name,
        &last_name,
        &member_type,
        display_name.as_deref(),
        None,
        discord_id.as_deref(),
        quick_pin.as_deref(),
      )
      .await
      .map_err(|e| map_quick_pin_conflict(&e))
  }

  async fn delete_team_member(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member not found"));
    }
    // RFID tags belonging to this member cascade-delete at the DB level (ON DELETE CASCADE).
    logic.remove(id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct TeamMemberSubscription;

#[Subscription]
impl TeamMemberSubscription {
  async fn team_member_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<TeamMember>>> {
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        let data = match change.operation {
          ChangeOperation::Delete => None,
          _ => logic.get(change.id.parse().ok()?).await.ok().flatten(),
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
