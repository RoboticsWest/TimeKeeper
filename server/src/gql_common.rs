use async_graphql::{ID, OutputType, SimpleObject};

use crate::domains::location::Location;
use crate::domains::notification::Notification;
use crate::domains::rfid_tag::RfidTag;
use crate::domains::session::Session;
use crate::domains::session_rsvp::SessionRsvp;
use crate::domains::team_member::TeamMember;
use crate::domains::team_member_session::TeamMemberSession;
use crate::domains::user::User;
use crate::events::ChangeOperation;

/// One row changed in a subscribed table. `data` is the freshly re-fetched row (never the stale
/// NOTIFY payload) and is `None` for `Delete` - there's nothing left to fetch.
#[derive(SimpleObject)]
#[graphql(concrete(name = "LocationChange", params(Location)))]
#[graphql(concrete(name = "NotificationChange", params(Notification)))]
#[graphql(concrete(name = "RfidTagChange", params(RfidTag)))]
#[graphql(concrete(name = "SessionChange", params(Session)))]
#[graphql(concrete(name = "SessionRsvpChange", params(SessionRsvp)))]
#[graphql(concrete(name = "TeamMemberChange", params(TeamMember)))]
#[graphql(concrete(name = "TeamMemberSessionChange", params(TeamMemberSession)))]
#[graphql(concrete(name = "UserChange", params(User)))]
pub struct Change<T: OutputType> {
  pub operation: ChangeOperation,
  pub id: ID,
  pub data: Option<T>,
}
