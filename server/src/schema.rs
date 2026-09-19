use async_graphql::{MergedObject, MergedSubscription, Schema};

use crate::domains::location::{LocationMutation, LocationQuery, LocationSubscription};
use crate::domains::notification::{NotificationMutation, NotificationQuery, NotificationSubscription};
use crate::domains::rfid_tag::{RfidTagMutation, RfidTagQuery, RfidTagSubscription};
use crate::domains::schedule::ScheduleMutation;
use crate::domains::session::{SessionMutation, SessionQuery, SessionSubscription};
use crate::domains::session_rsvp::{SessionRsvpQuery, SessionRsvpSubscription};
use crate::domains::settings::{LogoSubscription, SettingsMutation, SettingsQuery, SettingsSubscription};
use crate::domains::statistics::StatisticsQuery;
use crate::domains::team_member::{TeamMemberMutation, TeamMemberQuery, TeamMemberSubscription};
use crate::domains::team_member_session::{
  TeamMemberSessionMutation, TeamMemberSessionQuery, TeamMemberSessionSubscription,
};
use crate::domains::user::{UserMutation, UserQuery, UserSubscription};
use crate::version::VersionQuery;

#[derive(MergedObject, Default)]
pub struct QueryRoot(
  LocationQuery,
  NotificationQuery,
  RfidTagQuery,
  SessionQuery,
  SessionRsvpQuery,
  SettingsQuery,
  StatisticsQuery,
  TeamMemberQuery,
  TeamMemberSessionQuery,
  UserQuery,
  VersionQuery,
);

#[derive(MergedObject, Default)]
pub struct MutationRoot(
  LocationMutation,
  NotificationMutation,
  RfidTagMutation,
  ScheduleMutation,
  SessionMutation,
  SettingsMutation,
  TeamMemberMutation,
  TeamMemberSessionMutation,
  UserMutation,
);

#[derive(MergedSubscription, Default)]
pub struct SubscriptionRoot(
  LocationSubscription,
  NotificationSubscription,
  RfidTagSubscription,
  SessionSubscription,
  SessionRsvpSubscription,
  SettingsSubscription,
  LogoSubscription,
  TeamMemberSubscription,
  TeamMemberSessionSubscription,
  UserSubscription,
);

pub type AppSchema = Schema<QueryRoot, MutationRoot, SubscriptionRoot>;
