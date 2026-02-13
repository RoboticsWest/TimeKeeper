use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::RfidTag,
};

const RFID_TAG_TABLE_NAME: &str = "rfid_tags";

pub trait RfidTagRepository {
  fn add(record: &RfidTag) -> Result<(String, RfidTag)>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<RfidTag>>;
  fn get_all() -> Result<HashMap<String, RfidTag>>;
  fn get_by_member_id(member_id: &str) -> Result<HashMap<String, RfidTag>>;
  fn get_by_tag(tag: &str) -> Result<HashMap<String, RfidTag>>;
  fn clear() -> Result<()>;
}

impl RfidTagRepository for RfidTag {
  fn add(record: &RfidTag) -> Result<(String, RfidTag)> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    let data = DataInsert {
      id: None,
      value: record.clone(),
      search_indexes: vec![record.team_member_id.clone(), record.tag.clone()],
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

  fn remove(id: &str) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<RfidTag>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<RfidTag>> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, RfidTag>> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    table.get_all()
  }

  fn get_by_member_id(member_id: &str) -> Result<HashMap<String, RfidTag>> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    let results = table.get_by_search_indexes::<RfidTag>(vec![member_id.to_string()])?;
    let results = results.into_iter().filter(|(_, rt)| rt.team_member_id == member_id).collect();
    Ok(results)
  }

  fn get_by_tag(tag: &str) -> Result<HashMap<String, RfidTag>> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    let results = table.get_by_search_indexes::<RfidTag>(vec![tag.to_string()])?;
    let results = results.into_iter().filter(|(_, rt)| rt.tag == tag).collect();
    Ok(results)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(RFID_TAG_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<RfidTag>::Table)?;

    Ok(())
  }
}
