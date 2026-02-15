use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::{SessionRsvp, SessionRsvpMessage},
};

const SESSION_RSVP_TABLE_NAME: &str = "session_rsvps";
const SESSION_RSVP_MESSAGE_TABLE_NAME: &str = "session_rsvp_messages";

pub trait SessionRsvpRepository {
  fn upsert(session_id: &str, team_member_id: &str, status: i32) -> Result<()>;
  fn remove_by_session_and_member(session_id: &str, team_member_id: &str) -> Result<()>;
  fn get_all() -> Result<HashMap<String, SessionRsvp>>;
  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, SessionRsvp>>;
  fn clear() -> Result<()>;
}

impl SessionRsvpRepository for SessionRsvp {
  fn upsert(session_id: &str, team_member_id: &str, status: i32) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_TABLE_NAME);

    // Check if an RSVP already exists for this session+member
    let existing = table.get_by_search_indexes::<SessionRsvp>(vec![session_id.to_string()])?;
    let found = existing.into_iter().find(|(_, r)| r.team_member_id == team_member_id);

    let record = SessionRsvp { session_id: session_id.to_string(), team_member_id: team_member_id.to_string(), status };

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    if let Some((existing_id, _)) = found {
      // Update existing
      let data = DataInsert {
        id: Some(existing_id.clone()),
        value: record.clone(),
        search_indexes: vec![session_id.to_string()],
      };
      table.insert(data)?;

      event_bus.publish(ChangeEvent::Record {
        operation: ChangeOperation::Update,
        id: existing_id,
        data: Some(record),
      })?;
    } else {
      // Insert new
      let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![session_id.to_string()] };
      let id = table.insert(data)?;

      event_bus.publish(ChangeEvent::Record { operation: ChangeOperation::Create, id, data: Some(record) })?;
    }

    Ok(())
  }

  fn remove_by_session_and_member(session_id: &str, team_member_id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_TABLE_NAME);

    let existing = table.get_by_search_indexes::<SessionRsvp>(vec![session_id.to_string()])?;
    let found = existing.into_iter().find(|(_, r)| r.team_member_id == team_member_id);

    if let Some((id, _)) = found {
      table.remove(&id)?;

      let Some(event_bus) = EVENT_BUS.get() else {
        return Err(anyhow::anyhow!("Event bus not initialized"));
      };

      event_bus.publish(ChangeEvent::<SessionRsvp>::Record { operation: ChangeOperation::Delete, id, data: None })?;
    }

    Ok(())
  }

  fn get_all() -> Result<HashMap<String, SessionRsvp>> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_TABLE_NAME);
    table.get_all()
  }

  fn get_by_session_id(session_id: &str) -> Result<HashMap<String, SessionRsvp>> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_TABLE_NAME);
    let results = table.get_by_search_indexes::<SessionRsvp>(vec![session_id.to_string()])?;
    let results = results.into_iter().filter(|(_, r)| r.session_id == session_id).collect();
    Ok(results)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<SessionRsvp>::Table)?;

    Ok(())
  }
}

pub trait SessionRsvpMessageRepository {
  fn set(discord_message_id: &str, session_id: &str) -> Result<()>;
  fn get_by_message_id(discord_message_id: &str) -> Result<Option<SessionRsvpMessage>>;
  fn clear() -> Result<()>;
}

impl SessionRsvpMessageRepository for SessionRsvpMessage {
  fn set(discord_message_id: &str, session_id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_MESSAGE_TABLE_NAME);
    let record =
      SessionRsvpMessage { discord_message_id: discord_message_id.to_string(), session_id: session_id.to_string() };
    let data = DataInsert { id: Some(discord_message_id.to_string()), value: record, search_indexes: vec![] };
    table.insert(data)?;
    Ok(())
  }

  fn get_by_message_id(discord_message_id: &str) -> Result<Option<SessionRsvpMessage>> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_MESSAGE_TABLE_NAME);
    table.get(discord_message_id)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(SESSION_RSVP_MESSAGE_TABLE_NAME);
    table.clear()?;
    Ok(())
  }
}
