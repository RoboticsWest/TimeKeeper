use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::TeamMemberSession,
};

const TEAM_MEMBER_SESSION_TABLE_NAME: &str = "team_member_sessions";

pub trait TeamMemberSessionRepository {
  fn add(record: &TeamMemberSession) -> Result<(String, TeamMemberSession)>;
  fn update(id: &str, record: &TeamMemberSession) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<TeamMemberSession>>;
  fn get_all() -> Result<HashMap<String, TeamMemberSession>>;
  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, TeamMemberSession>>;
  fn get_by_member_id(member_id: &str) -> Result<HashMap<String, TeamMemberSession>>;
  fn clear() -> Result<()>;
}

impl TeamMemberSessionRepository for TeamMemberSession {
  fn add(record: &TeamMemberSession) -> Result<(String, TeamMemberSession)> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.team_member_id.clone(), record.session_id.clone()],
    };

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

  fn update(id: &str, record: &TeamMemberSession) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    let data = DataInsert {
      id: Some(id.to_string()),
      value: record.clone(),
      search_indexes: vec![record.team_member_id.clone(), record.session_id.clone()],
    };

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
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<TeamMemberSession>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<TeamMemberSession>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, TeamMemberSession>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    table.get_all()
  }

  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, TeamMemberSession>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    let results = table.get_by_search_indexes::<TeamMemberSession>(vec![session_id.to_string()])?;
    let results = results.into_iter().filter(|(_, ms)| ms.session_id == session_id).collect();
    Ok(results)
  }

  fn get_by_member_id(member_id: &str) -> Result<HashMap<String, TeamMemberSession>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    let results = table.get_by_search_indexes::<TeamMemberSession>(vec![member_id.to_string()])?;
    let results = results.into_iter().filter(|(_, ms)| ms.team_member_id == member_id).collect();
    Ok(results)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_SESSION_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<TeamMemberSession>::Table)?;

    Ok(())
  }
}
