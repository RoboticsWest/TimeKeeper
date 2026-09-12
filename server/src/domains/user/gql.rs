use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, SimpleObject, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::jwt::Auth;
use crate::auth::permissions::{PermissionLevel, Role, to_claim_strings};
use crate::auth::permissions_repository::PermissionsRepository;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::{DEFAULT_ADMIN_USERNAME, UserLogic};
use super::model::User;

const RESOURCE: &str = "users";
const TABLE: &str = "users";

#[derive(SimpleObject)]
pub struct AuthPayload {
  pub token: String,
}

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn UserLogic>> {
  Ok(ctx.data::<Arc<dyn UserLogic>>()?.clone())
}

fn permissions_repo(ctx: &Context<'_>) -> Result<Arc<dyn PermissionsRepository>> {
  Ok(ctx.data::<Arc<dyn PermissionsRepository>>()?.clone())
}

#[derive(Default)]
pub struct UserQuery;

#[Object]
impl UserQuery {
  /// The currently authenticated user, or `null` if the request has no valid token.
  async fn me(&self, ctx: &Context<'_>) -> Result<Option<User>> {
    let Some(claims) = crate::auth::auth_helpers::get_auth(ctx) else {
      return Ok(None);
    };
    let Ok(id) = claims.sub.parse::<Uuid>() else {
      return Ok(None);
    };
    Ok(logic(ctx)?.get(id).await?)
  }

  async fn users(&self, ctx: &Context<'_>) -> Result<Vec<User>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(logic(ctx)?.get_all().await?.into_iter().filter(|u| u.username != DEFAULT_ADMIN_USERNAME).collect())
  }

  /// Every assignable role, for populating the role picker.
  async fn roles(&self, ctx: &Context<'_>) -> Result<Vec<Role>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(permissions_repo(ctx)?.list_roles().await?)
  }
}

#[derive(Default)]
pub struct UserMutation;

#[Object]
impl UserMutation {
  async fn login(&self, ctx: &Context<'_>, username: String, password: String) -> Result<AuthPayload> {
    if username.is_empty() || password.is_empty() {
      return Err(Error::new("Username or password empty"));
    }

    let user = logic(ctx)?.get_by_username(&username).await?.ok_or_else(|| Error::new("User not found"))?;

    // Plain-text comparison - mirrors the old sled-era code exactly (no hashing on either side).
    if user.password != password {
      return Err(Error::new("Invalid username or password"));
    }

    let permissions = permissions_repo(ctx)?.get_user_permissions(user.id).await?;
    let claims = to_claim_strings(&permissions);
    let token = Auth::generate_token(&user.id.to_string(), &claims).map_err(|e| Error::new(e.to_string()))?;

    Ok(AuthPayload { token })
  }

  async fn update_admin_password(&self, ctx: &Context<'_>, password: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.set_admin_password(&password).await?;
    Ok(true)
  }

  async fn create_user(
    &self,
    ctx: &Context<'_>,
    username: String,
    password: String,
    role_ids: Option<Vec<i16>>,
  ) -> Result<User> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;

    if username.is_empty() || password.is_empty() {
      return Err(Error::new("Username and password are required"));
    }
    if username == DEFAULT_ADMIN_USERNAME {
      return Err(Error::new("Cannot create a user with the reserved admin username"));
    }

    let logic = logic(ctx)?;
    if logic.get_by_username(&username).await?.is_some() {
      return Err(Error::new("A user with that username already exists"));
    }

    let user = logic.add(&username, &password).await?;

    // Roles are set even when the list is empty, so "no roles" is an explicit choice rather
    // than something that silently happens to every new user.
    permissions_repo(ctx)?.set_user_roles(user.id, &role_ids.unwrap_or_default()).await?;

    Ok(user)
  }

  async fn update_user(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    username: Option<String>,
    password: Option<String>,
    role_ids: Option<Vec<i16>>,
  ) -> Result<User> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;

    let logic = logic(ctx)?;
    let existing = logic.get(id).await?.ok_or_else(|| Error::new("User not found"))?;

    if existing.username == DEFAULT_ADMIN_USERNAME {
      return Err(Error::new("Cannot modify the default admin user"));
    }

    let username = username.filter(|u| !u.is_empty()).unwrap_or(existing.username);
    let password = password.filter(|p| !p.is_empty()).unwrap_or(existing.password);

    // `None` leaves the user's roles untouched; `Some(..)` replaces them, including with an
    // empty list to strip every permission.
    if let Some(role_ids) = role_ids {
      permissions_repo(ctx)?.set_user_roles(id, &role_ids).await?;
    }

    logic.update(id, &username, &password).await?.ok_or_else(|| Error::new("User not found"))
  }

  async fn delete_user(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;

    let logic = logic(ctx)?;
    let user = logic.get(id).await?.ok_or_else(|| Error::new("User not found"))?;
    if user.username == DEFAULT_ADMIN_USERNAME {
      return Err(Error::new("Cannot delete the default admin user"));
    }

    logic.remove(id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct UserSubscription;

#[Subscription]
impl UserSubscription {
  async fn user_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<User>>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        let data = match change.operation {
          ChangeOperation::Delete => None,
          _ => match logic.get(change.id.parse().ok()?).await.ok().flatten() {
            Some(user) if user.username != DEFAULT_ADMIN_USERNAME => Some(user),
            _ => None,
          },
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
