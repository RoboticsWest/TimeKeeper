use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::{AsyncConnection, RunQueryDsl};
use uuid::Uuid;

use database::{
  DbPool,
  schema::{roles, user_roles},
  views::user_permissions,
};

use super::permissions::{Role, UserPermission};

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

  /// Every role that can be assigned, ordered by name.
  async fn list_roles(&self) -> anyhow::Result<Vec<Role>>;

  /// The roles held by one user.
  async fn roles_for_user(&self, user_id: Uuid) -> anyhow::Result<Vec<Role>>;

  /// Replaces a user's roles wholesale. An empty list leaves them with no permissions.
  async fn set_user_roles(&self, user_id: Uuid, role_ids: &[i16]) -> anyhow::Result<()>;
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

  async fn list_roles(&self) -> anyhow::Result<Vec<Role>> {
    let mut conn = self.pool.get().await?;
    Ok(roles::table.order(roles::name.asc()).select(Role::as_select()).load(&mut conn).await?)
  }

  async fn roles_for_user(&self, user_id: Uuid) -> anyhow::Result<Vec<Role>> {
    let mut conn = self.pool.get().await?;
    Ok(
      user_roles::table
        .inner_join(roles::table)
        .filter(user_roles::user_id.eq(user_id))
        .order(roles::name.asc())
        .select(Role::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn set_user_roles(&self, user_id: Uuid, role_ids: &[i16]) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;

    // Delete-then-insert rather than diffing: the set is tiny, and doing both in one
    // transaction means a failed update can't leave the user with partial permissions.
    conn
      .transaction::<_, anyhow::Error, _>(|conn| {
        let role_ids = role_ids.to_vec();
        Box::pin(async move {
          diesel::delete(user_roles::table.filter(user_roles::user_id.eq(user_id))).execute(conn).await?;

          if !role_ids.is_empty() {
            let rows: Vec<_> =
              role_ids.iter().map(|id| (user_roles::user_id.eq(user_id), user_roles::role_id.eq(*id))).collect();
            diesel::insert_into(user_roles::table).values(rows).execute(conn).await?;
          }

          Ok(())
        })
      })
      .await
  }
}
