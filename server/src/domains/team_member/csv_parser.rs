use std::io::{BufRead, BufReader};

use anyhow::{Result, anyhow};

/// One parsed row from a team member import CSV.
pub struct TeamMemberCsvRow {
  pub first_name: String,
  pub last_name: String,
  pub display_name: Option<String>,
  pub rfid_tag: Option<String>,
  pub discord_username: Option<String>,
}

pub struct TeamMemberCsvParser;

impl TeamMemberCsvParser {
  /// Parses a CSV of the form `FIRST_NAME,LAST_NAME,DISPLAY_NAME,RFID_TAG,DISCORD_USERNAME`
  /// (header row optional - skipped automatically if present). Used by
  /// `UploadStudentCsv`/`UploadMentorCsv`.
  pub fn parse(csv: &str) -> Result<Vec<TeamMemberCsvRow>> {
    let reader = BufReader::new(csv.as_bytes());
    let lines = reader.lines();

    let mut members: Vec<TeamMemberCsvRow> = Vec::new();

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

      let display_name = fields.get(2).map(|a| a.trim().to_string()).filter(|a| !a.is_empty());
      let rfid_tag = fields.get(3).map(|a| a.trim().to_string()).filter(|a| !a.is_empty());
      let discord_username = fields.get(4).map(|a| a.trim().to_string()).filter(|a| !a.is_empty());

      members.push(TeamMemberCsvRow { first_name, last_name, display_name, rfid_tag, discord_username });
    }

    Ok(members)
  }
}
