use std::io::{BufRead, BufReader};

use anyhow::{Result, anyhow};
use chrono::{DateTime, Utc};

use super::model::{Schedule, ScheduleSession};

/// Parse a datetime string. Tries RFC 3339 first (with timezone offset or Z), then falls back to
/// naive (treated as UTC).
fn parse_datetime(s: &str) -> Result<DateTime<Utc>> {
  if let Ok(dt) = DateTime::parse_from_rfc3339(s) {
    return Ok(dt.with_timezone(&Utc));
  }

  if let Ok(naive) = s.parse::<chrono::NaiveDateTime>() {
    return Ok(naive.and_utc());
  }

  Err(anyhow!("Could not parse datetime: {}", s))
}

pub fn csv_to_schedule(csv: &str) -> Result<Schedule> {
  let reader = BufReader::new(csv.as_bytes());
  let lines = reader.lines();

  // row format: LOCATION, START_DATE_TIME, END_DATE_TIME
  let mut locations: Vec<String> = Vec::new();
  let mut sessions: Vec<ScheduleSession> = Vec::new();

  for line in lines {
    let Ok(line) = line else { return Err(anyhow!("Could not parse line")) };

    let fields = line.split(',').collect::<Vec<&str>>();
    if fields.first() == Some(&"LOCATION") {
      continue; // skip header row
    }

    let location: String = match fields.first() {
      Some(location) => (*location).to_string(),
      None => return Err(anyhow!("Could not parse location")),
    };
    locations.push(location.clone());

    let start_time = match fields.get(1) {
      Some(time) => parse_datetime(time.trim())?,
      None => return Err(anyhow!("Could not parse start time")),
    };

    let end_time = match fields.get(2) {
      Some(time) => parse_datetime(time.trim())?,
      None => return Err(anyhow!("Could not parse end time")),
    };

    sessions.push(ScheduleSession { start_time, end_time, location_name: location });
  }

  Ok(Schedule { sessions, locations })
}
