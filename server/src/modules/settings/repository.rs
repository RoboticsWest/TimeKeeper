use anyhow::Result;
use database::DataInsert;

use crate::{core::db::get_db, generated::db::Settings};

const SETTINGS_TABLE_NAME: &str = "settings";
const SETTINGS_KEY: &str = "settings";

pub const DEFAULT_NEXT_SESSION_THRESHOLD_SECS: i64 = 4 * 60 * 60; // 4 hours

pub trait SettingsRepository {
  fn set(record: &Settings) -> Result<()>;
  fn get() -> Result<Settings>;
}

impl SettingsRepository for Settings {
  fn set(record: &Settings) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SETTINGS_TABLE_NAME);
    let data = DataInsert { id: Some(SETTINGS_KEY.to_string()), value: *record, search_indexes: vec![] };
    table.insert(data)?;
    Ok(())
  }

  fn get() -> Result<Settings> {
    let db = get_db()?;
    let table = db.get_table(SETTINGS_TABLE_NAME);

    if let Some(s) = table.get::<Settings>(SETTINGS_KEY)? {
      Ok(s)
    } else {
      let default = Settings { next_session_threshold_secs: DEFAULT_NEXT_SESSION_THRESHOLD_SECS };
      Self::set(&default)?;
      Ok(default)
    }
  }
}
