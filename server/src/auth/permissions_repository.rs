use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{roles, user_roles},
  views::user_permissions,
};

use super::permissions::UserPermission;

#[async_trait]
pub trait PermissionsRepository: Send + Sync {
  /// A user's effective permissions (via the `user_permissions` view - already resolved across
  /// every role they hold, including `is_super` roles expanded to `delete` on every resource).
  async fn get_user_permissions(&self, user_id: Uuid) -> anyhow::Result<Vec<UserPermission>>;

  /// Creates the role if it doesn't already exist (matched by name) and returns its id - used at
  /// startup to bootstrap the built-in admin role.
  async fn ensure_role(&self, name: &str, is_super: bool) -> anyhow::Result<i16>;

  /// No-op if the user already holds the role.
  async fn assign_role(&self, user_id: Uuid, role_id: i16) -> anyhow::Result<()>;
}

pub struct PgPermissionsRepository {
  pool: DbPool,
}

impl PgPermissionsRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl PermissionsRepository for PgPermissionsRepository {
  async fn get_user_permissions(&self, user_id: Uuid) -> anyhow::Result<Vec<UserPermission>> {
    let mut conn = self.pool.get().await?;
    Ok(
      user_permissions::table
        .filter(user_permissions::user_id.eq(user_id))
        .select(UserPermission::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn ensure_role(&self, name: &str, is_super: bool) -> anyhow::Result<i16> {
    let mut conn = self.pool.get().await?;

    if let Some(id) =
      roles::table.filter(roles::name.eq(name)).select(roles::id).first::<i16>(&mut conn).await.optional()?
    {
      return Ok(id);
    }

    Ok(
      diesel::insert_into(roles::table)
        .values((roles::name.eq(name), roles::is_super.eq(is_super)))
        .returning(roles::id)
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn assign_role(&self, user_id: Uuid, role_id: i16) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::insert_into(user_roles::table)
      .values((user_roles::user_id.eq(user_id), user_roles::role_id.eq(role_id)))
      .on_conflict((user_roles::user_id, user_roles::role_id))
      .do_nothing()
      .execute(&mut conn)
      .await?;
    Ok(())
  }
}
