use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{roles, user_roles, users},
};

use super::logic::DEFAULT_ADMIN_USERNAME;
use super::model::User;

/// Narrows a user query. Every field is optional; an absent constraint means "everyone".
#[derive(Debug, Clone, Default)]
pub struct UserFilter {
  /// Case-insensitive substring match on the username *or* on any of the user's role names,
  /// matching what the users view searches over.
  pub search: Option<String>,
}

/// Builds the filtered users query.
///
/// A macro rather than a function for the same reason as `filtered_attendance!`: the boxed query
/// type is named differently in the `select` and `count` positions, and a
/// `BoxedSelectStatement` is not `Clone`, so the query is rebuilt rather than reused.
///
/// The built-in admin is excluded here, in SQL, rather than by filtering the loaded rows the way
/// the unpaged `users` resolver does. Post-filtering a page would drop a row out of the page
/// while still counting it in the total, so the last page would look short and the pager would
/// promise a row that never renders.
macro_rules! filtered_users {
  ($filter:expr) => {{
    let mut query = users::table.into_boxed().filter(users::username.ne(DEFAULT_ADMIN_USERNAME));

    if let Some(search) = $filter.search.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
      // ILIKE rather than lowercasing both sides: it keeps the comparison in the database and
      // reads the same way the admin typed it.
      let pattern = format!("%{search}%");
      // Role names are matched with EXISTS rather than a join: a user holding two matching roles
      // would otherwise come back twice, inflating the count and pushing a row off the page.
      query = query.filter(
        users::username.ilike(pattern.clone()).or(diesel::dsl::exists(
          user_roles::table
            .inner_join(roles::table.on(roles::id.eq(user_roles::role_id)))
            .filter(user_roles::user_id.eq(users::id))
            .filter(roles::name.ilike(pattern)),
        )),
      );
    }

    query
  }};
}

#[async_trait]
pub trait UserRepository: Send + Sync {
  /// One page of users matching `filter`, ordered by username, with the total match count.
  ///
  /// Never includes the built-in admin account, matching the unpaged `users` listing.
  async fn query_page(&self, filter: &UserFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<User>, i64)>;
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>>;
  async fn get_all(&self) -> anyhow::Result<Vec<User>>;
  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>>;
  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User>;
  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgUserRepository {
  pool: DbPool,
}

impl PgUserRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl UserRepository for PgUserRepository {
  async fn query_page(&self, filter: &UserFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<User>, i64)> {
    let mut conn = self.pool.get().await?;

    // Counted with the same narrowing as the page but without the page bounds, so the pager
    // reports how many rows it is paging through rather than how many it received.
    let total: i64 = filtered_users!(filter).count().get_result(&mut conn).await?;

    let items = filtered_users!(filter)
      // `username` is unique, so it is already a total order; no tiebreaker needed.
      .order(users::username.asc())
      .limit(limit)
      .offset(offset)
      .select(User::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }

  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.filter(users::id.eq(id)).select(User::as_select()).first(&mut conn).await.optional()?)
  }

  async fn get_all(&self) -> anyhow::Result<Vec<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.select(User::as_select()).load(&mut conn).await?)
  }

  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(users::table.filter(users::username.eq(username)).select(User::as_select()).first(&mut conn).await.optional()?)
  }

  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(users::table)
        .values((users::id.eq(id), users::username.eq(username), users::password.eq(password)))
        .returning(User::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(users::table.filter(users::id.eq(id)))
        .set((users::username.eq(username), users::password.eq(password)))
        .returning(User::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(users::table.filter(users::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(users::table).execute(&mut conn).await?;
    Ok(())
  }
}
