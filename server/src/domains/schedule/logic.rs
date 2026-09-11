use std::sync::Arc;

use async_trait::async_trait;

use crate::domains::location::{Location, LocationRepository};
use crate::domains::session::SessionRepository;

use super::csv_parser::csv_to_schedule;
use super::ics_parser::ics_to_schedule;
use super::model::Schedule;

#[async_trait]
pub trait ScheduleLogic: Send + Sync {
  async fn import_csv(&self, csv: &str) -> anyhow::Result<()>;
  async fn import_ics(&self, ics: &str) -> anyhow::Result<()>;
}

pub struct DefaultScheduleLogic {
  locations: Arc<dyn LocationRepository>,
  sessions: Arc<dyn SessionRepository>,
}

impl DefaultScheduleLogic {
  pub fn new(locations: Arc<dyn LocationRepository>, sessions: Arc<dyn SessionRepository>) -> Self {
    Self { locations, sessions }
  }

  async fn import(&self, schedule: Schedule) -> anyhow::Result<()> {
    for location in schedule.locations {
      let existing = self.locations.get_by_name(&location).await?;
      if existing.is_empty() {
        let _: Location = self.locations.add(&location).await?;
      }
    }

    for session in schedule.sessions {
      let locations = self.locations.get_by_name(&session.location_name).await?;
      let Some(location) = locations.into_iter().next() else {
        return Err(anyhow::anyhow!("Location not found: {}", session.location_name));
      };

      self.sessions.add(session.start_time, session.end_time, location.id, false).await?;
    }

    Ok(())
  }
}

#[async_trait]
impl ScheduleLogic for DefaultScheduleLogic {
  async fn import_csv(&self, csv: &str) -> anyhow::Result<()> {
    let schedule = csv_to_schedule(csv)?;
    self.import(schedule).await
  }

  async fn import_ics(&self, ics: &str) -> anyhow::Result<()> {
    let schedule = ics_to_schedule(ics)?;
    self.import(schedule).await
  }
}
