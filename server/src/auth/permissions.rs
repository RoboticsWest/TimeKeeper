use std::io::Write;

use diesel::deserialize::{self, FromSql, FromSqlRow};
use diesel::expression::AsExpression;
use diesel::pg::{Pg, PgValue};
use diesel::serialize::{self, IsNull, Output, ToSql};

use database::schema::sql_types::PermissionLevel as PgPermissionLevel;

/// Mirrors Postgres' `permission_level` enum (`database/migrations/0001_init/up.sql`) - ordered so
/// `Write` implies `Read` and `Delete` implies `Write`, matching the ceiling semantics of the
/// `user_permissions`/`permissions_effective` views.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, AsExpression, FromSqlRow)]
#[diesel(sql_type = PgPermissionLevel)]
pub enum PermissionLevel {
  Read,
  Write,
  Delete,
}

impl PermissionLevel {
  pub fn as_str(self) -> &'static str {
    match self {
      Self::Read => "read",
      Self::Write => "write",
      Self::Delete => "delete",
    }
  }

  pub fn parse(s: &str) -> Option<Self> {
    match s {
      "read" => Some(Self::Read),
      "write" => Some(Self::Write),
      "delete" => Some(Self::Delete),
      _ => None,
    }
  }
}

impl ToSql<PgPermissionLevel, Pg> for PermissionLevel {
  fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
    out.write_all(self.as_str().as_bytes())?;
    Ok(IsNull::No)
  }
}

impl FromSql<PgPermissionLevel, Pg> for PermissionLevel {
  fn from_sql(bytes: PgValue<'_>) -> deserialize::Result<Self> {
    Self::parse(std::str::from_utf8(bytes.as_bytes())?).ok_or_else(|| "Unrecognized permission_level value".into())
  }
}

/// One row of a user's effective permission for a resource - read from the `user_permissions` view.
#[derive(Debug, Clone, diesel::Queryable, diesel::Selectable)]
#[diesel(table_name = database::views::user_permissions)]
#[diesel(check_for_backend(Pg))]
pub struct UserPermission {
  pub resource_slug: String,
  pub level: PermissionLevel,
}

/// Flattens permissions into the `"<resource_slug>:<level>"` strings baked into JWT claims at
/// sign time (see `auth::jwt::Claims`).
pub fn to_claim_strings(permissions: &[UserPermission]) -> Vec<String> {
  permissions.iter().map(|p| format!("{}:{}", p.resource_slug, p.level.as_str())).collect()
}

/// Parses a single `"<resource_slug>:<level>"` claim string.
pub fn parse_claim(claim: &str) -> Option<(&str, PermissionLevel)> {
  let (resource, level) = claim.split_once(':')?;
  Some((resource, PermissionLevel::parse(level)?))
}
