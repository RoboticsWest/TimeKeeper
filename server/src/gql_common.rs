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

/// How many rows a page query returns when the caller doesn't say, and the ceiling it is
/// clamped to.
///
/// A cap matters here: attendance grows without bound (tens of thousands of rows within a
/// season), and an uncapped `limit` lets one query pull the whole table into memory — exactly
/// the problem pagination exists to prevent.
pub const DEFAULT_PAGE_SIZE: i64 = 50;
pub const MAX_PAGE_SIZE: i64 = 500;

/// Normalises caller-supplied paging arguments into a safe `(limit, offset)`.
///
/// Negative values are meaningless rather than an error worth failing a query over, so they
/// clamp to the nearest sane value.
pub fn page_bounds(offset: Option<i32>, limit: Option<i32>) -> (i64, i64) {
  let limit = limit.map_or(DEFAULT_PAGE_SIZE, i64::from).clamp(1, MAX_PAGE_SIZE);
  let offset = i64::from(offset.unwrap_or(0)).max(0);
  (limit, offset)
}

/// One page of `T`, with enough context for a pager to render itself.
///
/// `total_count` is the number of rows matching the *filter*, not the page, so the UI can show
/// "51-100 of 1,284" and know whether a next page exists without asking for it.
#[derive(SimpleObject)]
#[graphql(concrete(name = "SessionPage", params(Session)))]
#[graphql(concrete(name = "TeamMemberPage", params(TeamMember)))]
#[graphql(concrete(name = "AttendancePage", params(TeamMemberSession)))]
pub struct Page<T: OutputType> {
  pub items: Vec<T>,
  /// Rows matching the filter across every page.
  pub total_count: i32,
  /// The offset these items start at, echoed back so a client can't desync its pager.
  pub offset: i32,
  pub limit: i32,
  /// Whether another page follows.
  pub has_more: bool,
}

impl<T: OutputType> Page<T> {
  pub fn new(items: Vec<T>, total_count: i64, offset: i64, limit: i64) -> Self {
    let has_more = offset + i64::try_from(items.len()).unwrap_or(0) < total_count;
    Self {
      items,
      total_count: i32::try_from(total_count).unwrap_or(i32::MAX),
      offset: i32::try_from(offset).unwrap_or(i32::MAX),
      limit: i32::try_from(limit).unwrap_or(i32::MAX),
      has_more,
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn omitted_paging_uses_the_default_page_size() {
    assert_eq!(page_bounds(None, None), (DEFAULT_PAGE_SIZE, 0));
  }

  /// The cap is the whole point: attendance grows without bound, so one query must not be
  /// able to pull the entire table.
  #[test]
  fn an_oversized_limit_is_capped() {
    assert_eq!(page_bounds(None, Some(100_000)), (MAX_PAGE_SIZE, 0));
  }

  #[test]
  fn nonsense_paging_clamps_rather_than_failing() {
    assert_eq!(page_bounds(Some(-5), Some(0)), (1, 0));
    assert_eq!(page_bounds(Some(-5), Some(-20)), (1, 0));
  }

  #[test]
  fn explicit_paging_is_passed_through() {
    assert_eq!(page_bounds(Some(100), Some(25)), (25, 100));
  }

  #[test]
  fn has_more_is_false_on_the_last_page() {
    let page = Page::new(vec![1, 2, 3], 103, 100, 50);
    assert!(!page.has_more);
    assert_eq!(page.total_count, 103);
  }

  #[test]
  fn has_more_is_true_when_rows_remain() {
    let page = Page::new(vec![1, 2, 3], 500, 0, 3);
    assert!(page.has_more);
  }

  #[test]
  fn an_empty_result_has_no_next_page() {
    let page: Page<i32> = Page::new(vec![], 0, 0, 50);
    assert!(!page.has_more);
    assert_eq!(page.total_count, 0);
  }
}
