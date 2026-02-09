mod api;
use anyhow::Result;
pub use api::*;

use crate::{generated::common::TkDateTime, modules::schedule::csv_parser::CsvParser};

mod csv_parser;

pub struct ScheduleSessionT {
  pub start_time: TkDateTime,
  pub end_time: TkDateTime,
  pub location_name: String,
}

pub struct Schedule {
  pub sessions: Vec<ScheduleSessionT>,
  pub locations: Vec<String>,
}

impl Schedule {
  pub fn from_csv(csv: &str) -> Result<Schedule> {
    CsvParser::csv_to_schedule(csv)
  }

  // pub fn from_ics(ics: &str) -> Result<Schedule> {}
}
