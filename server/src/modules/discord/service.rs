use std::{collections::HashSet, future::Future, time::Duration};

use chrono::Utc;
use serenity::all::{ChannelId, GuildId};
use serenity::http::Http;

/// Run an async future from within a sync context that's already on the tokio runtime.
/// Uses `block_in_place` to avoid the "cannot block inside a runtime" panic.
fn block_on<F: Future>(f: F) -> F::Output {
  tokio::task::block_in_place(|| tokio::runtime::Handle::current().block_on(f))
}

use crate::{
  core::scheduler::ScheduledService,
  generated::db::{Location, Session, Settings, TeamMember},
  modules::{
    location::LocationRepository, session::SessionRepository, settings::SettingsRepository,
    team_member::TeamMemberRepository,
  },
};

#[derive(Default)]
pub struct DiscordNotificationService {
  reminded_start: HashSet<String>,
  reminded_end: HashSet<String>,
}

impl DiscordNotificationService {
  pub fn new() -> Self {
    Self::default()
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

    let reminder_secs = settings.discord_reminder_mins * 60;
    let channel_id: u64 =
      settings.discord_channel_id.parse().map_err(|e| anyhow::anyhow!("Invalid channel ID: {e}"))?;

    let http = Http::new(&settings.discord_bot_token);
    let channel = ChannelId::new(channel_id);

    let sessions = Session::get_all()?;
    let locations = Location::get_all()?;
    let now_secs = Utc::now().timestamp();

    // Clean up stale entries for sessions that no longer exist
    self.reminded_start.retain(|id| sessions.contains_key(id));
    self.reminded_end.retain(|id| sessions.contains_key(id));

    let mut messages: Vec<String> = Vec::new();

    for (id, session) in &sessions {
      if session.finished {
        continue;
      }

      let start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
      let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);
      let location = locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str());

      // Session starting soon reminder
      let time_until_start = start_secs - now_secs;
      if time_until_start > 0 && time_until_start <= reminder_secs && !self.reminded_start.contains(id) {
        let mins = time_until_start / 60;
        messages.push(format!("@here Session starting in ~{mins} minutes @ {location}!"));
        self.reminded_start.insert(id.clone());
      }

      // Session ending soon reminder (fires within reminder window before end time)
      let time_until_end = end_secs - now_secs;
      if time_until_end > 0
        && time_until_end <= reminder_secs
        && now_secs >= start_secs
        && !self.reminded_end.contains(id)
      {
        let mins = time_until_end / 60;
        messages
          .push(format!("@here Session at {location} is ending in ~{mins} minutes \u{2014} don't forget to sign out!"));
        self.reminded_end.insert(id.clone());
      }
    }

    if !messages.is_empty() {
      for msg in messages {
        let http_ref = &http;
        if let Err(e) = block_on(async { channel.say(http_ref, &msg).await }) {
          log::error!("[DiscordNotificationService] Failed to send message: {e}");
        }
      }
    }

    // Name sync: update team member names from Discord server nicknames
    if settings.discord_name_sync_enabled
      && !settings.discord_guild_id.is_empty()
      && let Err(e) = Self::sync_names(&http, &settings)
    {
      log::error!("[DiscordNotificationService] Name sync failed: {e}");
    }

    Ok(())
  }
}

impl DiscordNotificationService {
  fn sync_names(http: &Http, settings: &Settings) -> anyhow::Result<()> {
    let guild_id: u64 = settings.discord_guild_id.parse()?;
    let guild = GuildId::new(guild_id);

    let guild_members = block_on(async { guild.members(http, Some(1000), None).await })?;

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
