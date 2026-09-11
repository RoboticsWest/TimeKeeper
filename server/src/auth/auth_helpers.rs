use async_graphql::{Context, Error, Result};

use crate::auth::{jwt::Claims, permissions::PermissionLevel};

/// Require authentication - returns claims or an error. `Claims` is injected into the GraphQL
/// request's context data by `graphql_handler`/`on_connection_init` (see `server.rs`) after
/// validating the JWT from the `Authorization` header (HTTP) or `connection_init` payload (ws).
pub fn require_auth(ctx: &Context<'_>) -> Result<Claims> {
  ctx.data::<Claims>().cloned().map_err(|_| Error::new("Authentication required"))
}

/// Require at least `required` permission on `resource` (ceiling semantics - see
/// `Claims::has_permission`).
pub fn require_permission(ctx: &Context<'_>, resource: &str, required: PermissionLevel) -> Result<Claims> {
  let claims = require_auth(ctx)?;

  if !claims.has_permission(resource, required) {
    return Err(Error::new(format!("'{}' permission on '{resource}' required", required.as_str())));
  }

  Ok(claims)
}

/// Get optional auth (for logging/analytics on public endpoints).
pub fn get_auth(ctx: &Context<'_>) -> Option<Claims> {
  ctx.data::<Claims>().ok().cloned()
}
