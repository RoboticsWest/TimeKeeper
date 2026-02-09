use std::io::{BufRead, BufReader};

use anyhow::{Result, anyhow};
use chrono::{Datelike, Timelike};

use crate::{
  generated::common::{TkDate, TkDateTime, TkTime},
  modules::schedule::{Schedule, ScheduleSessionT},
};

pub struct CsvParser;

impl CsvParser {
  pub fn csv_to_schedule(csv: &str) -> Result<Schedule> {
    let reader = BufReader::new(csv.as_bytes());
    let lines = reader.lines();

    // row format
    // LOCATION, START_DATE_TIME, END_DATE_TIME
    let mut locations: Vec<String> = Vec::new();
    let mut sessions: Vec<ScheduleSessionT> = Vec::new();

    for line in lines {
      let Ok(line) = line else { return Err(anyhow!("Could not parse line")) };

      let fields = line.split(',').collect::<Vec<&str>>();
      if fields.first() == Some(&"LOCATION") {
        continue; // skip header row
      }

      // Location
      let location: String = match fields.get(1) {
        Some(location) => (*location).to_string(),
        None => return Err(anyhow!("Could not parse location")),
      };
      locations.push(location.clone());

      // Session
      let start_time = match fields.get(2) {
        Some(time) => (*time).to_string(),
        None => return Err(anyhow!("Could not parse start time")),
      };
      let start_time = match start_time.parse::<chrono::NaiveDateTime>() {
        Ok(time) => TkDateTime {
          date: Some(TkDate { year: time.year(), month: time.month(), day: time.day() }),
          time: Some(TkTime { hour: time.hour(), minute: time.minute(), second: time.second() }),
        },
        Err(_) => TkDateTime { date: None, time: None },
      };

      let end_time = match fields.get(3) {
        Some(time) => (*time).to_string(),
        None => "session_end_time".to_string(),
      };
      let end_time = match end_time.parse::<chrono::NaiveDateTime>() {
        Ok(time) => TkDateTime {
          date: Some(TkDate { year: time.year(), month: time.month(), day: time.day() }),
          time: Some(TkTime { hour: time.hour(), minute: time.minute(), second: time.second() }),
        },
        Err(_) => TkDateTime { date: None, time: None },
      };
      sessions.push(ScheduleSessionT { start_time, end_time, location_name: location });
    }

    Ok(Schedule { sessions, locations })
  }
}
