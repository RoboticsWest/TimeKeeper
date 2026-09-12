use std::sync::Arc;

use async_graphql::{Context, Error, Object, Result};
use base64::Engine;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;

use super::logic::{
  DiscordBehaviorUpdate, DiscordCoreUpdate, DiscordReminderUpdate, DiscordRole, GeneralUpdate,
  ImportDiscordMembersResult, LeaderboardUpdate, SettingsLogic,
};
use super::model::Settings;

const RESOURCE: &str = "settings";
const VALID_MEMBER_TYPES: &[&str] = &["student", "mentor"];

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn SettingsLogic>> {
  Ok(ctx.data::<Arc<dyn SettingsLogic>>()?.clone())
}

fn validate_member_types(types: &[String]) -> Result<()> {
  for t in types {
    if !VALID_MEMBER_TYPES.contains(&t.as_str()) {
      return Err(Error::new(format!("Invalid member type '{t}', expected 'student' or 'mentor'")));
    }
  }
  Ok(())
}

#[derive(Default)]
pub struct SettingsQuery;

#[Object]
impl SettingsQuery {
  async fn settings(&self, ctx: &Context<'_>) -> Result<Settings> {
    Ok(logic(ctx)?.get().await?)
  }

  async fn logo(&self, ctx: &Context<'_>) -> Result<Option<String>> {
    Ok(logic(ctx)?.get_logo().await?.map(|bytes| base64::engine::general_purpose::STANDARD.encode(bytes)))
  }

  async fn discord_roles(&self, ctx: &Context<'_>) -> Result<Vec<DiscordRole>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    logic(ctx)?.get_discord_roles().await.map_err(|e| Error::new(e.to_string()))
  }
}

#[derive(Default)]
pub struct SettingsMutation;

#[Object]
impl SettingsMutation {
  async fn update_general_settings(
    &self,
    ctx: &Context<'_>,
    next_session_threshold_secs: Option<i64>,
    timezone: Option<String>,
    quick_pin_enabled: Option<bool>,
  ) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.update_general(GeneralUpdate { next_session_threshold_secs, timezone, quick_pin_enabled }).await?;
    Ok(true)
  }

  async fn update_leaderboard_settings(
    &self,
    ctx: &Context<'_>,
    leaderboard_show_overtime: Option<bool>,
    leaderboard_member_types: Vec<String>,
  ) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_member_types(&leaderboard_member_types)?;
    logic(ctx)?.update_leaderboard(LeaderboardUpdate { leaderboard_show_overtime, leaderboard_member_types }).await?;
    Ok(true)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_discord_core_settings(
    &self,
    ctx: &Context<'_>,
    discord_enabled: Option<bool>,
    discord_bot_token: Option<String>,
    discord_guild_id: Option<String>,
    discord_announcement_channel_id: Option<String>,
    discord_notification_channel_id: Option<String>,
  ) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?
      .update_discord_core(DiscordCoreUpdate {
        discord_enabled,
        discord_bot_token,
        discord_guild_id,
        discord_announcement_channel_id,
        discord_notification_channel_id,
      })
      .await?;
    Ok(true)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_discord_reminder_settings(
    &self,
    ctx: &Context<'_>,
    discord_start_reminder_mins: Option<i64>,
    discord_end_reminder_mins: Option<i64>,
    discord_start_reminder_message: Option<String>,
    discord_end_reminder_message: Option<String>,
    discord_auto_delete_start_reminder: Option<bool>,
    discord_auto_delete_end_reminder: Option<bool>,
  ) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?
      .update_discord_reminder(DiscordReminderUpdate {
        discord_start_reminder_mins,
        discord_end_reminder_mins,
        discord_start_reminder_message,
        discord_end_reminder_message,
        discord_auto_delete_start_reminder,
        discord_auto_delete_end_reminder,
      })
      .await?;
    Ok(true)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_discord_behavior_settings(
    &self,
    ctx: &Context<'_>,
    discord_self_link_enabled: Option<bool>,
    discord_name_sync_enabled: Option<bool>,
    discord_overtime_dm_enabled: Option<bool>,
    discord_overtime_dm_mins: Option<i64>,
    discord_overtime_dm_message: Option<String>,
    discord_auto_checkout_dm_enabled: Option<bool>,
    discord_auto_checkout_dm_message: Option<String>,
    discord_checkout_enabled: Option<bool>,
    discord_rsvp_reactions_enabled: Option<bool>,
  ) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?
      .update_discord_behavior(DiscordBehaviorUpdate {
        discord_self_link_enabled,
        discord_name_sync_enabled,
        discord_overtime_dm_enabled,
        discord_overtime_dm_mins,
        discord_overtime_dm_message,
        discord_auto_checkout_dm_enabled,
        discord_auto_checkout_dm_message,
        discord_checkout_enabled,
        discord_rsvp_reactions_enabled,
      })
      .await?;
    Ok(true)
  }

  /// `logo` is base64-encoded image bytes.
  async fn upload_logo(&self, ctx: &Context<'_>, logo: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    let bytes = base64::engine::general_purpose::STANDARD.decode(logo).map_err(|e| Error::new(e.to_string()))?;
    logic(ctx)?.upload_logo(&bytes).await?;
    Ok(true)
  }

  async fn purge_database(&self, ctx: &Context<'_>) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    logic(ctx)?.purge_database().await?;
    Ok(true)
  }

  async fn import_discord_members(
    &self,
    ctx: &Context<'_>,
    role_id: String,
    member_type: String,
  ) -> Result<ImportDiscordMembersResult> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    if role_id.is_empty() {
      return Err(Error::new("Role ID is required"));
    }
    validate_member_types(std::slice::from_ref(&member_type))?;
    logic(ctx)?.import_discord_members(&role_id, &member_type).await.map_err(|e| Error::new(e.to_string()))
  }
}
