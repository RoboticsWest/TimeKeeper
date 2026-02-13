mod api;
use anyhow::Result;
pub use api::*;

mod repository;
pub use repository::*;

mod csv_parser;

use crate::modules::team_member::csv_parser::TeamMemberCsvParser;

pub struct TeamMemberT {
  pub first_name: String,
  pub last_name: String,
  pub display_name: Option<String>,
  pub rfid_tag: Option<String>,
  pub discord_username: Option<String>,
}

pub struct TeamMemberImportList {
  pub members: Vec<TeamMemberT>,
}

impl TeamMemberImportList {
  pub fn from_csv(csv: &str) -> Result<TeamMemberImportList> {
    let members = TeamMemberCsvParser::csv_to_team_members(csv)?;
    Ok(TeamMemberImportList { members })
  }
}
