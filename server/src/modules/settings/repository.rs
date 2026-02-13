use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::Settings,
};

const SETTINGS_TABLE_NAME: &str = "settings";
const SETTINGS_KEY: &str = "settings";

pub const DEFAULT_NEXT_SESSION_THRESHOLD_SECS: i64 = 4 * 60 * 60; // 4 hours
pub const DEFAULT_START_REMINDER_MINS: i64 = 24 * 60; // 24 hours
pub const DEFAULT_END_REMINDER_MINS: i64 = 15;
pub const DEFAULT_START_REMINDER_MESSAGE: &str =
  "@here Session on {date} from {start_time} to {end_time} @ {location} starting in ~{mins} minutes!";
pub const DEFAULT_END_REMINDER_MESSAGE: &str =
  "@here Session at {location} is ending in ~{mins} minutes \u{2014} don't forget to sign out!";

pub trait SettingsRepository {
  fn set(record: &Settings) -> Result<()>;
  fn get() -> Result<Settings>;
  fn clear() -> Result<()>;
}

impl SettingsRepository for Settings {
  fn set(record: &Settings) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SETTINGS_TABLE_NAME);
    let data = DataInsert { id: Some(SETTINGS_KEY.to_string()), value: record.clone(), search_indexes: vec![] };
    table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::Record {
      operation: ChangeOperation::Update,
      id: SETTINGS_KEY.to_string(),
      data: Some(record.clone()),
    })?;

    Ok(())
  }

  fn get() -> Result<Settings> {
    let db = get_db()?;
    let table = db.get_table(SETTINGS_TABLE_NAME);

    if let Some(s) = table.get::<Settings>(SETTINGS_KEY)? {
      Ok(s)
    } else {
      #[allow(deprecated)]
      let default = Settings {
        next_session_threshold_secs: DEFAULT_NEXT_SESSION_THRESHOLD_SECS,
        discord_bot_token: String::new(),
        discord_guild_id: String::new(),
        discord_channel_id: String::new(),
        discord_reminder_mins: 0,
        discord_self_link_enabled: false,
        discord_name_sync_enabled: true,
        discord_start_reminder_mins: DEFAULT_START_REMINDER_MINS,
        discord_end_reminder_mins: DEFAULT_END_REMINDER_MINS,
        discord_start_reminder_message: DEFAULT_START_REMINDER_MESSAGE.to_string(),
        discord_end_reminder_message: DEFAULT_END_REMINDER_MESSAGE.to_string(),
      };
      Self::set(&default)?;
      Ok(default)
    }
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SETTINGS_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Settings>::Table)?;

    Ok(())
  }
}
