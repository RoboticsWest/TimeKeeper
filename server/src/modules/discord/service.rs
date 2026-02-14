use std::{future::Future, time::Duration};

use chrono::{TimeZone, Utc};
use serenity::all::{ChannelId, GuildId, Member as GuildMember};
use serenity::http::Http;

/// Run an async future from within a sync context that's already on the tokio runtime.
/// Uses `block_in_place` to avoid the "cannot block inside a runtime" panic.
fn block_on<F: Future>(f: F) -> F::Output {
  tokio::task::block_in_place(|| tokio::runtime::Handle::current().block_on(f))
}

use crate::{
  core::scheduler::ScheduledService,
  generated::db::{Location, Session, Settings, TeamMember, TeamMemberSession},
  modules::{
    location::LocationRepository,
    session::{
      SessionRepository,
      helpers::{get_past_end_sessions, is_auto_checkout_imminent},
    },
    settings::{
      DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_END_REMINDER_MESSAGE, DEFAULT_OVERTIME_DM_MESSAGE,
      DEFAULT_START_REMINDER_MESSAGE, SettingsRepository,
    },
    team_member::TeamMemberRepository,
    team_member_session::TeamMemberSessionRepository,
  },
};

#[derive(Default)]
pub struct DiscordNotificationService;

impl DiscordNotificationService {
  pub fn new() -> Self {
    Self
  }
}

impl ScheduledService for DiscordNotificationService {
  fn interval(&self) -> Duration {
    Duration::from_secs(60)
  }

  fn name(&self) -> &'static str {
    "DiscordNotificationService"
  }

  fn execute(&mut self) -> anyhow::Result<()> {
    let settings = Settings::get()?;

    if settings.discord_bot_token.is_empty() || settings.discord_channel_id.is_empty() {
      return Ok(());
    }

    let start_reminder_secs = settings.discord_start_reminder_mins * 60;
    let end_reminder_secs = settings.discord_end_reminder_mins * 60;
    let channel_id: u64 =
      settings.discord_channel_id.parse().map_err(|e| anyhow::anyhow!("Invalid channel ID: {e}"))?;

    let start_msg_template = if settings.discord_start_reminder_message.is_empty() {
      DEFAULT_START_REMINDER_MESSAGE
    } else {
      &settings.discord_start_reminder_message
    };
    let end_msg_template = if settings.discord_end_reminder_message.is_empty() {
      DEFAULT_END_REMINDER_MESSAGE
    } else {
      &settings.discord_end_reminder_message
    };

    let http = Http::new(&settings.discord_bot_token);
    let channel = ChannelId::new(channel_id);

    let sessions = Session::get_all()?;
    let locations = Location::get_all()?;
    let now_secs = Utc::now().timestamp();

    let mut messages: Vec<String> = Vec::new();
    let mut sessions_to_update: Vec<(String, Session)> = Vec::new();

    for (id, session) in &sessions {
      if session.finished {
        continue;
      }

      let start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
      let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);
      let location = locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str());

      let mut updated = false;
      let mut session = session.clone();

      let start_dt = Utc.timestamp_opt(start_secs, 0).single();
      let end_dt = Utc.timestamp_opt(end_secs, 0).single();
      let date_str = start_dt.map_or("Unknown".to_string(), |dt| dt.format("%B %-d").to_string());
      let start_time_str = start_dt.map_or("Unknown".to_string(), |dt| dt.format("%-I:%M%p").to_string());
      let end_time_str = end_dt.map_or("Unknown".to_string(), |dt| dt.format("%-I:%M%p").to_string());

      // Session starting soon reminder
      if start_reminder_secs > 0 && !session.start_reminder_sent {
        let time_until_start = start_secs - now_secs;
        if time_until_start > 0 && time_until_start <= start_reminder_secs {
          let mins = time_until_start / 60;
          messages.push(
            start_msg_template
              .replace("{mins}", &mins.to_string())
              .replace("{location}", location)
              .replace("{date}", &date_str)
              .replace("{start_time}", &start_time_str)
              .replace("{end_time}", &end_time_str),
          );
          session.start_reminder_sent = true;
          updated = true;
        }
      }

      // Session ending soon reminder
      if end_reminder_secs > 0 && !session.end_reminder_sent {
        let time_until_end = end_secs - now_secs;
        if time_until_end > 0 && time_until_end <= end_reminder_secs && now_secs >= start_secs {
          let mins = time_until_end / 60;
          messages.push(
            end_msg_template
              .replace("{mins}", &mins.to_string())
              .replace("{location}", location)
              .replace("{date}", &date_str)
              .replace("{start_time}", &start_time_str)
              .replace("{end_time}", &end_time_str),
          );
          session.end_reminder_sent = true;
          updated = true;
        }
      }

      if updated {
        sessions_to_update.push((id.clone(), session));
      }
    }

    // Send messages first, then persist the flags
    if !messages.is_empty() {
      for msg in &messages {
        let http_ref = &http;
        if let Err(e) = block_on(async { channel.say(http_ref, msg).await }) {
          log::error!("[DiscordNotificationService] Failed to send message: {e}");
        }
      }
    }

    // Persist reminder flags to the database so they survive restarts
    for (id, session) in sessions_to_update {
      if let Err(e) = Session::update(&id, &session) {
        log::error!("[DiscordNotificationService] Failed to persist reminder state for session {id}: {e}");
      }
    }

    // Fetch guild members once for DM notifications + name sync
    let guild_members = if settings.discord_guild_id.is_empty() {
      None
    } else {
      let guild_id: u64 = settings.discord_guild_id.parse().map_err(|e| anyhow::anyhow!("Invalid guild ID: {e}"))?;
      let guild = GuildId::new(guild_id);
      match block_on(async { guild.members(&http, Some(1000), None).await }) {
        Ok(members) => Some(members),
        Err(e) => {
          log::error!("[DiscordNotificationService] Failed to fetch guild members: {e}");
          None
        }
      }
    };

    // Per-user DM notifications (overtime + auto-checkout warnings)
    if (settings.discord_overtime_dm_enabled || settings.discord_auto_checkout_dm_enabled)
      && let Some(ref guild_members) = guild_members
    {
      let team_members = TeamMember::get_all()?;
      let past_end_sessions = get_past_end_sessions()?;

      let overtime_msg_template = if settings.discord_overtime_dm_message.is_empty() {
        DEFAULT_OVERTIME_DM_MESSAGE
      } else {
        &settings.discord_overtime_dm_message
      };
      let auto_checkout_msg_template = if settings.discord_auto_checkout_dm_message.is_empty() {
        DEFAULT_AUTO_CHECKOUT_DM_MESSAGE
      } else {
        &settings.discord_auto_checkout_dm_message
      };

      for pes in &past_end_sessions {
        if pes.checked_in.is_empty() {
          continue;
        }

        let location = locations.get(&pes.session.location_id).map_or("Unknown", |l| l.location.as_str());
        let end_dt = Utc.timestamp_opt(pes.end_secs, 0).single();
        let end_time_str = end_dt.map_or("Unknown".to_string(), |dt| dt.format("%-I:%M%p").to_string());

        // --- Overtime notification: configurable minutes after session end ---
        if settings.discord_overtime_dm_enabled {
          let overtime_threshold_secs = settings.discord_overtime_dm_mins * 60;
          if now_secs > pes.end_secs + overtime_threshold_secs {
            for (ms_id, ms) in &pes.checked_in {
              if ms.overtime_notified {
                continue;
              }

              let Some(member) = team_members.get(&ms.team_member_id) else { continue };
              let username = member.discord_username.as_deref().unwrap_or("");
              let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

              let msg = overtime_msg_template
                .replace("{username}", username)
                .replace("{name}", member_name)
                .replace("{location}", location)
                .replace("{end_time}", &end_time_str);

              if Self::send_dm_to_member(&http, guild_members, member, &msg) {
                let mut ms = ms.clone();
                ms.overtime_notified = true;
                if let Err(e) = TeamMemberSession::update(ms_id, &ms) {
                  log::error!("[DiscordNotificationService] Failed to persist overtime_notified for {ms_id}: {e}");
                }
              }
            }
          }
        }

        // --- Auto-checkout warning: detection via shared helper, timing owned by Discord ---
        if settings.discord_auto_checkout_dm_enabled
          && is_auto_checkout_imminent(pes.next_start_secs, now_secs, settings.discord_auto_checkout_dm_mins * 60)
        {
          for (ms_id, ms) in &pes.checked_in {
            if ms.auto_checkout_notified {
              continue;
            }

            let Some(member) = team_members.get(&ms.team_member_id) else { continue };
            let username = member.discord_username.as_deref().unwrap_or("");
            let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

            let msg = auto_checkout_msg_template
              .replace("{username}", username)
              .replace("{name}", member_name)
              .replace("{location}", location)
              .replace("{end_time}", &end_time_str);

            if Self::send_dm_to_member(&http, guild_members, member, &msg) {
              let mut ms = ms.clone();
              ms.auto_checkout_notified = true;
              if let Err(e) = TeamMemberSession::update(ms_id, &ms) {
                log::error!("[DiscordNotificationService] Failed to persist auto_checkout_notified for {ms_id}: {e}");
              }
            }
          }
        }
      }
    }

    // Name sync: update team member names from Discord server nicknames
    if settings.discord_name_sync_enabled
      && let Some(ref guild_members) = guild_members
      && let Err(e) = Self::sync_names(guild_members)
    {
      log::error!("[DiscordNotificationService] Name sync failed: {e}");
    }

    Ok(())
  }
}

impl DiscordNotificationService {
  /// Send a DM to a team member by finding their Discord user in the guild.
  /// Returns `true` if the DM was sent successfully, `false` otherwise.
  fn send_dm_to_member(http: &Http, guild_members: &[GuildMember], team_member: &TeamMember, message: &str) -> bool {
    let Some(discord_username) = team_member.discord_username.as_deref() else {
      return false;
    };
    if discord_username.is_empty() {
      return false;
    }

    let Some(guild_member) = guild_members.iter().find(|gm| gm.user.name == discord_username) else {
      log::debug!("[DiscordNotificationService] Discord user '{discord_username}' not found in guild");
      return false;
    };

    let result = block_on(async {
      let dm_channel = guild_member.user.create_dm_channel(http).await?;
      dm_channel.say(http, message).await?;
      Ok::<_, serenity::Error>(())
    });

    match result {
      Ok(()) => {
        log::info!("[DiscordNotificationService] Sent DM to '{discord_username}'");
        true
      }
      Err(e) => {
        log::error!("[DiscordNotificationService] Failed to send DM to '{discord_username}': {e}");
        false
      }
    }
  }

  fn sync_names(guild_members: &[GuildMember]) -> anyhow::Result<()> {
    let team_members = TeamMember::get_all()?;

    for (id, mut member) in team_members {
      let Some(discord_username) = member.discord_username.as_deref() else { continue };
      if discord_username.is_empty() {
        continue;
      }

      // Find the matching Discord guild member by username
      let Some(guild_member) = guild_members.iter().find(|gm| gm.user.name == discord_username) else {
        continue;
      };

      // display_name() returns: server nickname > global display name > username
      let new_display_name = guild_member.display_name().to_string();
      let current = member.display_name.as_deref().unwrap_or("");

      if current != new_display_name {
        log::info!(
          "[DiscordNotificationService] Syncing display name for {}: '{}' -> '{new_display_name}'",
          discord_username,
          current,
        );
        member.display_name = Some(new_display_name);
        TeamMember::update(&id, &member)?;
      }
    }

    Ok(())
  }
}
