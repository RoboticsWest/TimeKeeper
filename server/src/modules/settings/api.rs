use serenity::all::GuildId;
use serenity::all::RoleId;
use serenity::http::Http;
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::db::recreate_default_admin,
  generated::{
    api::{
      DiscordRole, GetDiscordRolesRequest, GetDiscordRolesResponse, GetSettingsRequest, GetSettingsResponse,
      ImportDiscordMembersRequest, ImportDiscordMembersResponse, PurgeDatabaseRequest, PurgeDatabaseResponse,
      UpdateSettingsRequest, UpdateSettingsResponse, settings_service_server::SettingsService,
    },
    common::Role,
    db::{Location, Notification, Secret, Session, Settings, TeamMember, TeamMemberSession, TeamMemberType, User},
  },
  modules::{
    location::LocationRepository, notification::NotificationRepository, secret::SecretRepository,
    session::SessionRepository, settings::SettingsRepository, team_member::TeamMemberRepository,
    team_member_session::TeamMemberSessionRepository, user::UserRepository,
  },
};

pub struct SettingsApi;

#[tonic::async_trait]
impl SettingsService for SettingsApi {
  async fn get_settings(&self, _request: Request<GetSettingsRequest>) -> Result<Response<GetSettingsResponse>, Status> {
    let settings = Settings::get().map_err(|e| Status::internal(format!("Failed to get settings: {}", e)))?;
    Ok(Response::new(GetSettingsResponse { settings: Some(settings) }))
  }

  async fn update_settings(
    &self,
    request: Request<UpdateSettingsRequest>,
  ) -> Result<Response<UpdateSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    let settings = Settings {
      next_session_threshold_secs: req.next_session_threshold_secs,
      discord_bot_token: req.discord_bot_token,
      discord_guild_id: req.discord_guild_id,
      discord_channel_id: req.discord_channel_id,
      discord_self_link_enabled: req.discord_self_link_enabled,
      discord_name_sync_enabled: req.discord_name_sync_enabled,
      discord_start_reminder_mins: req.discord_start_reminder_mins,
      discord_end_reminder_mins: req.discord_end_reminder_mins,
      discord_start_reminder_message: req.discord_start_reminder_message,
      discord_end_reminder_message: req.discord_end_reminder_message,
      discord_overtime_dm_enabled: req.discord_overtime_dm_enabled,
      discord_overtime_dm_mins: req.discord_overtime_dm_mins,
      discord_overtime_dm_message: req.discord_overtime_dm_message,
      discord_auto_checkout_dm_enabled: req.discord_auto_checkout_dm_enabled,
      discord_auto_checkout_dm_message: req.discord_auto_checkout_dm_message,
      discord_checkout_enabled: req.discord_checkout_enabled,
    };
    Settings::set(&settings).map_err(|e| Status::internal(format!("Failed to update settings: {}", e)))?;

    Ok(Response::new(UpdateSettingsResponse {}))
  }

  async fn purge_database(
    &self,
    request: Request<PurgeDatabaseRequest>,
  ) -> Result<Response<PurgeDatabaseResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    // Clear all data using repository methods so the event bus notifies clients
    Notification::clear().map_err(|e| Status::internal(format!("Failed to clear notification data: {}", e)))?;
    TeamMemberSession::clear()
      .map_err(|e| Status::internal(format!("Failed to clear team member session data: {}", e)))?;
    Session::clear().map_err(|e| Status::internal(format!("Failed to clear session data: {}", e)))?;
    TeamMember::clear().map_err(|e| Status::internal(format!("Failed to clear team member data: {}", e)))?;
    Location::clear().map_err(|e| Status::internal(format!("Failed to clear location data: {}", e)))?;
    User::clear().map_err(|e| Status::internal(format!("Failed to clear user data: {}", e)))?;
    Secret::clear().map_err(|e| Status::internal(format!("Failed to clear secret data: {}", e)))?;
    Settings::clear().map_err(|e| Status::internal(format!("Failed to clear settings data: {}", e)))?;

    log::warn!("Database purged by admin");

    // Recreate admin user with default password after clearing users
    recreate_default_admin().map_err(|e| Status::internal(format!("Failed to recreate admin user: {}", e)))?;

    Ok(Response::new(PurgeDatabaseResponse {}))
  }

  async fn get_discord_roles(
    &self,
    request: Request<GetDiscordRolesRequest>,
  ) -> Result<Response<GetDiscordRolesResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    let settings = Settings::get().map_err(|e| Status::internal(format!("Failed to get settings: {e}")))?;

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

    let settings = Settings::get().map_err(|e| Status::internal(format!("Failed to get settings: {e}")))?;

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

    let mut imported: i32 = 0;
    let mut linked: i32 = 0;
    let mut already_linked: i32 = 0;

    let existing_members =
      TeamMember::get_all().map_err(|e| Status::internal(format!("Failed to load team members: {e}")))?;

    for guild_member in &guild_members {
      if !guild_member.roles.contains(&target_role) {
        continue;
      }

      let display_name = guild_member.display_name().to_string();
      let discord_username = guild_member.user.name.clone();

      // Check if any existing member is already linked to this Discord username
      let existing =
        existing_members.iter().find(|(_, m)| m.discord_username.as_ref().is_some_and(|u| u == &discord_username));

      if existing.is_some() {
        already_linked += 1;
        continue;
      }

      // Check if a member with this display name exists but isn't linked
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
