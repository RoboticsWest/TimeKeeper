//! Diesel bindings for read-only database views.
//!
//! `diesel print-schema` can't infer a primary key for a view, so it skips these entirely -
//! meaning they will never be emitted into (or wiped from) the generated `schema.rs`. Keep these
//! definitions in sync by hand with the `CREATE VIEW` statements in `migrations/0001_init/up.sql`.

use crate::schema::sql_types::PermissionLevel;
use crate::schema::users;

diesel::table! {
    use diesel::sql_types::{Int2, Text};
    use super::PermissionLevel;

    permissions_effective (role_id, resource_slug) {
        role_id -> Int2,
        resource_slug -> Text,
        level -> PermissionLevel,
    }
}

diesel::table! {
    use diesel::sql_types::{Uuid, Text};
    use super::PermissionLevel;

    user_permissions (user_id, resource_slug) {
        user_id -> Uuid,
        resource_slug -> Text,
        level -> PermissionLevel,
    }
}

diesel::joinable!(user_permissions -> users (user_id));
diesel::allow_tables_to_appear_in_same_query!(user_permissions, users);
