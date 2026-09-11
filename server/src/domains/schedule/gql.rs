use std::sync::Arc;

use async_graphql::{Context, Object, Result};

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;

use super::logic::ScheduleLogic;

// Schedule uploads create/update sessions - gated on the `sessions` resource, not a dedicated one.
const RESOURCE: &str = "sessions";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn ScheduleLogic>> {
  Ok(ctx.data::<Arc<dyn ScheduleLogic>>()?.clone())
}

#[derive(Default)]
pub struct ScheduleMutation;

#[Object]
impl ScheduleMutation {
  async fn upload_schedule_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_csv(&csv_data).await?;
    Ok(true)
  }

  async fn upload_schedule_ics(&self, ctx: &Context<'_>, ics_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_ics(&ics_data).await?;
    Ok(true)
  }
}
