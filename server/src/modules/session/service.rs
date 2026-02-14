use std::time::Duration;

use crate::{
  core::scheduler::ScheduledService,
  generated::{common::Timestamp, db::Session},
  modules::session::{
    SessionRepository,
    helpers::{
      check_out_all_members, get_next_session_threshold_secs, get_past_end_sessions, is_auto_checkout_imminent,
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

    let past_end_sessions = get_past_end_sessions()?;

    for mut pes in past_end_sessions {
      if pes.checked_in.is_empty() {
        // No checked-in members and past end time — mark finished
        pes.session.finished = true;
        Session::update(&pes.session_id, &pes.session)?;
        log::info!("[SessionService] Marked session {} as finished (no lingering members)", pes.session_id);
      } else if is_auto_checkout_imminent(pes.next_start_secs, now_secs, threshold) {
        // Has lingering members and next session approaching — force-finish
        let end_time = Timestamp { seconds: pes.end_secs, nanos: 0 };
        check_out_all_members(&pes.session_id, &end_time)?;

        pes.session.finished = true;
        Session::update(&pes.session_id, &pes.session)?;
        log::info!(
          "[SessionService] Force-finished session {} (checked out lingering members, next session approaching)",
          pes.session_id
        );
      }
    }

    Ok(())
  }
}
