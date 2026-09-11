use std::sync::Arc;

use crate::domains::location::LocationLogic;
use crate::domains::session::SessionLogic;
use crate::domains::session_rsvp::{SessionRsvpLogic, SessionRsvpMessageLogic};
use crate::domains::settings::SettingsLogic;
use crate::domains::statistics::StatisticsLogic;
use crate::domains::team_member::TeamMemberLogic;
use crate::domains::team_member_session::TeamMemberSessionLogic;

/// Domain dependencies the live gateway bot (chat commands + RSVP reactions) needs. Cheap to
/// clone (every field is an `Arc`).
#[derive(Clone)]
pub struct DiscordDeps {
  pub team_members: Arc<dyn TeamMemberLogic>,
  pub team_member_sessions: Arc<dyn TeamMemberSessionLogic>,
  pub sessions: Arc<dyn SessionLogic>,
  pub locations: Arc<dyn LocationLogic>,
  pub settings: Arc<dyn SettingsLogic>,
  pub statistics: Arc<dyn StatisticsLogic>,
  pub session_rsvps: Arc<dyn SessionRsvpLogic>,
  pub session_rsvp_messages: Arc<dyn SessionRsvpMessageLogic>,
}
