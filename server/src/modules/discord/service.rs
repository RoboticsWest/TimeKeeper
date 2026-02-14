use std::{future::Future, time::Duration};

use chrono::Utc;
use serenity::all::{ChannelId, GuildId, Member as GuildMember};
use serenity::http::Http;

use crate::core::time::{format_date, format_time, parse_tz};

/// Run an async future from within a sync context that's already on the tokio runtime.
/// Uses `block_in_place` to avoid the "cannot block inside a runtime" panic.
fn block_on<F: Future>(f: F) -> F::Output {
  tokio::task::block_in_place(|| tokio::runtime::Handle::current().block_on(f))
}

use crate::{
  core::scheduler::ScheduledService,
  generated::db::{Location, Notification, NotificationType, Session, Settings, TeamMember},
  modules::{
    location::LocationRepository,
    notification::NotificationRepository,
    session::{SessionRepository, helpers::get_past_end_sessions},
    settings::{
      DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_END_REMINDER_MESSAGE, DEFAULT_OVERTIME_DM_MESSAGE,
      DEFAULT_START_REMINDER_MESSAGE, SettingsRepository,
    },
    team_member::TeamMemberRepository,
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

    if !settings.discord_enabled || settings.discord_bot_token.is_empty() || settings.discord_channel_id.is_empty() {
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

    let tz = parse_tz(&settings.timezone);
    let sessions = Session::get_all()?;
    let locations = Location::get_all()?;
    let now_secs = Utc::now().timestamp();

    // --- Session Start/End Reminders ---
    for (id, session) in &sessions {
      if session.finished {
        continue;
      }

      let start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
      let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);
      let location = locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str());

      let date_str = format_date(start_secs, &tz);
      let start_time_str = format_time(start_secs, &tz);
      let end_time_str = format_time(end_secs, &tz);

      // Session starting soon reminder
      if start_reminder_secs > 0 {
        let time_until_start = start_secs - now_secs;
        if time_until_start > 0
          && time_until_start <= start_reminder_secs
          && !Notification::exists(NotificationType::SessionStartReminder, id, None)?
        {
          let mins = time_until_start / 60;
          let msg = start_msg_template
            .replace("{mins}", &mins.to_string())
            .replace("{location}", location)
            .replace("{date}", &date_str)
            .replace("{start_time}", &start_time_str)
            .replace("{end_time}", &end_time_str);

          if let Err(e) = block_on(async { channel.say(&http, &msg).await }) {
            log::error!("[DiscordNotificationService] Failed to send start reminder: {e}");
          } else {
            Notification::add(&Notification {
              notification_type: NotificationType::SessionStartReminder as i32,
              session_id: id.clone(),
              team_member_id: None,
              sent: true,
            })?;
          }
        }
      }

      // Session ending soon reminder
      if end_reminder_secs > 0 {
        let time_until_end = end_secs - now_secs;
        if time_until_end > 0
          && time_until_end <= end_reminder_secs
          && now_secs >= start_secs
          && !Notification::exists(NotificationType::SessionEndReminder, id, None)?
        {
          let mins = time_until_end / 60;
          let msg = end_msg_template
            .replace("{mins}", &mins.to_string())
            .replace("{location}", location)
            .replace("{date}", &date_str)
            .replace("{start_time}", &start_time_str)
            .replace("{end_time}", &end_time_str);

          if let Err(e) = block_on(async { channel.say(&http, &msg).await }) {
            log::error!("[DiscordNotificationService] Failed to send end reminder: {e}");
          } else {
            Notification::add(&Notification {
              notification_type: NotificationType::SessionEndReminder as i32,
              session_id: id.clone(),
              team_member_id: None,
              sent: true,
            })?;
          }
        }
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

    // Per-user DM notifications
    if (settings.discord_overtime_dm_enabled || settings.discord_auto_checkout_dm_enabled)
      && let Some(ref guild_members) = guild_members
    {
      let team_members = TeamMember::get_all()?;

      // --- Overtime DMs: members still checked in past session end + threshold ---
      if settings.discord_overtime_dm_enabled {
        let overtime_msg_template = if settings.discord_overtime_dm_message.is_empty() {
          DEFAULT_OVERTIME_DM_MESSAGE
        } else {
          &settings.discord_overtime_dm_message
        };
        let overtime_threshold_secs = settings.discord_overtime_dm_mins * 60;

        for pes in &get_past_end_sessions()? {
          if pes.checked_in.is_empty() || now_secs <= pes.end_secs + overtime_threshold_secs {
            continue;
          }

          let location = locations.get(&pes.session.location_id).map_or("Unknown", |l| l.location.as_str());
          let end_time_str = format_time(pes.end_secs, &tz);

          for (_, ms) in &pes.checked_in {
            if Notification::exists(NotificationType::Overtime, &pes.session_id, Some(&ms.team_member_id))? {
              continue;
            }

            let Some(member) = team_members.get(&ms.team_member_id) else { continue };
            let Some(mention) = Self::resolve_mention(guild_members, member) else { continue };
            let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

            let msg = overtime_msg_template
              .replace("{username}", &mention)
              .replace("{name}", member_name)
              .replace("{location}", location)
              .replace("{end_time}", &end_time_str);

            if Self::send_member_notification(&http, channel, &msg) {
              if let Err(e) = Notification::add(&Notification {
                notification_type: NotificationType::Overtime as i32,
                session_id: pes.session_id.clone(),
                team_member_id: Some(ms.team_member_id.clone()),
                sent: true,
              }) {
                log::error!(
                  "[DiscordNotificationService] Failed to record overtime notification for {}: {e}",
                  ms.team_member_id
                );
              }
            }
          }
        }
      }

      // --- Auto-checkout DMs: process queued notifications from SessionService ---
      if settings.discord_auto_checkout_dm_enabled {
        let auto_checkout_msg_template = if settings.discord_auto_checkout_dm_message.is_empty() {
          DEFAULT_AUTO_CHECKOUT_DM_MESSAGE
        } else {
          &settings.discord_auto_checkout_dm_message
        };

        let unsent = Notification::get_unsent()?;
        for (notif_id, notification) in unsent {
          if notification.notification_type != NotificationType::AutoCheckout as i32 {
            continue;
          }

          let Some(ref member_id) = notification.team_member_id else { continue };
          let Some(session) = sessions.get(&notification.session_id) else { continue };
          let Some(member) = team_members.get(member_id) else { continue };
          let Some(mention) = Self::resolve_mention(guild_members, member) else { continue };
          let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);
          let location = locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str());
          let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);
          let end_time_str = format_time(end_secs, &tz);

          let msg = auto_checkout_msg_template
            .replace("{username}", &mention)
            .replace("{name}", member_name)
            .replace("{location}", location)
            .replace("{end_time}", &end_time_str);

          if Self::send_member_notification(&http, channel, &msg) {
            let mut updated = notification.clone();
            updated.sent = true;
            if let Err(e) = Notification::update(&notif_id, &updated) {
              log::error!(
                "[DiscordNotificationService] Failed to mark auto-checkout notification as sent for {notif_id}: {e}"
              );
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
  /// Resolve a team member's Discord mention string (`<@USER_ID>`).
  /// Returns None if the member has no Discord username or isn't found in the guild.
  fn resolve_mention(guild_members: &[GuildMember], team_member: &TeamMember) -> Option<String> {
    let discord_username = team_member.discord_username.as_deref().filter(|u| !u.is_empty())?;
    let guild_member = guild_members.iter().find(|gm| gm.user.name == discord_username)?;
    Some(format!("<@{}>", guild_member.user.id))
  }

  /// Send a notification to the channel mentioning a specific team member.
  /// Returns `true` if the message was sent successfully, `false` otherwise.
  fn send_member_notification(http: &Http, channel: ChannelId, message: &str) -> bool {
    let result = block_on(async { channel.say(http, message).await });

    match result {
      Ok(_) => true,
      Err(e) => {
        log::error!("[DiscordNotificationService] Failed to send notification: {e}");
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
