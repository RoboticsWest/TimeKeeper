use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::Session,
};

const SESSION_TABLE_NAME: &str = "sessions";

pub trait SessionRepository {
  fn add(record: &Session) -> Result<(String, Session)>;
  fn update(id: &str, record: &Session) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<Session>>;
  fn get_all() -> Result<HashMap<String, Session>>;
  fn clear() -> Result<()>;
}

impl SessionRepository for Session {
  fn add(record: &Session) -> Result<(String, Session)> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![] };

    let id = table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::Record {
      operation: ChangeOperation::Create,
      id: id.clone(),
      data: Some(record.clone()),
    })?;

    Ok((id, record.clone()))
  }

  fn update(id: &str, record: &Session) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    let data = DataInsert { id: Some(id.to_string()), value: record.clone(), search_indexes: vec![] };

    table.insert(data)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::Record {
      operation: ChangeOperation::Update,
      id: id.to_string(),
      data: Some(record.clone()),
    })?;

    Ok(())
  }

  fn remove(id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Session>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<Session>> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, Session>> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    table.get_all()
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Session>::Table)?;

    Ok(())
  }
}
