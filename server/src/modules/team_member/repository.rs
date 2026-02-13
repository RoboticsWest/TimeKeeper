use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::TeamMember,
};

const TEAM_MEMBER_TABLE_NAME: &str = "team_members";

/// Ensures `display_name` is populated. If empty/missing, fills it from first + last name.
fn fill_display_name(mut member: TeamMember) -> TeamMember {
  if member.display_name.as_ref().is_none_or(String::is_empty) {
    let name = format!("{} {}", member.first_name, member.last_name).trim().to_string();
    if !name.is_empty() {
      member.display_name = Some(name);
    }
  }
  member
}

pub trait TeamMemberRepository {
  fn add(record: &TeamMember) -> Result<(String, TeamMember)>;
  fn update(id: &str, record: &TeamMember) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<TeamMember>>;
  fn get_all() -> Result<HashMap<String, TeamMember>>;
  fn get_by_name(first_name: &str, last_name: &str) -> Result<HashMap<String, TeamMember>>;
  fn clear() -> Result<()>;
}

impl TeamMemberRepository for TeamMember {
  fn add(record: &TeamMember) -> Result<(String, TeamMember)> {
    let record = fill_display_name(record.clone());
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    let mut search_indexes = vec![record.first_name.clone(), record.last_name.clone()];
    if let Some(ref dn) = record.display_name {
      search_indexes.push(dn.clone());
    }
    let data = DataInsert { id: None, value: record.clone(), search_indexes };

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

  fn update(id: &str, record: &TeamMember) -> Result<()> {
    let record = fill_display_name(record.clone());
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    let mut search_indexes = vec![record.first_name.clone(), record.last_name.clone()];
    if let Some(ref dn) = record.display_name {
      search_indexes.push(dn.clone());
    }
    let data = DataInsert { id: Some(id.to_string()), value: record.clone(), search_indexes };

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
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<TeamMember>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<TeamMember>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    Ok(table.get::<TeamMember>(id)?.map(fill_display_name))
  }

  fn get_all() -> Result<HashMap<String, TeamMember>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    Ok(table.get_all::<TeamMember>()?.into_iter().map(|(id, m)| (id, fill_display_name(m))).collect())
  }

  fn get_by_name(first_name: &str, last_name: &str) -> Result<HashMap<String, TeamMember>> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    let members = table.get_by_search_indexes::<TeamMember>(vec![first_name.to_string(), last_name.to_string()])?;
    let members = members
      .into_iter()
      .filter(|(_, m)| m.first_name == first_name && m.last_name == last_name)
      .map(|(id, m)| (id, fill_display_name(m)))
      .collect();
    Ok(members)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(TEAM_MEMBER_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<TeamMember>::Table)?;

    Ok(())
  }
}
