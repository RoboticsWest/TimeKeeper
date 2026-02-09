use std::io::{BufRead, BufReader};

use anyhow::{Result, anyhow};

use crate::modules::team_member::TeamMemberT;

pub struct TeamMemberCsvParser;

impl TeamMemberCsvParser {
  pub fn csv_to_team_members(csv: &str) -> Result<Vec<TeamMemberT>> {
    let reader = BufReader::new(csv.as_bytes());
    let lines = reader.lines();

    // row format
    // FIRST_NAME, LAST_NAME, ALIAS, SECONDARY_ALIAS
    let mut members: Vec<TeamMemberT> = Vec::new();

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

      let alias = fields.get(2).map(|a| a.trim().to_string()).filter(|a| !a.is_empty());
      let secondary_alias = fields.get(3).map(|a| a.trim().to_string()).filter(|a| !a.is_empty());

      members.push(TeamMemberT { first_name, last_name, alias, secondary_alias });
    }

    Ok(members)
  }
}
