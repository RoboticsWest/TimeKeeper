use std::sync::Arc;

use async_graphql::SimpleObject;
use async_trait::async_trait;
use serenity::http::Http;

use crate::auth::permissions_repository::PermissionsRepository;
use crate::domains::location::LocationRepository;
use crate::domains::notification::NotificationRepository;
use crate::domains::secret::SecretRepository;
use crate::domains::session::SessionRepository;
use crate::domains::session_rsvp::{SessionRsvpMessageRepository, SessionRsvpRepository};
use crate::domains::team_member::{TeamMember, TeamMemberRepository};
use crate::domains::team_member_session::TeamMemberSessionRepository;
use crate::domains::user::UserRepository;

use super::model::Settings;
use super::repository::{LogoRepository, SettingsRepository};

pub struct GeneralUpdate {
  pub next_session_threshold_secs: Option<i64>,
  pub timezone: Option<String>,
  pub quick_pin_enabled: Option<bool>,
}

pub struct LeaderboardUpdate {
  pub leaderboard_show_overtime: Option<bool>,
  pub leaderboard_member_types: Vec<String>,
}

pub struct DiscordCoreUpdate {
  pub discord_enabled: Option<bool>,
  pub discord_bot_token: Option<String>,
  pub discord_guild_id: Option<String>,
  pub discord_announcement_channel_id: Option<String>,
  pub discord_notification_channel_id: Option<String>,
}

pub struct DiscordReminderUpdate {
  pub discord_start_reminder_mins: Option<i64>,
  pub discord_end_reminder_mins: Option<i64>,
  pub discord_start_reminder_message: Option<String>,
  pub discord_end_reminder_message: Option<String>,
  pub discord_auto_delete_start_reminder: Option<bool>,
  pub discord_auto_delete_end_reminder: Option<bool>,
}

pub struct DiscordBehaviorUpdate {
  pub discord_self_link_enabled: Option<bool>,
  pub discord_name_sync_enabled: Option<bool>,
  pub discord_overtime_dm_enabled: Option<bool>,
  pub discord_overtime_dm_mins: Option<i64>,
  pub discord_overtime_dm_message: Option<String>,
  pub discord_auto_checkout_dm_enabled: Option<bool>,
  pub discord_auto_checkout_dm_message: Option<String>,
  pub discord_checkout_enabled: Option<bool>,
  pub discord_rsvp_reactions_enabled: Option<bool>,
}

#[derive(SimpleObject)]
pub struct DiscordRole {
  pub id: String,
  pub name: String,
}

#[derive(SimpleObject)]
pub struct ImportDiscordMembersResult {
  pub imported: i32,
  pub linked: i32,
  pub already_linked: i32,
}

#[async_trait]
pub trait SettingsLogic: Send + Sync {
  async fn get(&self) -> anyhow::Result<Settings>;
  async fn update_general(&self, update: GeneralUpdate) -> anyhow::Result<()>;
  async fn update_leaderboard(&self, update: LeaderboardUpdate) -> anyhow::Result<()>;
  async fn update_discord_core(&self, update: DiscordCoreUpdate) -> anyhow::Result<()>;
  async fn update_discord_reminder(&self, update: DiscordReminderUpdate) -> anyhow::Result<()>;
  async fn update_discord_behavior(&self, update: DiscordBehaviorUpdate) -> anyhow::Result<()>;
  async fn upload_logo(&self, data: &[u8]) -> anyhow::Result<()>;
  async fn get_logo(&self) -> anyhow::Result<Option<Vec<u8>>>;
  async fn purge_database(&self) -> anyhow::Result<()>;
  async fn get_discord_roles(&self) -> anyhow::Result<Vec<DiscordRole>>;
  async fn import_discord_members(
    &self,
    role_id: &str,
    member_type: &str,
  ) -> anyhow::Result<ImportDiscordMembersResult>;
}

#[allow(clippy::too_many_arguments)]
pub struct DefaultSettingsLogic<R: SettingsRepository, L: LogoRepository> {
  repo: R,
  logos: L,
  notifications: Arc<dyn NotificationRepository>,
  team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
  sessions: Arc<dyn SessionRepository>,
  team_members: Arc<dyn TeamMemberRepository>,
  locations: Arc<dyn LocationRepository>,
  users: Arc<dyn UserRepository>,
  secrets: Arc<dyn SecretRepository>,
  session_rsvps: Arc<dyn SessionRsvpRepository>,
  session_rsvp_messages: Arc<dyn SessionRsvpMessageRepository>,
  permissions: Arc<dyn PermissionsRepository>,
}

impl<R: SettingsRepository, L: LogoRepository> DefaultSettingsLogic<R, L> {
  #[allow(clippy::too_many_arguments)]
  pub fn new(
    repo: R,
    logos: L,
    notifications: Arc<dyn NotificationRepository>,
    team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
    sessions: Arc<dyn SessionRepository>,
    team_members: Arc<dyn TeamMemberRepository>,
    locations: Arc<dyn LocationRepository>,
    users: Arc<dyn UserRepository>,
    secrets: Arc<dyn SecretRepository>,
    session_rsvps: Arc<dyn SessionRsvpRepository>,
    session_rsvp_messages: Arc<dyn SessionRsvpMessageRepository>,
    permissions: Arc<dyn PermissionsRepository>,
  ) -> Self {
    Self {
      repo,
      logos,
      notifications,
      team_member_sessions,
      sessions,
      team_members,
      locations,
      users,
      secrets,
      session_rsvps,
      session_rsvp_messages,
      permissions,
    }
  }

  async fn save(&self, settings: &Settings) -> anyhow::Result<()> {
    self.repo.set(settings).await?;
    Ok(())
  }
}

#[async_trait]
impl<R: SettingsRepository, L: LogoRepository> SettingsLogic for DefaultSettingsLogic<R, L> {
  async fn get(&self) -> anyhow::Result<Settings> {
    self.repo.get().await
  }

  async fn update_general(&self, update: GeneralUpdate) -> anyhow::Result<()> {
    let mut settings = self.repo.get().await?;
    if let Some(v) = update.next_session_threshold_secs {
      settings.next_session_threshold_secs = v;
    }
    if let Some(v) = update.timezone {
      settings.timezone = v;
    }
    if let Some(v) = update.quick_pin_enabled {
      settings.quick_pin_enabled = v;
    }
    self.save(&settings).await
  }

  async fn update_leaderboard(&self, update: LeaderboardUpdate) -> anyhow::Result<()> {
    let mut settings = self.repo.get().await?;
    if let Some(v) = update.leaderboard_show_overtime {
      settings.leaderboard_show_overtime = v;
    }
    settings.leaderboard_member_types = update.leaderboard_member_types.into_iter().map(Some).collect();
    self.save(&settings).await
  }

  async fn update_discord_core(&self, update: DiscordCoreUpdate) -> anyhow::Result<()> {
    let mut settings = self.repo.get().await?;
    if let Some(v) = update.discord_enabled {
      settings.discord_enabled = v;
    }
    if let Some(v) = update.discord_bot_token {
      settings.discord_bot_token = v;
    }
    if let Some(v) = update.discord_guild_id {
      settings.discord_guild_id = v;
    }
    if let Some(v) = update.discord_announcement_channel_id {
      settings.discord_announcement_channel_id = v;
    }
    if let Some(v) = update.discord_notification_channel_id {
      settings.discord_notification_channel_id = v;
    }
    self.save(&settings).await
  }

  async fn update_discord_reminder(&self, update: DiscordReminderUpdate) -> anyhow::Result<()> {
    let mut settings = self.repo.get().await?;
    if let Some(v) = update.discord_start_reminder_mins {
      settings.discord_start_reminder_mins = v;
    }
    if let Some(v) = update.discord_end_reminder_mins {
      settings.discord_end_reminder_mins = v;
    }
    if let Some(v) = update.discord_start_reminder_message {
      settings.discord_start_reminder_message = v;
    }
    if let Some(v) = update.discord_end_reminder_message {
      settings.discord_end_reminder_message = v;
    }
    if let Some(v) = update.discord_auto_delete_start_reminder {
      settings.discord_auto_delete_start_reminder = v;
    }
    if let Some(v) = update.discord_auto_delete_end_reminder {
      settings.discord_auto_delete_end_reminder = v;
    }
    self.save(&settings).await
  }

  async fn update_discord_behavior(&self, update: DiscordBehaviorUpdate) -> anyhow::Result<()> {
    let mut settings = self.repo.get().await?;
    if let Some(v) = update.discord_self_link_enabled {
      settings.discord_self_link_enabled = v;
    }
    if let Some(v) = update.discord_name_sync_enabled {
      settings.discord_name_sync_enabled = v;
    }
    if let Some(v) = update.discord_overtime_dm_enabled {
      settings.discord_overtime_dm_enabled = v;
    }
    if let Some(v) = update.discord_overtime_dm_mins {
      settings.discord_overtime_dm_mins = v;
    }
    if let Some(v) = update.discord_overtime_dm_message {
      settings.discord_overtime_dm_message = v;
    }
    if let Some(v) = update.discord_auto_checkout_dm_enabled {
      settings.discord_auto_checkout_dm_enabled = v;
    }
    if let Some(v) = update.discord_auto_checkout_dm_message {
      settings.discord_auto_checkout_dm_message = v;
    }
    if let Some(v) = update.discord_checkout_enabled {
      settings.discord_checkout_enabled = v;
    }
    if let Some(v) = update.discord_rsvp_reactions_enabled {
      settings.discord_rsvp_reactions_enabled = v;
    }
    self.save(&settings).await
  }

  async fn upload_logo(&self, data: &[u8]) -> anyhow::Result<()> {
    self.logos.set(data).await?;
    Ok(())
  }

  async fn get_logo(&self) -> anyhow::Result<Option<Vec<u8>>> {
    self.logos.get().await
  }

  async fn purge_database(&self) -> anyhow::Result<()> {
    self.notifications.clear().await?;
    self.team_member_sessions.clear().await?;
    self.sessions.clear().await?;
    self.team_members.clear().await?;
    self.locations.clear().await?;
    self.users.clear().await?;
    self.secrets.clear().await?;
    self.repo.clear().await?;
    self.logos.clear().await?;
    self.session_rsvps.clear().await?;
    self.session_rsvp_messages.clear().await?;

    log::warn!("Database purged by admin");

    let admin = self.users.add(crate::db::DEFAULT_ADMIN_USERNAME, crate::db::DEFAULT_ADMIN_PASSWORD).await?;

    // `user_roles` cascade-deleted with the purged `users` row - the "admin" role itself is
    // untouched (roles/resources aren't user data), just needs re-linking to the new admin user id.
    let super_role_id = self.permissions.ensure_role("admin", true).await?;
    self.permissions.assign_role(admin.id, super_role_id).await?;

    Ok(())
  }

  async fn get_discord_roles(&self) -> anyhow::Result<Vec<DiscordRole>> {
    let settings = self.repo.get().await?;

    if settings.discord_bot_token.is_empty() {
      return Err(anyhow::anyhow!("Discord bot token is not configured"));
    }
    if settings.discord_guild_id.is_empty() {
      return Err(anyhow::anyhow!("Discord server ID is not configured"));
    }

    let guild_id: u64 = settings.discord_guild_id.parse().map_err(|_| anyhow::anyhow!("Invalid server ID"))?;
    let http = Http::new(&settings.discord_bot_token);
    let guild = serenity::all::GuildId::new(guild_id);

    let role_map = guild.roles(&http).await.map_err(|e| anyhow::anyhow!("Failed to fetch Discord roles: {e}"))?;

    let mut roles: Vec<DiscordRole> = role_map
      .into_values()
      .filter(|r| r.name != "@everyone")
      .map(|r| DiscordRole { id: r.id.to_string(), name: r.name })
      .collect();

    roles.sort_by_key(|r| r.name.to_lowercase());

    Ok(roles)
  }

  async fn import_discord_members(
    &self,
    role_id: &str,
    member_type: &str,
  ) -> anyhow::Result<ImportDiscordMembersResult> {
    let settings = self.repo.get().await?;

    if settings.discord_bot_token.is_empty() {
      return Err(anyhow::anyhow!("Discord bot token is not configured"));
    }
    if settings.discord_guild_id.is_empty() {
      return Err(anyhow::anyhow!("Discord server ID is not configured"));
    }

    let guild_id: u64 = settings.discord_guild_id.parse().map_err(|_| anyhow::anyhow!("Invalid server ID"))?;
    let role_id: u64 = role_id.parse().map_err(|_| anyhow::anyhow!("Invalid role ID"))?;

    let http = Http::new(&settings.discord_bot_token);
    let guild = serenity::all::GuildId::new(guild_id);
    let target_role = serenity::all::RoleId::new(role_id);

    let guild_members = guild
      .members(&http, Some(1000), None)
      .await
      .map_err(|e| anyhow::anyhow!("Failed to fetch Discord members: {e}"))?;

    let existing_members: Vec<TeamMember> = self.team_members.get_all().await?;

    let mut imported = 0;
    let mut linked = 0;
    let mut already_linked = 0;

    for guild_member in &guild_members {
      if !guild_member.roles.contains(&target_role) {
        continue;
      }

      let display_name = guild_member.display_name().to_string();
      let discord_id = guild_member.user.id.to_string();

      let existing = existing_members.iter().find(|m| m.discord_id.as_deref() == Some(discord_id.as_str()));
      if existing.is_some() {
        already_linked += 1;
        continue;
      }

      // Display-name matching is kept for *new* links only, and now records an
      // ID - so re-running the import re-links members whose old username-based
      // link was dropped by the 0003 migration. No separate backfill needed.
      let by_display_name = existing_members.iter().find(|m| {
        m.discord_id.as_ref().is_none_or(String::is_empty) && m.display_name.as_deref() == Some(display_name.as_str())
      });

      if let Some(member) = by_display_name {
        self
          .team_members
          .update(
            member.id,
            &member.first_name,
            &member.last_name,
            &member.member_type,
            member.display_name.as_deref(),
            member.mobile_number.as_deref(),
            Some(&discord_id),
            member.quick_pin.as_deref(),
          )
          .await?;
        linked += 1;
      } else {
        self.team_members.add("", "", member_type, Some(&display_name), None, Some(&discord_id), None).await?;
        imported += 1;
      }
    }

    Ok(ImportDiscordMembersResult { imported, linked, already_linked })
  }
}
