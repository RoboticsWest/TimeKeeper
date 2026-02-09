use std::collections::HashMap;

use anyhow::Result;
use database::DataInsert;

use crate::{
  core::{
    db::get_db,
    events::{ChangeEvent, ChangeOperation, EVENT_BUS},
  },
  generated::db::Location,
};

const LOCATION_TABLE_NAME: &str = "locations";

pub trait LocationRepository {
  fn add(record: &Location) -> Result<(String, Location)>;
  fn update(id: &str, record: &Location) -> Result<()>;
  fn remove(id: &str) -> Result<()>;
  fn get(id: &str) -> Result<Option<Location>>;
  fn get_all() -> Result<HashMap<String, Location>>;
  fn get_by_name(name: &str) -> Result<HashMap<String, Location>>;
  fn clear() -> Result<()>;
}

impl LocationRepository for Location {
  fn add(record: &Location) -> Result<(String, Location)> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    let data = DataInsert { id: None, value: record.clone(), search_indexes: vec![record.location.clone()] };

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

  fn update(id: &str, record: &Location) -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    let data =
      DataInsert { id: Some(id.to_string()), value: record.clone(), search_indexes: vec![record.location.clone()] };

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
    let table = db.get_table(LOCATION_TABLE_NAME);
    table.remove(id)?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Location>::Record {
      operation: ChangeOperation::Delete,
      id: id.to_string(),
      data: None,
    })?;

    Ok(())
  }

  fn get(id: &str) -> Result<Option<Location>> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    table.get(id)
  }

  fn get_all() -> Result<HashMap<String, Location>> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    table.get_all()
  }

  fn get_by_name(name: &str) -> Result<HashMap<String, Location>> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    let locations = table.get_by_search_indexes::<Location>(vec![name.to_string()])?;
    let locations = locations.into_iter().filter(|(_, loc)| loc.location == name).collect();
    Ok(locations)
  }

  fn clear() -> Result<()> {
    let db = get_db()?;
    let table = db.get_table(LOCATION_TABLE_NAME);
    table.clear()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      log::error!("Event bus not initialized");
      return Err(anyhow::anyhow!("Event bus not initialized"));
    };

    event_bus.publish(ChangeEvent::<Location>::Table)?;

    Ok(())
  }
}
