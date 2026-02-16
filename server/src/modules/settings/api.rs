use serenity::all::{GuildId, RoleId};
use serenity::http::Http;
use tonic::{Request, Response, Result, Status};

use crate::generated::api::settings_service_server::SettingsService;
use crate::modules::location::LocationRepository;
use crate::modules::notification::NotificationRepository;
use crate::modules::secret::SecretRepository;
use crate::modules::session::SessionRepository;
use crate::modules::session_rsvp::{SessionRsvpMessageRepository, SessionRsvpRepository};
use crate::modules::settings::{LogoRepository, SettingsRepository};
use crate::modules::team_member::TeamMemberRepository;
use crate::modules::team_member_session::TeamMemberSessionRepository;
use crate::modules::user::UserRepository;
use crate::{
  auth::auth_helpers::require_permission,
  core::db::recreate_default_admin,
  generated::{
    api::{
      DiscordRole, GetDiscordRolesRequest, GetDiscordRolesResponse, GetLogoRequest, GetLogoResponse,
      GetSettingsRequest, GetSettingsResponse, ImportDiscordMembersRequest, ImportDiscordMembersResponse,
      PurgeDatabaseRequest, PurgeDatabaseResponse, UpdateBrandingSettingsRequest, UpdateBrandingSettingsResponse,
      UpdateDiscordBehaviorSettingsRequest, UpdateDiscordBehaviorSettingsResponse, UpdateDiscordCoreSettingsRequest,
      UpdateDiscordCoreSettingsResponse, UpdateDiscordReminderSettingsRequest, UpdateDiscordReminderSettingsResponse,
      UpdateGeneralSettingsRequest, UpdateGeneralSettingsResponse, UpdateLeaderboardSettingsRequest,
      UpdateLeaderboardSettingsResponse, UploadLogoRequest, UploadLogoResponse,
    },
    common::Role,
    db::{
      Location, Logo, Notification, Secret, Session, SessionRsvp, SessionRsvpMessage, Settings, TeamMember,
      TeamMemberSession, TeamMemberType, User,
    },
  },
};

pub struct SettingsApi;

impl SettingsApi {
  fn load_settings() -> Result<Settings, Status> {
    Settings::get().map_err(|e| Status::internal(format!("Failed to load settings: {e}")))
  }

  fn save_settings(settings: &Settings) -> Result<(), Status> {
    Settings::set(settings).map_err(|e| Status::internal(format!("Failed to save settings: {e}")))
  }
}

#[tonic::async_trait]
impl SettingsService for SettingsApi {
  // ============================================================
  // GET SETTINGS
  // ============================================================

  async fn get_settings(&self, _request: Request<GetSettingsRequest>) -> Result<Response<GetSettingsResponse>, Status> {
    let settings = Self::load_settings()?;
    Ok(Response::new(GetSettingsResponse { settings: Some(settings) }))
  }

  // ============================================================
  // GENERAL SETTINGS (PATCH)
  // ============================================================

  async fn update_general_settings(
    &self,
    request: Request<UpdateGeneralSettingsRequest>,
  ) -> Result<Response<UpdateGeneralSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.next_session_threshold_secs {
      settings.next_session_threshold_secs = v;
    }

    if let Some(v) = req.timezone {
      settings.timezone = v;
    }

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateGeneralSettingsResponse {}))
  }

  // ============================================================
  // BRANDING SETTINGS (PATCH)
  // ============================================================

  async fn update_branding_settings(
    &self,
    request: Request<UpdateBrandingSettingsRequest>,
  ) -> Result<Response<UpdateBrandingSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.primary_color {
      settings.primary_color = v;
    }

    if let Some(v) = req.secondary_color {
      settings.secondary_color = v;
    }

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateBrandingSettingsResponse {}))
  }

  // ============================================================
  // LEADERBOARD SETTINGS (PATCH)
  // ============================================================

  async fn update_leaderboard_settings(
    &self,
    request: Request<UpdateLeaderboardSettingsRequest>,
  ) -> Result<Response<UpdateLeaderboardSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.leaderboard_show_overtime {
      settings.leaderboard_show_overtime = v;
    }

    settings.leaderboard_member_types = req.leaderboard_member_types;

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateLeaderboardSettingsResponse {}))
  }

  // ============================================================
  // DISCORD CORE SETTINGS (PATCH)
  // ============================================================

  async fn update_discord_core_settings(
    &self,
    request: Request<UpdateDiscordCoreSettingsRequest>,
  ) -> Result<Response<UpdateDiscordCoreSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.discord_enabled {
      settings.discord_enabled = v;
    }

    if let Some(v) = req.discord_bot_token {
      settings.discord_bot_token = v;
    }

    if let Some(v) = req.discord_guild_id {
      settings.discord_guild_id = v;
    }

    if let Some(v) = req.discord_announcement_channel_id {
      settings.discord_announcement_channel_id = v;
    }

    if let Some(v) = req.discord_notification_channel_id {
      settings.discord_notification_channel_id = v;
    }

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateDiscordCoreSettingsResponse {}))
  }

  // ============================================================
  // DISCORD REMINDER SETTINGS (PATCH)
  // ============================================================

  async fn update_discord_reminder_settings(
    &self,
    request: Request<UpdateDiscordReminderSettingsRequest>,
  ) -> Result<Response<UpdateDiscordReminderSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.discord_start_reminder_mins {
      settings.discord_start_reminder_mins = v;
    }

    if let Some(v) = req.discord_end_reminder_mins {
      settings.discord_end_reminder_mins = v;
    }

    if let Some(v) = req.discord_start_reminder_message {
      settings.discord_start_reminder_message = v;
    }

    if let Some(v) = req.discord_end_reminder_message {
      settings.discord_end_reminder_message = v;
    }

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateDiscordReminderSettingsResponse {}))
  }

  // ============================================================
  // DISCORD BEHAVIOR SETTINGS (PATCH)
  // ============================================================

  async fn update_discord_behavior_settings(
    &self,
    request: Request<UpdateDiscordBehaviorSettingsRequest>,
  ) -> Result<Response<UpdateDiscordBehaviorSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();
    let mut settings = Self::load_settings()?;

    if let Some(v) = req.discord_self_link_enabled {
      settings.discord_self_link_enabled = v;
    }

    if let Some(v) = req.discord_name_sync_enabled {
      settings.discord_name_sync_enabled = v;
    }

    if let Some(v) = req.discord_overtime_dm_enabled {
      settings.discord_overtime_dm_enabled = v;
    }

    if let Some(v) = req.discord_overtime_dm_mins {
      settings.discord_overtime_dm_mins = v;
    }

    if let Some(v) = req.discord_overtime_dm_message {
      settings.discord_overtime_dm_message = v;
    }

    if let Some(v) = req.discord_auto_checkout_dm_enabled {
      settings.discord_auto_checkout_dm_enabled = v;
    }

    if let Some(v) = req.discord_auto_checkout_dm_message {
      settings.discord_auto_checkout_dm_message = v;
    }

    if let Some(v) = req.discord_checkout_enabled {
      settings.discord_checkout_enabled = v;
    }

    if let Some(v) = req.discord_rsvp_reactions_enabled {
      settings.discord_rsvp_reactions_enabled = v;
    }

    Self::save_settings(&settings)?;
    Ok(Response::new(UpdateDiscordBehaviorSettingsResponse {}))
  }

  // ============================================================
  // LOGO
  // ============================================================

  async fn upload_logo(&self, request: Request<UploadLogoRequest>) -> Result<Response<UploadLogoResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    Logo::set(&req.logo).map_err(|e| Status::internal(format!("Failed to upload logo: {e}")))?;

    Ok(Response::new(UploadLogoResponse {}))
  }

  async fn get_logo(&self, _request: Request<GetLogoRequest>) -> Result<Response<GetLogoResponse>, Status> {
    let logo = Logo::get().map_err(|e| Status::internal(format!("Failed to get logo: {e}")))?;

    Ok(Response::new(GetLogoResponse { logo: logo.unwrap_or_default() }))
  }

  // ============================================================
  // PURGE DATABASE
  // ============================================================

  async fn purge_database(
    &self,
    request: Request<PurgeDatabaseRequest>,
  ) -> Result<Response<PurgeDatabaseResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    Notification::clear().map_err(|e| Status::internal(format!("Failed to clear notification data: {e}")))?;
    TeamMemberSession::clear()
      .map_err(|e| Status::internal(format!("Failed to clear team member session data: {e}")))?;
    Session::clear().map_err(|e| Status::internal(format!("Failed to clear session data: {e}")))?;
    TeamMember::clear().map_err(|e| Status::internal(format!("Failed to clear team member data: {e}")))?;
    Location::clear().map_err(|e| Status::internal(format!("Failed to clear location data: {e}")))?;
    User::clear().map_err(|e| Status::internal(format!("Failed to clear user data: {e}")))?;
    Secret::clear().map_err(|e| Status::internal(format!("Failed to clear secret data: {e}")))?;
    Settings::clear().map_err(|e| Status::internal(format!("Failed to clear settings data: {e}")))?;
    Logo::clear().map_err(|e| Status::internal(format!("Failed to clear logo data: {e}")))?;
    SessionRsvp::clear().map_err(|e| Status::internal(format!("Failed to clear session RSVP data: {e}")))?;
    SessionRsvpMessage::clear()
      .map_err(|e| Status::internal(format!("Failed to clear session RSVP message data: {e}")))?;

    log::warn!("Database purged by admin");

    recreate_default_admin().map_err(|e| Status::internal(format!("Failed to recreate admin user: {e}")))?;

    Ok(Response::new(PurgeDatabaseResponse {}))
  }

  // ============================================================
  // DISCORD ROLES
  // ============================================================

  async fn get_discord_roles(
    &self,
    request: Request<GetDiscordRolesRequest>,
  ) -> Result<Response<GetDiscordRolesResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    let settings = Self::load_settings()?;

    if settings.discord_bot_token.is_empty() {
      return Err(Status::failed_precondition("Discord bot token is not configured"));
    }

    if settings.discord_guild_id.is_empty() {
      return Err(Status::failed_precondition("Discord server ID is not configured"));
    }

    let guild_id: u64 = settings.discord_guild_id.parse().map_err(|_| Status::invalid_argument("Invalid server ID"))?;

    let http = Http::new(&settings.discord_bot_token);
    let guild = GuildId::new(guild_id);

    let role_map =
      guild.roles(&http).await.map_err(|e| Status::internal(format!("Failed to fetch Discord roles: {e}")))?;

    let mut roles: Vec<DiscordRole> = role_map
      .into_values()
      .filter(|r| r.name != "@everyone")
      .map(|r| DiscordRole { id: r.id.to_string(), name: r.name })
      .collect();

    roles.sort_by(|a, b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));

    Ok(Response::new(GetDiscordRolesResponse { roles }))
  }

  // ============================================================
  // IMPORT DISCORD MEMBERS
  // ============================================================

  async fn import_discord_members(
    &self,
    request: Request<ImportDiscordMembersRequest>,
  ) -> Result<Response<ImportDiscordMembersResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    if req.role_id.is_empty() {
      return Err(Status::invalid_argument("Role ID is required"));
    }

    let member_type =
      TeamMemberType::try_from(req.member_type).map_err(|_| Status::invalid_argument("Invalid member type"))?;

    let settings = Self::load_settings()?;

    if settings.discord_bot_token.is_empty() {
      return Err(Status::failed_precondition("Discord bot token is not configured"));
    }

    if settings.discord_guild_id.is_empty() {
      return Err(Status::failed_precondition("Discord server ID is not configured"));
    }

    let guild_id: u64 = settings.discord_guild_id.parse().map_err(|_| Status::invalid_argument("Invalid server ID"))?;

    let role_id: u64 = req.role_id.parse().map_err(|_| Status::invalid_argument("Invalid role ID"))?;

    let http = Http::new(&settings.discord_bot_token);
    let guild = GuildId::new(guild_id);
    let target_role = RoleId::new(role_id);

    let guild_members = guild
      .members(&http, Some(1000), None)
      .await
      .map_err(|e| Status::internal(format!("Failed to fetch Discord members: {e}")))?;

    let existing_members =
      TeamMember::get_all().map_err(|e| Status::internal(format!("Failed to load team members: {e}")))?;

    let mut imported = 0;
    let mut linked = 0;
    let mut already_linked = 0;

    for guild_member in &guild_members {
      if !guild_member.roles.contains(&target_role) {
        continue;
      }

      let display_name = guild_member.display_name().to_string();
      let discord_username = guild_member.user.name.clone();

      let existing =
        existing_members.iter().find(|(_, m)| m.discord_username.as_ref().is_some_and(|u| u == &discord_username));

      if existing.is_some() {
        already_linked += 1;
        continue;
      }

      let by_display_name = existing_members.iter().find(|(_, m)| {
        m.discord_username.as_ref().is_none_or(String::is_empty)
          && m.display_name.as_ref().is_some_and(|dn| dn == &display_name)
      });

      if let Some((id, member)) = by_display_name {
        let mut updated = member.clone();
        updated.discord_username = Some(discord_username);
        TeamMember::update(id, &updated).map_err(|e| Status::internal(format!("Failed to link member: {e}")))?;
        linked += 1;
      } else {
        let new_member = TeamMember {
          first_name: String::new(),
          last_name: String::new(),
          member_type: member_type as i32,
          display_name: Some(display_name),
          mobile_number: None,
          discord_username: Some(discord_username),
        };

        TeamMember::add(&new_member).map_err(|e| Status::internal(format!("Failed to create member: {e}")))?;

        imported += 1;
      }
    }

    Ok(Response::new(ImportDiscordMembersResponse { imported, linked, already_linked }))
  }
}
