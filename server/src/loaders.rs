//! GraphQL data loaders: the batching layer behind the schema's nested relationships.
//!
//! Every foreign key in the database is exposed as a nested field, in both directions — an
//! attendance row resolves its `teamMember` and `session`, a session resolves its `attendance`,
//! `notifications` and `rsvps`, and so on. That is what lets a view ask for the shape it renders in
//! one request instead of holding local copies of half the schema to look ids up in.
//!
//! A relational schema has one hazard, and it is the whole reason this module exists. When a page of
//! fifty attendance rows each resolves `teamMember`, the naive resolver runs fifty
//! `SELECT ... WHERE id = $1` statements — the N+1 problem. A [`DataLoader`] collects the ids
//! requested within one resolution pass and answers them with a single `WHERE ... = ANY($1)`, so a
//! page of any size costs one query per relationship *level* rather than one per row.
//!
//! Loaders are built per request, not once for the schema. Their cache is what makes a repeated id
//! free within one query — and exactly what would serve stale rows if it outlived the request.

use std::collections::HashMap;
use std::sync::Arc;

use async_graphql::dataloader::Loader;
use uuid::Uuid;

use crate::domains::location::{Location, LocationRepository};
use crate::domains::notification::{Notification, NotificationRepository};
use crate::domains::rfid_tag::{RfidTag, RfidTagRepository};
use crate::domains::session::{Session, SessionRepository};
use crate::domains::session_rsvp::{SessionRsvp, SessionRsvpRepository};
use crate::domains::statistics::{AttendanceStats, MemberStatsRepository, TeamMemberStats};
use crate::domains::team_member::{TeamMember, TeamMemberRepository};
use crate::domains::team_member_session::{TeamMemberSession, TeamMemberSessionRepository};

/// Errors are shared rather than owned because a data loader hands the same failure to every caller
/// that was waiting on the batch.
type LoadError = Arc<anyhow::Error>;

/// A loader for a *belongs-to* relationship: many rows point at one parent, keyed by its id.
macro_rules! id_loader {
  ($name:ident, $repo:path, $model:ty, $method:ident, $doc:literal) => {
    #[doc = $doc]
    pub struct $name(pub Arc<dyn $repo>);

    impl Loader<Uuid> for $name {
      type Value = $model;
      type Error = LoadError;

      async fn load(&self, keys: &[Uuid]) -> Result<HashMap<Uuid, Self::Value>, Self::Error> {
        let rows = self.0.$method(keys).await.map_err(Arc::new)?;
        Ok(rows.into_iter().map(|row| (row.id, row)).collect())
      }
    }
  };
}

/// A loader for a one-row-per-parent relationship whose key column is not called `id`.
macro_rules! keyed_loader {
  ($name:ident, $repo:path, $model:ty, $method:ident, $key:expr, $doc:literal) => {
    #[doc = $doc]
    pub struct $name(pub Arc<dyn $repo>);

    impl Loader<Uuid> for $name {
      type Value = $model;
      type Error = LoadError;

      async fn load(&self, keys: &[Uuid]) -> Result<HashMap<Uuid, Self::Value>, Self::Error> {
        let rows = self.0.$method(keys).await.map_err(Arc::new)?;
        let extract: fn(&$model) -> Uuid = $key;
        Ok(rows.into_iter().map(|row| (extract(&row), row)).collect())
      }
    }
  };
}

/// A loader for a *has-many* relationship: rows grouped under the foreign key they point at.
///
/// Keys with no rows resolve to an empty list rather than null, which is what a GraphQL list field
/// should say about a parent that simply has no children. `$key` may return `None` for a nullable
/// foreign key — those rows belong to nobody and are dropped.
macro_rules! fk_loader {
  ($name:ident, $repo:path, $model:ty, $method:ident, $key:expr, $doc:literal) => {
    #[doc = $doc]
    pub struct $name(pub Arc<dyn $repo>);

    impl Loader<Uuid> for $name {
      type Value = Vec<$model>;
      type Error = LoadError;

      async fn load(&self, keys: &[Uuid]) -> Result<HashMap<Uuid, Self::Value>, Self::Error> {
        let rows = self.0.$method(keys).await.map_err(Arc::new)?;
        let mut grouped: HashMap<Uuid, Vec<$model>> = keys.iter().map(|key| (*key, Vec::new())).collect();
        for row in rows {
          let extract: fn(&$model) -> Option<Uuid> = $key;
          if let Some(key) = extract(&row) {
            grouped.entry(key).or_default().push(row);
          }
        }
        Ok(grouped)
      }
    }
  };
}

// --- belongs-to ---------------------------------------------------------------------------------
id_loader!(TeamMemberLoader, TeamMemberRepository, TeamMember, get_many, "Batches `teamMember` by id.");
id_loader!(SessionLoader, SessionRepository, Session, get_many, "Batches `session` by id.");
id_loader!(LocationLoader, LocationRepository, Location, get_many, "Batches `location` by id.");
id_loader!(
  AttendanceLoader,
  TeamMemberSessionRepository,
  TeamMemberSession,
  get_many,
  "Batches `teamMemberSession` by id."
);

// --- has-many -----------------------------------------------------------------------------------
fk_loader!(
  MemberAttendanceLoader,
  TeamMemberSessionRepository,
  TeamMemberSession,
  get_many_by_team_member_ids,
  |row| Some(row.team_member_id),
  "Batches a member's attendance history."
);
fk_loader!(
  SessionAttendanceLoader,
  TeamMemberSessionRepository,
  TeamMemberSession,
  get_many_by_session_ids,
  |row| Some(row.session_id),
  "Batches a session's attendance."
);
fk_loader!(
  MemberRfidTagsLoader,
  RfidTagRepository,
  RfidTag,
  get_many_by_team_member_ids,
  |row| Some(row.team_member_id),
  "Batches a member's RFID tags."
);
fk_loader!(
  SessionRsvpsLoader,
  SessionRsvpRepository,
  SessionRsvp,
  get_many_by_session_ids,
  |row| Some(row.session_id),
  "Batches a session's RSVPs."
);
fk_loader!(
  MemberRsvpsLoader,
  SessionRsvpRepository,
  SessionRsvp,
  get_many_by_team_member_ids,
  |row| Some(row.team_member_id),
  "Batches a member's RSVPs."
);
fk_loader!(
  SessionNotificationsLoader,
  NotificationRepository,
  Notification,
  get_many_by_session_ids,
  |row| Some(row.session_id),
  "Batches a session's notifications."
);
fk_loader!(
  MemberNotificationsLoader,
  NotificationRepository,
  Notification,
  get_many_by_team_member_ids,
  |row| row.team_member_id,
  "Batches the per-member notifications aimed at a member."
);
fk_loader!(
  LocationSessionsLoader,
  SessionRepository,
  Session,
  get_many_by_location_ids,
  |row| Some(row.location_id),
  "Batches the sessions held at a location."
);

// --- recorded statistics (one row per parent, keyed by the parent's id) --------------------------
keyed_loader!(
  MemberStatsLoader,
  MemberStatsRepository,
  TeamMemberStats,
  get_many_members,
  |row| row.team_member_id,
  "Batches a member's recorded counters."
);
keyed_loader!(
  AttendanceStatsLoader,
  MemberStatsRepository,
  AttendanceStats,
  get_many_attendance,
  |row| row.team_member_session_id,
  "Batches what was recorded about an attendance."
);
