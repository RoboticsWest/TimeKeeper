use async_graphql::SimpleObject;
use diesel::prelude::*;

use database::schema::{logos, settings};

pub const DEFAULT_NEXT_SESSION_THRESHOLD_SECS: i64 = 4 * 60 * 60; // 4 hours
pub const DEFAULT_START_REMINDER_MINS: i64 = 24 * 60; // 24 hours
pub const DEFAULT_END_REMINDER_MINS: i64 = 15;
pub const DEFAULT_START_REMINDER_MESSAGE: &str =
  "@here Session on {date} from {start_time} to {end_time} @ **{location}** starting in ~{mins} minutes!";
pub const DEFAULT_END_REMINDER_MESSAGE: &str =
  "@here Session @ **{location}** is ending in ~{mins} minutes \u{2014} don't forget to sign out!";
pub const DEFAULT_OVERTIME_DM_MINS: i64 = 10;
pub const DEFAULT_OVERTIME_DM_MESSAGE: &str = "Hey {username}, you're now in overtime for the session @ **{location}**. The session ended at **{end_time}**. Don't forget to check out!";
pub const DEFAULT_AUTO_CHECKOUT_DM_MESSAGE: &str = "Hey {username}, you've been auto-checked-out from the session @ **{location}** (ended at **{end_time}**) because a new session is starting soon.";

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = settings)]
#[diesel(check_for_backend(diesel::pg::Pg))]
#[allow(clippy::struct_excessive_bools)]
pub struct Settings {
  pub id: bool,
  pub next_session_threshold_secs: i64,
  pub discord_bot_token: String,
  pub discord_guild_id: String,
  pub discord_announcement_channel_id: String,
  pub discord_notification_channel_id: String,
  pub discord_self_link_enabled: bool,
  pub discord_name_sync_enabled: bool,
  pub discord_start_reminder_mins: i64,
  pub discord_end_reminder_mins: i64,
  pub discord_start_reminder_message: String,
  pub discord_end_reminder_message: String,
  pub discord_overtime_dm_enabled: bool,
  pub discord_overtime_dm_mins: i64,
  pub discord_overtime_dm_message: String,
  pub discord_auto_checkout_dm_enabled: bool,
  pub discord_auto_checkout_dm_message: String,
  pub discord_checkout_enabled: bool,
  pub discord_enabled: bool,
  pub timezone: String,
  pub leaderboard_show_overtime: bool,
  pub leaderboard_member_types: Vec<Option<String>>,
  pub discord_rsvp_reactions_enabled: bool,
  pub discord_auto_delete_start_reminder: bool,
  pub discord_auto_delete_end_reminder: bool,
}

#[derive(Debug, Clone, Queryable, Selectable)]
#[diesel(table_name = logos)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Logo {
  pub id: bool,
  pub data: Vec<u8>,
}
