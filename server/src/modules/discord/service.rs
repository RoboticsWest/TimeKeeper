use std::{future::Future, time::Duration};

use chrono::{FixedOffset, Utc};
use serenity::all::{ChannelId, GuildId, Member as GuildMember};
use serenity::http::Http;

use crate::core::time::parse_tz;

/// Run an async future from within a sync context on the tokio runtime.
fn block_on<F: Future>(f: F) -> F::Output {
  tokio::task::block_in_place(|| tokio::runtime::Handle::current().block_on(f))
}

use serenity::model::channel::ReactionType;

use crate::{
  core::scheduler::ScheduledService,
  generated::db::{Location, Notification, NotificationType, Session, SessionRsvpMessage, Settings, TeamMember},
  modules::{
    location::LocationRepository,
    notification::NotificationRepository,
    session::{SessionRepository, helpers::get_past_end_sessions},
    session_rsvp::SessionRsvpMessageRepository,
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

  /// Generic helper to replace placeholders in templates
  fn replace_placeholders(
    template: &str,
    location: &str,
    start_secs: i64,
    end_secs: i64,
    tz: FixedOffset,
    mins: Option<i64>,
  ) -> String {
    let date_str = crate::core::time::format_date(start_secs, tz);
    let start_date_str = date_str.clone();
    let end_date_str = crate::core::time::format_date(end_secs, tz);
    let start_time_str = crate::core::time::format_time(start_secs, tz);
    let end_time_str = crate::core::time::format_time(end_secs, tz);

    let start_timestamp = format!("<t:{}:F>", start_secs);
    let end_timestamp = format!("<t:{}:F>", end_secs);

    let mut msg = template
      .replace("{location}", location)
      .replace("{date}", &date_str)
      .replace("{start_date}", &start_date_str)
      .replace("{end_date}", &end_date_str)
      .replace("{start_time}", &start_time_str)
      .replace("{end_time}", &end_time_str)
      .replace("{start_date_time}", &start_timestamp)
      .replace("{end_date_time}", &end_timestamp);

    if let Some(m) = mins {
      msg = msg.replace("{mins}", &m.to_string());
    }

    msg
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

    if !settings.discord_enabled
      || settings.discord_bot_token.is_empty()
      || settings.discord_announcement_channel_id.is_empty()
      || settings.discord_notification_channel_id.is_empty()
    {
      return Ok(());
    }

    let start_reminder_secs = settings.discord_start_reminder_mins * 60;
    let end_reminder_secs = settings.discord_end_reminder_mins * 60;
    let announcement_channel_id: u64 = settings
      .discord_announcement_channel_id
      .parse()
      .map_err(|e| anyhow::anyhow!("Invalid announcement channel ID: {e}"))?;
    let notification_channel_id: u64 = settings
      .discord_notification_channel_id
      .parse()
      .map_err(|e| anyhow::anyhow!("Invalid notification channel ID: {e}"))?;

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
    let announcement_channel = ChannelId::new(announcement_channel_id);
    let notification_channel = ChannelId::new(notification_channel_id);

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

      // Session starting soon reminder
      if start_reminder_secs > 0 {
        let time_until_start = start_secs - now_secs;
        if time_until_start > 0
          && time_until_start <= start_reminder_secs
          && !Notification::exists(NotificationType::SessionStartReminder, id, None)?
        {
          let mins = time_until_start / 60;
          let msg = DiscordNotificationService::replace_placeholders(
            start_msg_template,
            location,
            start_secs,
            end_secs,
            tz,
            Some(mins),
          );

          match block_on(async { announcement_channel.say(&http, &msg).await }) {
            Ok(sent_msg) => {
              if settings.discord_rsvp_reactions_enabled {
                let _ = block_on(async { sent_msg.react(&http, ReactionType::Unicode("👍".to_string())).await });
                let _ = block_on(async { sent_msg.react(&http, ReactionType::Unicode("👎".to_string())).await });

                if let Err(e) = SessionRsvpMessage::set(&sent_msg.id.to_string(), id) {
                  log::error!("[DiscordNotificationService] Failed to store RSVP message mapping: {e}");
                }
              }

              Notification::add(&Notification {
                notification_type: NotificationType::SessionStartReminder as i32,
                session_id: id.clone(),
                team_member_id: None,
                sent: true,
              })?;
            }
            Err(e) => {
              log::error!("[DiscordNotificationService] Failed to send start reminder: {e}");
            }
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
          let msg = DiscordNotificationService::replace_placeholders(
            end_msg_template,
            location,
            start_secs,
            end_secs,
            tz,
            Some(mins),
          );

          if let Err(e) = block_on(async { announcement_channel.say(&http, &msg).await }) {
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

    // --- Fetch guild members once ---
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

    // --- Per-user DM notifications ---
    if (settings.discord_overtime_dm_enabled || settings.discord_auto_checkout_dm_enabled)
      && let Some(ref guild_members) = guild_members
    {
      let team_members = TeamMember::get_all()?;

      // Overtime DMs
      if settings.discord_overtime_dm_enabled {
        let overtime_template = if settings.discord_overtime_dm_message.is_empty() {
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

          for (_, ms) in &pes.checked_in {
            if Notification::exists(NotificationType::Overtime, &pes.session_id, Some(&ms.team_member_id))? {
              continue;
            }

            let Some(member) = team_members.get(&ms.team_member_id) else { continue };
            let Some(mention) = Self::resolve_mention(guild_members, member) else { continue };
            let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

            let msg = DiscordNotificationService::replace_placeholders(
              overtime_template,
              location,
              pes.start_secs,
              pes.end_secs,
              tz,
              None,
            )
            .replace("{username}", &mention)
            .replace("{name}", member_name);

            if Self::send_member_notification(&http, notification_channel, &msg)
              && let Err(e) = Notification::add(&Notification {
                notification_type: NotificationType::Overtime as i32,
                session_id: pes.session_id.clone(),
                team_member_id: Some(ms.team_member_id.clone()),
                sent: true,
              })
            {
              log::error!(
                "[DiscordNotificationService] Failed to record overtime notification for {}: {e}",
                ms.team_member_id
              );
            }
          }
        }
      }

      // Auto-checkout DMs
      if settings.discord_auto_checkout_dm_enabled {
        let auto_template = if settings.discord_auto_checkout_dm_message.is_empty() {
          DEFAULT_AUTO_CHECKOUT_DM_MESSAGE
        } else {
          &settings.discord_auto_checkout_dm_message
        };

        for (notif_id, notification) in Notification::get_unsent()? {
          if notification.notification_type != NotificationType::AutoCheckout as i32 {
            continue;
          }

          let Some(ref member_id) = notification.team_member_id else { continue };
          let Some(session) = sessions.get(&notification.session_id) else { continue };
          let Some(member) = team_members.get(member_id) else { continue };
          let Some(mention) = Self::resolve_mention(guild_members, member) else { continue };
          let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);
          let location = locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str());
          let start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
          let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);

          let msg =
            DiscordNotificationService::replace_placeholders(auto_template, location, start_secs, end_secs, tz, None)
              .replace("{username}", &mention)
              .replace("{name}", member_name);

          if Self::send_member_notification(&http, notification_channel, &msg) {
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

    // Name sync
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
  fn resolve_mention(guild_members: &[GuildMember], team_member: &TeamMember) -> Option<String> {
    let discord_username = team_member.discord_username.as_deref().filter(|u| !u.is_empty())?;
    let guild_member = guild_members.iter().find(|gm| gm.user.name == discord_username)?;
    Some(format!("<@{}>", guild_member.user.id))
  }

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

      let Some(guild_member) = guild_members.iter().find(|gm| gm.user.name == discord_username) else {
        continue;
      };
      let new_display_name = guild_member.display_name().to_string();
      let current = member.display_name.as_deref().unwrap_or("");
      if current != new_display_name {
        log::info!(
          "[DiscordNotificationService] Syncing display name for {}: '{}' -> '{}'",
          discord_username,
          current,
          new_display_name
        );
        member.display_name = Some(new_display_name);
        TeamMember::update(&id, &member)?;
      }
    }

    Ok(())
  }
}
