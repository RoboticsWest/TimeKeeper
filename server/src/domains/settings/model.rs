use async_graphql::SimpleObject;
use diesel::prelude::*;

use database::schema::{logos, settings};

/// How far either side of a session a kiosk scan still counts as checking in to it.
pub const DEFAULT_CHECK_IN_WINDOW_SECS: i64 = 4 * 60 * 60; // 4 hours
/// How long after a session's scheduled end its stragglers are auto-checked-out. The other
/// trigger - the next session at that location starting - is unconditional.
pub const DEFAULT_AUTO_CHECKOUT_AFTER_SECS: i64 = 24 * 60 * 60; // 24 hours
pub const DEFAULT_START_REMINDER_MINS: i64 = 24 * 60; // 24 hours
pub const DEFAULT_END_REMINDER_MINS: i64 = 15;
/// Uses `{relative_day}` rather than a hardcoded "tomorrow": the reminder fires whenever its
/// lead time is reached, which is not always the day before.
pub const DEFAULT_START_REMINDER_MESSAGE: &str =
  "@here Session {relative_day} from {start_time} to {end_time} @ **{location}** \u{2014} starting in ~{mins} minutes!";
pub const DEFAULT_END_REMINDER_MESSAGE: &str =
  "@here Session @ **{location}** is ending in ~{mins} minutes \u{2014} don't forget to sign out!";
pub const DEFAULT_OVERTIME_DM_MINS: i64 = 10;
pub const DEFAULT_OVERTIME_DM_MESSAGE: &str = "Hey {username}, you're now in overtime for the session @ **{location}**. The session ended at **{end_time}**. Don't forget to check out!";
pub const DEFAULT_AUTO_CHECKOUT_DM_MESSAGE: &str = "Hey {username}, you've been auto-checked-out from the session @ **{location}** (ended at **{end_time}**) because you were still signed in after it finished.";

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = settings)]
#[diesel(check_for_backend(diesel::pg::Pg))]
#[allow(clippy::struct_excessive_bools)]
pub struct Settings {
  pub id: bool,
  pub check_in_window_secs: i64,
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
  /// Enables the kiosk's PIN sign-in method.
  pub quick_pin_enabled: bool,
  /// Grace period after a session's scheduled end before lingering members are checked out.
  pub auto_checkout_after_secs: i64,
}

#[derive(Debug, Clone, Queryable, Selectable)]
#[diesel(table_name = logos)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Logo {
  pub id: bool,
  pub data: Vec<u8>,
}
