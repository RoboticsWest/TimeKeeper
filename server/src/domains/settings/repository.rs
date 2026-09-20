use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;

use database::{
  DbPool,
  schema::{logos, settings},
};

use super::model::{
  DEFAULT_AUTO_CHECKOUT_AFTER_SECS, DEFAULT_AUTO_CHECKOUT_DM_MESSAGE, DEFAULT_CHECK_IN_WINDOW_SECS,
  DEFAULT_END_REMINDER_MESSAGE, DEFAULT_END_REMINDER_MINS, DEFAULT_OVERTIME_DM_MESSAGE, DEFAULT_OVERTIME_DM_MINS,
  DEFAULT_START_REMINDER_MESSAGE, DEFAULT_START_REMINDER_MINS, Logo, Settings,
};

fn default_settings() -> Settings {
  Settings {
    id: true,
    check_in_window_secs: DEFAULT_CHECK_IN_WINDOW_SECS,
    auto_checkout_after_secs: DEFAULT_AUTO_CHECKOUT_AFTER_SECS,
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
    // A fresh install is not under maintenance.
    maintenance_mode: false,
    maintenance_message: String::new(),
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
        .values(&defaults)
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
        .values(record)
        .on_conflict(settings::id)
        // `AsChangeset` skips the primary key, so this updates every other column from `record`.
        .do_update()
        .set(record)
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
