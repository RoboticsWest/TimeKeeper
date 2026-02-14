use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::{Notification, NotificationType},
};

const NOTIFICATION_TABLE_NAME: &str = "notifications";

pub trait NotificationRepository {
  fn add(record: &Notification) -> Result<(String, Notification)>;
  fn update(id: &str, record: &Notification) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<Notification>>;
  fn get_all() -> Result<HashMap<String, Notification>>;
  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, Notification>>;
  fn exists(notification_type: NotificationType, session_id: &str, team_member_id: Option<&str>) -> Result<bool>;
  fn get_unsent() -> Result<Vec<(String, Notification)>>;
  fn clear() -> Result<()>;
}

impl NotificationRepository for Notification {
  fn add(record: &Notification) -> Result<(String, Notification)> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![record.session_id.clone()] };

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

  fn update(id: &str, record: &Notification) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    let data =
      DataInsert { id: Some(id.to_string()), value: record.clone(), search_indexes: vec![record.session_id.clone()] };

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
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Notification>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<Notification>> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, Notification>> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    table.get_all()
  }

  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, Notification>> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    let results = table.get_by_search_indexes::<Notification>(vec![session_id.to_string()])?;
    let results = results.into_iter().filter(|(_, n)| n.session_id == session_id).collect();
    Ok(results)
  }

  fn exists(notification_type: NotificationType, session_id: &str, team_member_id: Option<&str>) -> Result<bool> {
    let all = Self::get_by_session_id(session_id)?;
    let exists = all.values().any(|n| {
      n.notification_type == notification_type as i32
        && match team_member_id {
          Some(mid) => n.team_member_id.as_deref() == Some(mid),
          None => n.team_member_id.is_none(),
        }
    });
    Ok(exists)
  }

  fn get_unsent() -> Result<Vec<(String, Notification)>> {
    let all = Self::get_all()?;
    Ok(all.into_iter().filter(|(_, n)| !n.sent).collect())
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(NOTIFICATION_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Notification>::Table)?;

    Ok(())
  }
}
