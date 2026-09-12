use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;

use database::{
  DbPool,
  schema::{logos, settings},
};

use super::model::{
  DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_END_REMINDER_MESSAGE, DEFAULT_END_REMINDER_MINS,
  DEFAULT_NEXT_SESSION_THRESHOLD_SECS, DEFAULT_OVERTIME_DM_MESSAGE, DEFAULT_OVERTIME_DM_MINS,
  DEFAULT_START_REMINDER_MESSAGE, DEFAULT_START_REMINDER_MINS, Logo, Settings,
};

fn default_settings() -> Settings {
  Settings {
    id: true,
    next_session_threshold_secs: DEFAULT_NEXT_SESSION_THRESHOLD_SECS,
    discord_bot_token: String::new(),
    discord_guild_id: String::new(),
    discord_announcement_channel_id: String::new(),
    discord_notification_channel_id: String::new(),
    discord_self_link_enabled: false,
    discord_name_sync_enabled: false,
    discord_start_reminder_mins: DEFAULT_START_REMINDER_MINS,
    discord_end_reminder_mins: DEFAULT_END_REMINDER_MINS,
    discord_start_reminder_message: DEFAULT_START_REMINDER_MESSAGE.to_string(),
    discord_end_reminder_message: DEFAULT_END_REMINDER_MESSAGE.to_string(),
    discord_overtime_dm_enabled: true,
    discord_overtime_dm_mins: DEFAULT_OVERTIME_DM_MINS,
    discord_overtime_dm_message: DEFAULT_OVERTIME_DM_MESSAGE.to_string(),
    discord_auto_checkout_dm_enabled: true,
    discord_auto_checkout_dm_message: DEFAULT_AUTO_CHECKOUT_DM_MESSAGE.to_string(),
    discord_checkout_enabled: false,
    discord_enabled: false,
    timezone: String::new(),
    leaderboard_show_overtime: true,
    leaderboard_member_types: vec![Some("student".to_string()), Some("mentor".to_string())],
    discord_rsvp_reactions_enabled: true,
    discord_auto_delete_start_reminder: false,
    discord_auto_delete_end_reminder: false,
    quick_pin_enabled: false,
  }
}

#[async_trait]
pub trait SettingsRepository: Send + Sync {
  async fn get(&self) -> anyhow::Result<Settings>;
  async fn set(&self, settings: &Settings) -> anyhow::Result<Settings>;
  /// Deletes the settings row - the next `get()` recreates it with defaults. Used by purge-database.
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgSettingsRepository {
  pool: DbPool,
}

impl PgSettingsRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl SettingsRepository for PgSettingsRepository {
  async fn get(&self) -> anyhow::Result<Settings> {
    let mut conn = self.pool.get().await?;

    if let Some(existing) = settings::table.select(Settings::as_select()).first(&mut conn).await.optional()? {
      return Ok(existing);
    }

    let defaults = default_settings();
    Ok(
      diesel::insert_into(settings::table)
        .values((
          settings::id.eq(defaults.id),
          settings::next_session_threshold_secs.eq(defaults.next_session_threshold_secs),
          settings::discord_bot_token.eq(&defaults.discord_bot_token),
          settings::discord_guild_id.eq(&defaults.discord_guild_id),
          settings::discord_announcement_channel_id.eq(&defaults.discord_announcement_channel_id),
          settings::discord_notification_channel_id.eq(&defaults.discord_notification_channel_id),
          settings::discord_self_link_enabled.eq(defaults.discord_self_link_enabled),
          settings::discord_name_sync_enabled.eq(defaults.discord_name_sync_enabled),
          settings::discord_start_reminder_mins.eq(defaults.discord_start_reminder_mins),
          settings::discord_end_reminder_mins.eq(defaults.discord_end_reminder_mins),
          settings::discord_start_reminder_message.eq(&defaults.discord_start_reminder_message),
          settings::discord_end_reminder_message.eq(&defaults.discord_end_reminder_message),
          settings::discord_overtime_dm_enabled.eq(defaults.discord_overtime_dm_enabled),
          settings::discord_overtime_dm_mins.eq(defaults.discord_overtime_dm_mins),
          settings::discord_overtime_dm_message.eq(&defaults.discord_overtime_dm_message),
          settings::discord_auto_checkout_dm_enabled.eq(defaults.discord_auto_checkout_dm_enabled),
          settings::discord_auto_checkout_dm_message.eq(&defaults.discord_auto_checkout_dm_message),
          settings::discord_checkout_enabled.eq(defaults.discord_checkout_enabled),
          settings::discord_enabled.eq(defaults.discord_enabled),
          settings::timezone.eq(&defaults.timezone),
          settings::leaderboard_show_overtime.eq(defaults.leaderboard_show_overtime),
          settings::leaderboard_member_types.eq(&defaults.leaderboard_member_types),
          settings::discord_rsvp_reactions_enabled.eq(defaults.discord_rsvp_reactions_enabled),
          settings::discord_auto_delete_start_reminder.eq(defaults.discord_auto_delete_start_reminder),
          settings::discord_auto_delete_end_reminder.eq(defaults.discord_auto_delete_end_reminder),
          settings::quick_pin_enabled.eq(defaults.quick_pin_enabled),
        ))
        .on_conflict(settings::id)
        .do_update()
        .set(settings::id.eq(defaults.id))
        .returning(Settings::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn set(&self, record: &Settings) -> anyhow::Result<Settings> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::insert_into(settings::table)
        .values((
          settings::id.eq(true),
          settings::next_session_threshold_secs.eq(record.next_session_threshold_secs),
          settings::discord_bot_token.eq(&record.discord_bot_token),
          settings::discord_guild_id.eq(&record.discord_guild_id),
          settings::discord_announcement_channel_id.eq(&record.discord_announcement_channel_id),
          settings::discord_notification_channel_id.eq(&record.discord_notification_channel_id),
          settings::discord_self_link_enabled.eq(record.discord_self_link_enabled),
          settings::discord_name_sync_enabled.eq(record.discord_name_sync_enabled),
          settings::discord_start_reminder_mins.eq(record.discord_start_reminder_mins),
          settings::discord_end_reminder_mins.eq(record.discord_end_reminder_mins),
          settings::discord_start_reminder_message.eq(&record.discord_start_reminder_message),
          settings::discord_end_reminder_message.eq(&record.discord_end_reminder_message),
          settings::discord_overtime_dm_enabled.eq(record.discord_overtime_dm_enabled),
          settings::discord_overtime_dm_mins.eq(record.discord_overtime_dm_mins),
          settings::discord_overtime_dm_message.eq(&record.discord_overtime_dm_message),
          settings::discord_auto_checkout_dm_enabled.eq(record.discord_auto_checkout_dm_enabled),
          settings::discord_auto_checkout_dm_message.eq(&record.discord_auto_checkout_dm_message),
          settings::discord_checkout_enabled.eq(record.discord_checkout_enabled),
          settings::discord_enabled.eq(record.discord_enabled),
          settings::timezone.eq(&record.timezone),
          settings::leaderboard_show_overtime.eq(record.leaderboard_show_overtime),
          settings::leaderboard_member_types.eq(&record.leaderboard_member_types),
          settings::discord_rsvp_reactions_enabled.eq(record.discord_rsvp_reactions_enabled),
          settings::discord_auto_delete_start_reminder.eq(record.discord_auto_delete_start_reminder),
          settings::discord_auto_delete_end_reminder.eq(record.discord_auto_delete_end_reminder),
          settings::quick_pin_enabled.eq(record.quick_pin_enabled),
        ))
        .on_conflict(settings::id)
        .do_update()
        .set((
          settings::next_session_threshold_secs.eq(record.next_session_threshold_secs),
          settings::discord_bot_token.eq(&record.discord_bot_token),
          settings::discord_guild_id.eq(&record.discord_guild_id),
          settings::discord_announcement_channel_id.eq(&record.discord_announcement_channel_id),
          settings::discord_notification_channel_id.eq(&record.discord_notification_channel_id),
          settings::discord_self_link_enabled.eq(record.discord_self_link_enabled),
          settings::discord_name_sync_enabled.eq(record.discord_name_sync_enabled),
          settings::discord_start_reminder_mins.eq(record.discord_start_reminder_mins),
          settings::discord_end_reminder_mins.eq(record.discord_end_reminder_mins),
          settings::discord_start_reminder_message.eq(&record.discord_start_reminder_message),
          settings::discord_end_reminder_message.eq(&record.discord_end_reminder_message),
          settings::discord_overtime_dm_enabled.eq(record.discord_overtime_dm_enabled),
          settings::discord_overtime_dm_mins.eq(record.discord_overtime_dm_mins),
          settings::discord_overtime_dm_message.eq(&record.discord_overtime_dm_message),
          settings::discord_auto_checkout_dm_enabled.eq(record.discord_auto_checkout_dm_enabled),
          settings::discord_auto_checkout_dm_message.eq(&record.discord_auto_checkout_dm_message),
          settings::discord_checkout_enabled.eq(record.discord_checkout_enabled),
          settings::discord_enabled.eq(record.discord_enabled),
          settings::timezone.eq(&record.timezone),
          settings::leaderboard_show_overtime.eq(record.leaderboard_show_overtime),
          settings::leaderboard_member_types.eq(&record.leaderboard_member_types),
          settings::discord_rsvp_reactions_enabled.eq(record.discord_rsvp_reactions_enabled),
          settings::discord_auto_delete_start_reminder.eq(record.discord_auto_delete_start_reminder),
          settings::discord_auto_delete_end_reminder.eq(record.discord_auto_delete_end_reminder),
          settings::quick_pin_enabled.eq(record.quick_pin_enabled),
        ))
        .returning(Settings::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(settings::table).execute(&mut conn).await?;
    Ok(())
  }
}

#[async_trait]
pub trait LogoRepository: Send + Sync {
  async fn get(&self) -> anyhow::Result<Option<Vec<u8>>>;
  async fn set(&self, data: &[u8]) -> anyhow::Result<Logo>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgLogoRepository {
  pool: DbPool,
}

impl PgLogoRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl LogoRepository for PgLogoRepository {
  async fn get(&self) -> anyhow::Result<Option<Vec<u8>>> {
    let mut conn = self.pool.get().await?;
    let logo = logos::table.select(Logo::as_select()).first(&mut conn).await.optional()?;
    Ok(logo.and_then(|l| if l.data.is_empty() { None } else { Some(l.data) }))
  }

  async fn set(&self, data: &[u8]) -> anyhow::Result<Logo> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::insert_into(logos::table)
        .values((logos::id.eq(true), logos::data.eq(data)))
        .on_conflict(logos::id)
        .do_update()
        .set(logos::data.eq(data))
        .returning(Logo::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(logos::table).execute(&mut conn).await?;
    Ok(())
  }
}
