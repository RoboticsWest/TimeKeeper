use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;

use chrono::{DateTime, FixedOffset, Utc};
use serenity::all::{ChannelId, CreateEmbed, CreateMessage, GuildId, Member as GuildMember, MessageId, ReactionType};
use serenity::http::Http;
use uuid::Uuid;

use crate::domains::discord::embeds;
use crate::domains::location::{Location, LocationLogic};
use crate::domains::session::{Session, SessionLogic};
use crate::domains::session_rsvp::SessionRsvpMessageLogic;
use crate::domains::settings::{
  DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_END_REMINDER_MESSAGE, DEFAULT_OVERTIME_DM_MESSAGE,
  DEFAULT_START_REMINDER_MESSAGE, Settings, SettingsLogic,
};
use crate::domains::statistics::MemberStatsLogic;
use crate::domains::team_member::{TeamMember, TeamMemberLogic};
use crate::scheduler::{Schedule, Service};
use crate::time::{format_date, format_relative_day, format_time, format_weekday, parse_tz};

use super::logic::NotificationLogic;
use super::model::{
  Notification, STATUS_FAILED, STATUS_PENDING, STATUS_SENT, TYPE_AUTO_CHECKOUT, TYPE_OVERTIME,
  TYPE_SESSION_END_REMINDER, TYPE_SESSION_START_REMINDER,
};
use super::repository::NewNotification;
use super::scheduling::{LateReminderPolicy, ensure_session_reminders};

pub struct DiscordNotificationService {
  settings: Arc<dyn SettingsLogic>,
  sessions: Arc<dyn SessionLogic>,
  locations: Arc<dyn LocationLogic>,
  notifications: Arc<dyn NotificationLogic>,
  team_members: Arc<dyn TeamMemberLogic>,
  session_rsvp_messages: Arc<dyn SessionRsvpMessageLogic>,
  member_stats: Arc<dyn MemberStatsLogic>,
}

/// Everything the send loop needs to render one notification.
struct SendContext<'a> {
  http: &'a Http,
  settings: &'a Settings,
  tz: FixedOffset,
  now_secs: i64,
  announcement_channel: ChannelId,
  notification_channel: ChannelId,
  sessions: &'a HashMap<Uuid, Session>,
  locations: &'a HashMap<Uuid, Location>,
  members: &'a HashMap<Uuid, TeamMember>,
}

impl SendContext<'_> {
  fn location_name(&self, session: &Session) -> &str {
    self.locations.get(&session.location_id).map_or("Unknown", |l| l.location.as_str())
  }
}

impl DiscordNotificationService {
  pub fn new(
    settings: Arc<dyn SettingsLogic>,
    sessions: Arc<dyn SessionLogic>,
    locations: Arc<dyn LocationLogic>,
    notifications: Arc<dyn NotificationLogic>,
    team_members: Arc<dyn TeamMemberLogic>,
    session_rsvp_messages: Arc<dyn SessionRsvpMessageLogic>,
    member_stats: Arc<dyn MemberStatsLogic>,
  ) -> Self {
    Self { settings, sessions, locations, notifications, team_members, session_rsvp_messages, member_stats }
  }

  /// Substitutes the `{...}` tokens an operator can use in a message template.
  ///
  /// `{relative_day}` is the one that earns its keep: templates used to hardcode "tomorrow",
  /// which silently became a lie whenever a session was created inside its own reminder window.
  fn replace_placeholders(
    template: &str,
    location: &str,
    start_secs: i64,
    end_secs: i64,
    tz: FixedOffset,
    now_secs: i64,
    mins: Option<i64>,
  ) -> String {
    let date_str = format_date(start_secs, tz);

    let mut msg = template
      .replace("{location}", location)
      .replace("{date}", &date_str)
      .replace("{start_date}", &date_str)
      .replace("{end_date}", &format_date(end_secs, tz))
      .replace("{start_time}", &format_time(start_secs, tz))
      .replace("{end_time}", &format_time(end_secs, tz))
      .replace("{start_date_time}", &format!("<t:{start_secs}:F>"))
      .replace("{end_date_time}", &format!("<t:{end_secs}:F>"))
      .replace("{relative_day}", &format_relative_day(start_secs, tz, now_secs))
      .replace("{weekday}", &format_weekday(start_secs, tz))
      .replace("{end_weekday}", &format_weekday(end_secs, tz));

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
  async fn send_with_facts(http: &Http, channel: ChannelId, message: &str, facts: CreateEmbed) -> Option<String> {
    match channel.send_message(http, CreateMessage::new().content(message).embed(facts)).await {
      Ok(sent) => Some(sent.id.to_string()),
      Err(e) => {
        log::error!("[DiscordNotificationService] Failed to send notification: {e}");
        None
      }
    }
  }

  /// Makes sure every future session has its session-wide reminders scheduled.
  ///
  /// Sessions get their reminders at creation time, but reminder lead times can be changed
  /// afterwards, and sessions imported before this scheduling model existed have none at all.
  /// Scheduling is idempotent, so this is a cheap safety net rather than a second source of
  /// truth: a reminder already sent, cancelled or skipped is never revived.
  async fn backfill_schedules(&self, settings: &Settings, now: DateTime<Utc>) -> anyhow::Result<()> {
    for session in self.sessions.get_all().await? {
      if session.finished || session.end_time <= now {
        continue;
      }
      // A session created before the operator set a lead time was never offered the choice, so
      // a reminder that is already overdue is skipped rather than fired retroactively.
      if let Err(e) =
        ensure_session_reminders(self.notifications.as_ref(), &session, settings, now, LateReminderPolicy::Skip).await
      {
        log::error!("[DiscordNotificationService] Failed to schedule reminders for session {}: {e}", session.id);
      }
    }
    Ok(())
  }

  /// Schedules the per-member `overtime` notifications for anyone still checked in past the
  /// configured threshold. Idempotent via the unique index, so a member is warned once.
  async fn schedule_overtime(&self, settings: &Settings, now_secs: i64) -> anyhow::Result<()> {
    if !settings.discord_overtime_dm_enabled {
      return Ok(());
    }
    let threshold_secs = settings.discord_overtime_dm_mins * 60;

    for pes in self.sessions.get_past_end_sessions().await? {
      if pes.checked_in.is_empty() {
        continue;
      }
      let due_secs = pes.end_secs + threshold_secs;
      if now_secs < due_secs {
        continue;
      }
      let Some(due) = DateTime::from_timestamp(due_secs, 0) else { continue };

      for ms in &pes.checked_in {
        if let Err(e) = self
          .notifications
          .schedule(NewNotification {
            notification_type: TYPE_OVERTIME,
            session_id: pes.session_id,
            team_member_id: Some(ms.team_member_id),
            scheduled_for: Some(due),
            status: STATUS_PENDING,
          })
          .await
        {
          log::error!(
            "[DiscordNotificationService] Failed to schedule overtime notification for {}: {e}",
            ms.team_member_id
          );
        }
      }
    }
    Ok(())
  }

  /// Sends one due notification. Returns the Discord message id when one was produced.
  async fn dispatch(&self, ctx: &SendContext<'_>, notification: &Notification) -> anyhow::Result<Option<String>> {
    let Some(session) = ctx.sessions.get(&notification.session_id) else {
      anyhow::bail!("session {} no longer exists", notification.session_id);
    };
    let location = ctx.location_name(session);
    let start_secs = session.start_time.timestamp();
    let end_secs = session.end_time.timestamp();

    match notification.notification_type.as_str() {
      TYPE_SESSION_START_REMINDER => {
        let template = if ctx.settings.discord_start_reminder_message.is_empty() {
          DEFAULT_START_REMINDER_MESSAGE
        } else {
          &ctx.settings.discord_start_reminder_message
        };
        let mins = (start_secs - ctx.now_secs).max(0) / 60;
        let msg =
          Self::replace_placeholders(template, location, start_secs, end_secs, ctx.tz, ctx.now_secs, Some(mins));
        let facts =
          embeds::session_facts("Session starting soon", embeds::SUPPORT_INFO, location, start_secs, end_secs);

        let sent =
          ctx.announcement_channel.send_message(ctx.http, CreateMessage::new().content(&msg).embed(facts)).await?;
        let message_id = sent.id.to_string();

        if ctx.settings.discord_rsvp_reactions_enabled {
          let _ = sent.react(ctx.http, ReactionType::Unicode("\u{1F44D}".to_string())).await;
          let _ = sent.react(ctx.http, ReactionType::Unicode("\u{1F44E}".to_string())).await;
          if let Err(e) = self.session_rsvp_messages.set(&message_id, session.id).await {
            log::error!("[DiscordNotificationService] Failed to store RSVP message mapping: {e}");
          }
        }

        Ok(Some(message_id))
      }

      TYPE_SESSION_END_REMINDER => {
        let template = if ctx.settings.discord_end_reminder_message.is_empty() {
          DEFAULT_END_REMINDER_MESSAGE
        } else {
          &ctx.settings.discord_end_reminder_message
        };
        let mins = (end_secs - ctx.now_secs).max(0) / 60;
        let msg =
          Self::replace_placeholders(template, location, start_secs, end_secs, ctx.tz, ctx.now_secs, Some(mins));
        let facts =
          embeds::session_facts("Session ending soon", embeds::SUPPORT_WARNING, location, start_secs, end_secs);

        let sent =
          ctx.announcement_channel.send_message(ctx.http, CreateMessage::new().content(&msg).embed(facts)).await?;
        Ok(Some(sent.id.to_string()))
      }

      TYPE_OVERTIME | TYPE_AUTO_CHECKOUT => {
        let is_overtime = notification.notification_type == TYPE_OVERTIME;
        let enabled = if is_overtime {
          ctx.settings.discord_overtime_dm_enabled
        } else {
          ctx.settings.discord_auto_checkout_dm_enabled
        };
        if !enabled {
          // Leave it pending: the operator may turn the feature back on.
          return Ok(None);
        }

        let Some(member_id) = notification.team_member_id else {
          anyhow::bail!("{} notification has no team member", notification.notification_type);
        };
        let Some(member) = ctx.members.get(&member_id) else {
          anyhow::bail!("team member {member_id} no longer exists");
        };
        let Some(mention) = Self::resolve_mention(member) else {
          // No linked Discord account - nothing to send, and nothing to retry.
          anyhow::bail!("team member {member_id} has no linked Discord account");
        };
        let member_name = member.display_name.as_deref().unwrap_or(&member.first_name);

        let (template, title, colour) = if is_overtime {
          let t = if ctx.settings.discord_overtime_dm_message.is_empty() {
            DEFAULT_OVERTIME_DM_MESSAGE
          } else {
            &ctx.settings.discord_overtime_dm_message
          };
          (t, "In overtime", embeds::SUPPORT_WARNING)
        } else {
          let t = if ctx.settings.discord_auto_checkout_dm_message.is_empty() {
            DEFAULT_AUTO_CHECKOUT_DM_MESSAGE
          } else {
            &ctx.settings.discord_auto_checkout_dm_message
          };
          (t, "Auto checked out", embeds::SUPPORT_INFO)
        };

        let msg = Self::replace_placeholders(template, location, start_secs, end_secs, ctx.tz, ctx.now_secs, None)
          .replace("{username}", &mention)
          .replace("{name}", member_name);
        let facts =
          embeds::session_facts(title, colour, location, start_secs, end_secs).field("Member", member_name, true);

        Ok(Self::send_with_facts(ctx.http, ctx.notification_channel, &msg, facts).await)
      }

      other => anyhow::bail!("unknown notification type '{other}'"),
    }
  }

  /// Deletes the Discord message for a reminder whose moment has passed, when configured to.
  async fn auto_delete_expired(&self, ctx: &SendContext<'_>) -> anyhow::Result<()> {
    if !ctx.settings.discord_auto_delete_start_reminder && !ctx.settings.discord_auto_delete_end_reminder {
      return Ok(());
    }

    for (session_id, session) in ctx.sessions {
      for notification in self.notifications.get_by_session_id(*session_id).await? {
        if notification.status != STATUS_SENT {
          continue;
        }
        let Some(message_id) = notification.discord_message_id.as_deref() else { continue };

        let expired = match notification.notification_type.as_str() {
          TYPE_SESSION_START_REMINDER => {
            ctx.settings.discord_auto_delete_start_reminder && ctx.now_secs >= session.start_time.timestamp()
          }
          TYPE_SESSION_END_REMINDER => {
            ctx.settings.discord_auto_delete_end_reminder && ctx.now_secs >= session.end_time.timestamp()
          }
          _ => false,
        };
        if !expired {
          continue;
        }

        let Ok(raw) = message_id.parse::<u64>() else { continue };
        if let Err(e) = ctx.announcement_channel.delete_message(ctx.http, MessageId::new(raw)).await {
          log::warn!("[DiscordNotificationService] Failed to delete reminder message {message_id}: {e}");
        }
        // Cleared either way: if the message is already gone, retrying forever helps nobody.
        if let Err(e) = self.notifications.clear_message_id(notification.id).await {
          log::error!("[DiscordNotificationService] Failed to clear reminder message ID: {e}");
        }
      }
    }
    Ok(())
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

    let now = Utc::now();
    let now_secs = now.timestamp();

    // Keep the schedule complete before deciding what is due.
    self.backfill_schedules(&settings, now).await?;
    self.schedule_overtime(&settings, now_secs).await?;

    let announcement_channel_id: u64 = settings
      .discord_announcement_channel_id
      .parse()
      .map_err(|e| anyhow::anyhow!("Invalid announcement channel ID: {e}"))?;
    let notification_channel_id: u64 = settings
      .discord_notification_channel_id
      .parse()
      .map_err(|e| anyhow::anyhow!("Invalid notification channel ID: {e}"))?;

    let http = Http::new(&settings.discord_bot_token);
    let sessions: HashMap<Uuid, Session> = self.sessions.get_all().await?.into_iter().map(|s| (s.id, s)).collect();
    let locations: HashMap<Uuid, Location> = self.locations.get_all().await?.into_iter().map(|l| (l.id, l)).collect();
    let members: HashMap<Uuid, TeamMember> =
      self.team_members.get_all().await?.into_iter().map(|m| (m.id, m)).collect();

    let ctx = SendContext {
      http: &http,
      settings: &settings,
      tz: parse_tz(&settings.timezone),
      now_secs,
      announcement_channel: ChannelId::new(announcement_channel_id),
      notification_channel: ChannelId::new(notification_channel_id),
      sessions: &sessions,
      locations: &locations,
      members: &members,
    };

    // --- Send everything that is due ---
    //
    // The whole send decision is this query. Previously it was inferred from the *absence* of a
    // row, which meant deleting a notification re-armed it; now a row's status is the record,
    // and a send only ever moves it out of `pending`.
    for notification in self.notifications.get_due(now).await? {
      match self.dispatch(&ctx, &notification).await {
        Ok(Some(message_id)) => {
          if let Err(e) = self.notifications.mark_sent(notification.id, Some(&message_id)).await {
            log::error!("[DiscordNotificationService] Failed to mark notification {} sent: {e}", notification.id);
          }

          // Counted here rather than where the notification is scheduled: this is the point at
          // which the member was actually told. A notification that stayed pending because the
          // feature was switched off, or failed because nobody linked a Discord account, is not
          // a warning anybody received. Status only ever leaves `pending` once, so it counts once.
          if notification.notification_type == TYPE_OVERTIME
            && let Some(member_id) = notification.team_member_id
          {
            self.member_stats.record_overtime_warning(member_id).await;
          }
        }
        // Nothing sent, but nothing wrong either - the feature is switched off. Leave pending.
        Ok(None) => {}
        Err(e) => {
          log::error!(
            "[DiscordNotificationService] Failed to send {} notification {}: {e}",
            notification.notification_type,
            notification.id
          );
          // Terminal: retrying a message whose session or member is gone will never succeed,
          // and leaving it pending would log the same error every minute forever.
          if let Err(e) = self.notifications.set_status(notification.id, STATUS_FAILED).await {
            log::error!("[DiscordNotificationService] Failed to mark notification failed: {e}");
          }
        }
      }
    }

    self.auto_delete_expired(&ctx).await?;

    // --- Name sync ---
    // DM notifications used to need the guild roster to turn a username into a mentionable ID.
    // Members are keyed on their ID now, so name sync is the only remaining consumer.
    if settings.discord_name_sync_enabled && !settings.discord_guild_id.is_empty() {
      let guild_id: u64 = settings.discord_guild_id.parse().map_err(|e| anyhow::anyhow!("Invalid guild ID: {e}"))?;
      match GuildId::new(guild_id).members(&http, Some(1000), None).await {
        Ok(guild_members) => {
          if let Err(e) = self.sync_names(&guild_members).await {
            log::error!("[DiscordNotificationService] Name sync failed: {e}");
          }
        }
        Err(e) => log::error!("[DiscordNotificationService] Failed to fetch guild members: {e}"),
      }
    }

    Ok(())
  }
}
