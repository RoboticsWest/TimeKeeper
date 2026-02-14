use std::io::{BufRead, BufReader};

use anyhow::{Result, anyhow};
use chrono::DateTime;

use crate::generated::common::Timestamp;

pub struct AttendanceRecord {
  pub first_name: String,
  pub last_name: String,
  pub location: String,
  pub check_in_time: Timestamp,
  pub check_out_time: Option<Timestamp>,
}

fn parse_datetime(s: &str) -> Result<Timestamp> {
  if let Ok(dt) = DateTime::parse_from_rfc3339(s) {
    return Ok(Timestamp { seconds: dt.timestamp(), nanos: 0 });
  }

  if let Ok(naive) = s.parse::<chrono::NaiveDateTime>() {
    return Ok(Timestamp { seconds: naive.and_utc().timestamp(), nanos: 0 });
  }

  Err(anyhow!("Could not parse datetime: {}", s))
}

pub struct AttendanceCsvParser;

impl AttendanceCsvParser {
  pub fn parse(csv: &str) -> Result<Vec<AttendanceRecord>> {
    let reader = BufReader::new(csv.as_bytes());
    let lines = reader.lines();

    // FIRST_NAME,LAST_NAME,LOCATION,CHECK_IN_TIME,CHECK_OUT_TIME
    let mut records: Vec<AttendanceRecord> = Vec::new();

    for line in lines {
      let Ok(line) = line else { return Err(anyhow!("Could not parse line")) };

      let fields = line.split(',').collect::<Vec<&str>>();
      if fields.first() == Some(&"FIRST_NAME") {
        continue; // skip header row
      }

      let first_name = match fields.first() {
        Some(name) => name.trim().to_string(),
        None => return Err(anyhow!("Could not parse first name")),
      };

      let last_name = match fields.get(1) {
        Some(name) => name.trim().to_string(),
        None => return Err(anyhow!("Could not parse last name")),
      };

      let location = match fields.get(2) {
        Some(loc) => loc.trim().to_string(),
        None => return Err(anyhow!("Could not parse location")),
      };

      let check_in_time = match fields.get(3) {
        Some(time) => parse_datetime(time.trim())?,
        None => return Err(anyhow!("Could not parse check-in time")),
      };

      let check_out_time = fields.get(4).map(|s| s.trim()).filter(|s| !s.is_empty()).map(parse_datetime).transpose()?;

      records.push(AttendanceRecord { first_name, last_name, location, check_in_time, check_out_time });
    }

    Ok(records)
  }
}
