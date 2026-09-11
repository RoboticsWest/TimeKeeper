use std::sync::Arc;
use std::time::Duration;

use crate::scheduler::{Schedule, Service};

use super::logic::SessionLogic;

pub struct SessionService {
  logic: Arc<dyn SessionLogic>,
}

impl SessionService {
  pub fn new(logic: Arc<dyn SessionLogic>) -> Self {
    Self { logic }
  }
}

impl Service for SessionService {
  fn name(&self) -> &'static str {
    "SessionService"
  }

  fn schedule(&self) -> Schedule {
    Schedule::Every(Duration::from_secs(5))
  }

  async fn execute(&self) -> anyhow::Result<()> {
    self.logic.process_past_end_sessions().await
  }
}
