use std::time::Duration;

use crate::{
  core::scheduler::ScheduledService,
  generated::db::Session,
  modules::session::{
    SessionRepository,
    helpers::{
      check_out_all_members, get_next_session_threshold_secs, get_unfinished_sessions_sorted, has_checked_in_members,
      now_timestamp,
    },
  },
};

pub struct SessionService;

impl ScheduledService for SessionService {
  fn interval(&self) -> Duration {
    Duration::from_secs(5)
  }

  fn name(&self) -> &'static str {
    "SessionService"
  }

  fn warning_threshold(&self) -> Option<Duration> {
    Some(Duration::from_millis(250))
  }

  fn execute(&mut self) -> anyhow::Result<()> {
    let now = now_timestamp();
    let now_secs = now.seconds;
    let threshold = get_next_session_threshold_secs();

    let mut unfinished = get_unfinished_sessions_sorted()?;

    for i in 0..unfinished.len() {
      let end_secs = match &unfinished[i].1.end_time {
        Some(t) => t.seconds,
        None => continue,
      };

      // Only process sessions that are past their end time
      if now_secs <= end_secs {
        continue;
      }

      if has_checked_in_members(&unfinished[i].1) {
        // Has lingering members — check if next session is within threshold
        let next_start_secs = unfinished.get(i + 1).and_then(|(_, next)| next.start_time.as_ref().map(|t| t.seconds));

        let should_force_finish = match next_start_secs {
          Some(next_start) => {
            let time_until_next = next_start - now_secs;
            time_until_next <= threshold
          }
          None => false,
        };

        if should_force_finish {
          let (id, session) = &mut unfinished[i];
          check_out_all_members(session, &now);
          session.finished = true;
          Session::update(id, session)?;
          log::info!(
            "[SessionService] Force-finished session {} (checked out lingering members, next session approaching)",
            id
          );
        }
      } else {
        // No checked-in members and past end time — mark finished
        let (id, session) = &mut unfinished[i];
        session.finished = true;
        Session::update(id, session)?;
        log::info!("[SessionService] Marked session {} as finished (no lingering members)", id);
      }
    }

    Ok(())
  }
}
