use std::sync::Arc;
use std::time::Duration;

use chrono::{FixedOffset, Utc};
use serenity::all::{ChannelId, CreateEmbed, CreateMessage, GuildId, Member as GuildMember, MessageId, ReactionType};
use serenity::http::Http;

use crate::domains::discord::embeds;
use crate::domains::location::LocationLogic;
use crate::domains::session::SessionLogic;
use crate::domains::session_rsvp::SessionRsvpMessageLogic;
use crate::domains::settings::{
  DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_END_REMINDER_MESSAGE, DEFAULT_OVERTIME_DM_MESSAGE,
  DEFAULT_START_REMINDER_MESSAGE, SettingsLogic,
};
use crate::domains::team_member::{TeamMember, TeamMemberLogic};
use crate::scheduler::{Schedule, Service};
use crate::time::{format_date, format_time, parse_tz};

use super::logic::NotificationLogic;

/// Run an async future from within a sync context - unused now that `execute` is itself async,
/// kept only if a future caller needs to bridge a sync callback; currently unused.
#[allow(dead_code)]
fn block_on<F: std::future::Future>(f: F) -> F::Output {
  tokio::task::block_in_place(|| tokio::runtime::Handle::current().block_on(f))
}

pub struct DiscordNotificationService {
  settings: Arc<dyn SettingsLogic>,
  sessions: Arc<dyn SessionLogic>,
  locations: Arc<dyn LocationLogic>,
  notifications: Arc<dyn NotificationLogic>,
  team_members: Arc<dyn TeamMemberLogic>,
  session_rsvp_messages: Arc<dyn SessionRsvpMessageLogic>,
}

impl DiscordNotificationService {
  pub fn new(
    settings: Arc<dyn SettingsLogic>,
    sessions: Arc<dyn SessionLogic>,
    locations: Arc<dyn LocationLogic>,
    notifications: Arc<dyn NotificationLogic>,
    team_members: Arc<dyn TeamMemberLogic>,
    session_rsvp_messages: Arc<dyn SessionRsvpMessageLogic>,
  ) -> Self {
    Self { settings, sessions, locations, notifications, team_members, session_rsvp_messages }
  }

  fn replace_placeholders(
    template: &str,
    location: &str,
    start_secs: i64,
    end_secs: i64,
    tz: FixedOffset,
    mins: Option<i64>,
  ) -> String {
    let date_str = format_date(start_secs, tz);
    let start_date_str = date_str.clone();
    let end_date_str = format_date(end_secs, tz);
    let start_time_str = format_time(start_secs, tz);
    let end_time_str = format_time(end_secs, tz);

    let start_timestamp = format!("<t:{start_secs}:F>");
    let end_timestamp = format!("<t:{end_secs}:F>");

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

  /// A mention *is* the ID, so once members are keyed on their snowflake there
  /// is nothing to look up - the guild-member roster is no longer needed here.
  fn resolve_mention(team_member: &TeamMember) -> Option<String> {
    let discord_id = team_member.discord_id.as_deref().filter(|id| !id.is_empty())?;
    Some(format!("<@{discord_id}>"))
  }

  /// Sends an operator-authored message with a structured embed beside it.
  ///
  /// The template stays in the message *content* on purpose: it is where the
  /// `@here` and `<@id>` mentions live, and Discord only fires a notification
  /// for a mention in the content — one inside an embed renders as a link but
  /// pings nobody. The embed adds the session facts and the brand colour
  /// without taking the ping away.
  async fn send_with_facts(http: &Http, channel: ChannelId, message: &str, facts: CreateEmbed) -> bool {
    match channel.send_message(http, CreateMessage::new().content(message).embed(facts)).await {
      Ok(_) => true,
      Err(e) => {
        log::error!("[DiscordNotificationService] Failed to send notification: {e}");
        false
      }
    }
  }

  async fn sync_names(&self, guild_members: &[GuildMember]) -> anyhow::Result<()> {
    let team_members = self.team_members.get_all().await?;

    for member in team_members {
      let Some(discord_id) = member.discord_id.as_deref() else { continue };
      if discord_id.is_empty() {
        continue;
      }

      let Some(guild_member) = guild_members.iter().find(|gm| gm.user.id.to_string() == discord_id) else { continue };
      let new_display_name = guild_member.display_name().to_string();
      let current = member.display_name.as_deref().unwrap_or("");
      if current != new_display_name {
        log::info!(
          "[DiscordNotificationService] Syncing display name for {discord_id}: '{current}' -> '{new_display_name}'"
        );
        self
          .team_members
          .update(
            member.id,
            &member.first_name,
            &member.last_name,
            &member.member_type,
            Some(&new_display_name),
            member.mobile_number.as_deref(),
            member.discord_id.as_deref(),
            member.quick_pin.as_deref(),
          )
          .await?;
      }
    }

    Ok(())
  }
}

impl Service for DiscordNotificationService {
  fn name(&self) -> &'static str {
    "DiscordNotificationService"
  }

  fn schedule(&self) -> Schedule {
    Schedule::Every(Duration::from_secs(60))
  }

  async fn execute(&self) -> anyhow::Result<()> {
    let settings = self.settings.get().await?;

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
    let sessions = self.sessions.get_all().await?;
    let locations = self.locations.get_all().await?;
    let now_secs = Utc::now().timestamp();

    // --- Session Start/End Reminders ---
    for session in &sessions {
      let start_secs = session.start_time.timestamp();
      let end_secs = session.end_time.timestamp();

      if !session.finished {
        let location =
          locations.iter().find(|l| l.id == session.location_id).map_or("Unknown", |l| l.location.as_str());

        if start_reminder_secs > 0 {
          let time_until_start = start_secs - now_secs;
          if time_until_start > 0
            && time_until_start <= start_reminder_secs
            && !self.notifications.exists("session_start_reminder", session.id, None).await?
          {
            let mins = time_until_start / 60;
            let msg = Self::replace_placeholders(start_msg_template, location, start_secs, end_secs, tz, Some(mins));
            let facts =
              embeds::session_facts("Session starting soon", embeds::SUPPORT_INFO, location, start_secs, end_secs);

            match announcement_channel.send_message(&http, CreateMessage::new().content(&msg).embed(facts)).await {
              Ok(sent_msg) => {
                let discord_message_id = sent_msg.id.to_string();

                if settings.discord_rsvp_reactions_enabled {
                  let _ = sent_msg.react(&http, ReactionType::Unicode("👍".to_string())).await;
                  let _ = sent_msg.react(&http, ReactionType::Unicode("👎".to_string())).await;

                  if let Err(e) = self.session_rsvp_messages.set(&discord_message_id, session.id).await {
                    log::error!("[DiscordNotificationService] Failed to store RSVP message mapping: {e}");
                  }
                }

                self
                  .notifications
                  .add("session_start_reminder", session.id, None, true, Some(&discord_message_id))
                  .await?;
              }
              Err(e) => log::error!("[DiscordNotificationService] Failed to send start reminder: {e}"),
            }
          }
        }

        if end_reminder_secs > 0 {
          let time_until_end = end_secs - now_secs;
          if time_until_end > 0
            && time_until_end <= end_reminder_secs
            && now_secs >= start_secs
            && !self.notifications.exists("session_end_reminder", session.id, None).await?
          {
            let mins = time_until_end / 60;
            let msg = Self::replace_placeholders(end_msg_template, location, start_secs, end_secs, tz, Some(mins));
            let facts =
              embeds::session_facts("Session ending soon", embeds::SUPPORT_WARNING, location, start_secs, end_secs);

            match announcement_channel.send_message(&http, CreateMessage::new().content(&msg).embed(facts)).await {
              Ok(sent_msg) => {
                self
                  .notifications
                  .add("session_end_reminder", session.id, None, true, Some(&sent_msg.id.to_string()))
                  .await?;
              }
              Err(e) => log::error!("[DiscordNotificationService] Failed to send end reminder: {e}"),
            }
          }
        }
      }

      // Auto-delete start reminder when session has started
      if settings.discord_auto_delete_start_reminder && start_secs > 0 && now_secs >= start_secs {
        let session_notifs = self.notifications.get_by_session_id(session.id).await?;
        if let Some(notif) = session_notifs
          .into_iter()
          .find(|n| n.notification_type == "session_start_reminder" && n.discord_message_id.is_some())
        {
          let discord_msg_id = notif.discord_message_id.clone().unwrap();
          let msg_id: u64 = discord_msg_id.parse().unwrap_or(0);
          if msg_id > 0
            && let Err(e) = announcement_channel.delete_message(&http, MessageId::new(msg_id)).await
          {
            log::warn!("[DiscordNotificationService] Failed to delete start reminder message {discord_msg_id}: {e}");
          }
          if let Err(e) = self
            .notifications
            .update(notif.id, &notif.notification_type, notif.session_id, notif.team_member_id, notif.sent, None)
            .await
          {
            log::error!("[DiscordNotificationService] Failed to clear start reminder message ID: {e}");
          }
        }
      }

      // Auto-delete end reminder when session has ended
      if settings.discord_auto_delete_end_reminder && end_secs > 0 && now_secs >= end_secs {
        let session_notifs = self.notifications.get_by_session_id(session.id).await?;
        if let Some(notif) = session_notifs
          .into_iter()
          .find(|n| n.notification_type == "session_end_reminder" && n.discord_message_id.is_some())
        {
          let discord_msg_id = notif.discord_message_id.clone().unwrap();
          let msg_id: u64 = discord_msg_id.parse().unwrap_or(0);
          if msg_id > 0
            && let Err(e) = announcement_channel.delete_message(&http, MessageId::new(msg_id)).await
          {
            log::warn!("[DiscordNotificationService] Failed to delete end reminder message {discord_msg_id}: {e}");
          }
          if let Err(e) = self
            .notifications
            .update(notif.id, &notif.notification_type, notif.session_id, notif.team_member_id, notif.sent, None)
            .await
          {
            log::error!("[DiscordNotificationService] Failed to clear end reminder message ID: {e}");
          }
        }
      }
    }

    // --- Fetch guild members (name sync only) ---
    // DM notifications used to need this roster to turn a username into a
    // mentionable ID. Members are keyed on their ID now, so name sync is the
    // only remaining consumer and the fetch is gated on it.
    let guild_members = if !settings.discord_name_sync_enabled || settings.discord_guild_id.is_empty() {
      None
    } else {
      let guild_id: u64 = settings.discord_guild_id.parse().map_err(|e| anyhow::anyhow!("Invalid guild ID: {e}"))?;
      let guild = GuildId::new(guild_id);
      match guild.members(&http, Some(1000), None).await {
        Ok(members) => Some(members),
        Err(e) => {
          log::error!("[DiscordNotificationService] Failed to fetch guild members: {e}");
          None
        }
      }
    };

    // --- Per-user DM notifications ---
    if settings.discord_overtime_dm_enabled || settings.discord_auto_checkout_dm_enabled {
      let team_members = self.team_members.get_all().await?;

      if settings.discord_overtime_dm_enabled {
        let overtime_template = if settings.discord_overtime_dm_message.is_empty() {
          DEFAULT_OVERTIME_DM_MESSAGE
        } else {
          &settings.discord_overtime_dm_message
        };
        let overtime_threshold_secs = settings.discord_overtime_dm_mins * 60;

        for pes in self.sessions.get_past_end_sessions().await? {
          if pes.checked_in.is_empty() || now_secs <= pes.end_secs + overtime_threshold_secs {
            continue;
          }

          let location =
            locations.iter().find(|l| l.id == pes.session.location_id).map_or("Unknown", |l| l.location.as_str());

          for ms in &pes.checked_in {
            if self.notifications.exists("overtime", pes.session_id, Some(ms.team_member_id)).await? {
              continue;
            }

            let Some(member) = team_members.iter().find(|m| m.id == ms.team_member_id) else { continue };
            let Some(mention) = Self::resolve_mention(member) else { continue };
            let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

            let msg = Self::replace_placeholders(overtime_template, location, pes.start_secs, pes.end_secs, tz, None)
              .replace("{username}", &mention)
              .replace("{name}", member_name);

            let facts =
              embeds::session_facts("In overtime", embeds::SUPPORT_WARNING, location, pes.start_secs, pes.end_secs)
                .field("Member", member_name, true);

            if Self::send_with_facts(&http, notification_channel, &msg, facts).await
              && let Err(e) =
                self.notifications.add("overtime", pes.session_id, Some(ms.team_member_id), true, None).await
            {
              log::error!(
                "[DiscordNotificationService] Failed to record overtime notification for {}: {e}",
                ms.team_member_id
              );
            }
          }
        }
      }

      if settings.discord_auto_checkout_dm_enabled {
        let auto_template = if settings.discord_auto_checkout_dm_message.is_empty() {
          DEFAULT_AUTO_CHECKOUT_DM_MESSAGE
        } else {
          &settings.discord_auto_checkout_dm_message
        };

        for notification in self.notifications.get_unsent().await? {
          if notification.notification_type != "auto_checkout" {
            continue;
          }

          let Some(member_id) = notification.team_member_id else { continue };
          let Some(session) = sessions.iter().find(|s| s.id == notification.session_id) else { continue };
          let Some(member) = team_members.iter().find(|m| m.id == member_id) else { continue };
          let Some(mention) = Self::resolve_mention(member) else { continue };
          let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);
          let location =
            locations.iter().find(|l| l.id == session.location_id).map_or("Unknown", |l| l.location.as_str());
          let start_secs = session.start_time.timestamp();
          let end_secs = session.end_time.timestamp();

          let msg = Self::replace_placeholders(auto_template, location, start_secs, end_secs, tz, None)
            .replace("{username}", &mention)
            .replace("{name}", member_name);

          let facts = embeds::session_facts("Auto checked out", embeds::SUPPORT_INFO, location, start_secs, end_secs)
            .field("Member", member_name, true);

          if Self::send_with_facts(&http, notification_channel, &msg, facts).await
            && let Err(e) = self
              .notifications
              .update(
                notification.id,
                &notification.notification_type,
                notification.session_id,
                notification.team_member_id,
                true,
                notification.discord_message_id.as_deref(),
              )
              .await
          {
            log::error!(
              "[DiscordNotificationService] Failed to mark auto-checkout notification as sent for {}: {e}",
              notification.id
            );
          }
        }
      }
    }

    // Name sync
    if settings.discord_name_sync_enabled
      && let Some(ref guild_members) = guild_members
      && let Err(e) = self.sync_names(guild_members).await
    {
      log::error!("[DiscordNotificationService] Name sync failed: {e}");
    }

    Ok(())
  }
}
