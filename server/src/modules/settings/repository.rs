use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::{Logo, Settings, TeamMemberType},
};

const SETTINGS_TABLE_NAME: &str = "settings";
const SETTINGS_KEY: &str = "settings";
const LOGO_TABLE_NAME: &str = "logo";
const LOGO_KEY: &str = "logo";

pub const DEFAULT_PRIMARY_COLOR: &str = "#009485";
pub const DEFAULT_SECONDARY_COLOR: &str = "#005994";
pub const DEFAULT_NEXT_SESSION_THRESHOLD_SECS: i64 = 4 * 60 * 60; // 4 hours
pub const DEFAULT_START_REMINDER_MINS: i64 = 24 * 60; // 24 hours
pub const DEFAULT_END_REMINDER_MINS: i64 = 15;
pub const DEFAULT_START_REMINDER_MESSAGE: &str =
  "@here Session on {date} from {start_time} to {end_time} @ {location} starting in ~{mins} minutes!";
pub const DEFAULT_END_REMINDER_MESSAGE: &str =
  "@here Session at {location} is ending in ~{mins} minutes \u{2014} don't forget to sign out!";
pub const DEFAULT_OVERTIME_DM_MINS: i64 = 10;
pub const DEFAULT_OVERTIME_DM_MESSAGE: &str = "Hey {username}, you're now in overtime for the session at **{location}**. The session ended at **{end_time}**. Don't forget to check out!";
pub const DEFAULT_AUTO_CHECKOUT_DM_MESSAGE: &str = "Hey {username}, you've been auto-checked-out from the session at **{location}** (ended at **{end_time}**) because a new session is starting soon.";

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

    let default_settings = Settings {
      next_session_threshold_secs: DEFAULT_NEXT_SESSION_THRESHOLD_SECS,
      discord_enabled: false,
      discord_bot_token: String::new(),
      discord_guild_id: String::new(),
      discord_channel_id: String::new(),
      discord_self_link_enabled: false,
      discord_name_sync_enabled: true,
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
      timezone: String::new(),
      primary_color: DEFAULT_PRIMARY_COLOR.to_string(),
      secondary_color: DEFAULT_SECONDARY_COLOR.to_string(),
      leaderboard_show_overtime: true,
      leaderboard_member_types: vec![TeamMemberType::Student as i32, TeamMemberType::Mentor as i32],
    };

    if let Some(s) = table.get::<Settings>(SETTINGS_KEY)? {
      Ok(s)
    } else {
      Self::set(&default_settings)?;
      Ok(default_settings)
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

pub trait LogoRepository {
  fn set(data: &[u8]) -> Result<()>;
  fn get() -> Result<Option<Vec<u8>>>;
  fn clear() -> Result<()>;
}

impl LogoRepository for Logo {
  fn set(data: &[u8]) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(LOGO_TABLE_NAME);
    let logo = Logo { data: data.to_vec() };
    let insert = DataInsert { id: Some(LOGO_KEY.to_string()), value: logo, search_indexes: vec![] };
    table.insert(insert)?;
    Ok(())
  }

  fn get() -> Result<Option<Vec<u8>>> {
    let db = get_db()?;
    let table = db.get_table(LOGO_TABLE_NAME);
    match table.get::<Logo>(LOGO_KEY)? {
      Some(logo) if !logo.data.is_empty() => Ok(Some(logo.data)),
      _ => Ok(None),
    }
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(LOGO_TABLE_NAME);
    table.clear()?;
    Ok(())
  }
}
