// @generated automatically by Diesel CLI.

pub mod sql_types {
  #[derive(diesel::sql_types::SqlType)]
  #[diesel(postgres_type(name = "permission_level"))]
  pub struct PermissionLevel;
}

diesel::table! {
    locations (id) {
        id -> Uuid,
        location -> Text,
    }
}

diesel::table! {
    logos (id) {
        id -> Bool,
        data -> Bytea,
    }
}

diesel::table! {
    notifications (id) {
        id -> Uuid,
        notification_type -> Text,
        session_id -> Uuid,
        team_member_id -> Nullable<Uuid>,
        sent -> Bool,
        discord_message_id -> Nullable<Text>,
    }
}

diesel::table! {
    resources (slug) {
        slug -> Text,
        description -> Nullable<Text>,
    }
}

diesel::table! {
    rfid_tags (id) {
        id -> Uuid,
        team_member_id -> Uuid,
        tag -> Text,
    }
}

diesel::table! {
    use diesel::sql_types::{Int2, Text, Timestamptz};
    use super::sql_types::PermissionLevel;

    role_permissions (role_id, resource_slug) {
        role_id -> Int2,
        resource_slug -> Text,
        level -> PermissionLevel,
        granted_at -> Timestamptz,
    }
}

diesel::table! {
    roles (id) {
        id -> Int2,
        name -> Text,
        description -> Nullable<Text>,
        is_super -> Bool,
    }
}

diesel::table! {
    secrets (key) {
        key -> Text,
        secret_bytes -> Bytea,
    }
}

diesel::table! {
    session_rsvp_messages (discord_message_id) {
        discord_message_id -> Text,
        session_id -> Uuid,
    }
}

diesel::table! {
    session_rsvps (id) {
        id -> Uuid,
        session_id -> Uuid,
        team_member_id -> Uuid,
        status -> Text,
    }
}

diesel::table! {
    sessions (id) {
        id -> Uuid,
        start_time -> Timestamptz,
        end_time -> Timestamptz,
        location_id -> Uuid,
        finished -> Bool,
    }
}

diesel::table! {
    settings (id) {
        id -> Bool,
        next_session_threshold_secs -> Int8,
        discord_bot_token -> Text,
        discord_guild_id -> Text,
        discord_announcement_channel_id -> Text,
        discord_notification_channel_id -> Text,
        discord_self_link_enabled -> Bool,
        discord_name_sync_enabled -> Bool,
        discord_start_reminder_mins -> Int8,
        discord_end_reminder_mins -> Int8,
        discord_start_reminder_message -> Text,
        discord_end_reminder_message -> Text,
        discord_overtime_dm_enabled -> Bool,
        discord_overtime_dm_mins -> Int8,
        discord_overtime_dm_message -> Text,
        discord_auto_checkout_dm_enabled -> Bool,
        discord_auto_checkout_dm_message -> Text,
        discord_checkout_enabled -> Bool,
        discord_enabled -> Bool,
        timezone -> Text,
        primary_color -> Text,
        secondary_color -> Text,
        leaderboard_show_overtime -> Bool,
        leaderboard_member_types -> Array<Nullable<Text>>,
        discord_rsvp_reactions_enabled -> Bool,
        discord_auto_delete_start_reminder -> Bool,
        discord_auto_delete_end_reminder -> Bool,
    }
}

diesel::table! {
    team_member_sessions (id) {
        id -> Uuid,
        team_member_id -> Uuid,
        session_id -> Uuid,
        check_in_time -> Timestamptz,
        check_out_time -> Nullable<Timestamptz>,
    }
}

diesel::table! {
    team_members (id) {
        id -> Uuid,
        first_name -> Text,
        last_name -> Text,
        member_type -> Text,
        display_name -> Nullable<Text>,
        mobile_number -> Nullable<Text>,
        discord_username -> Nullable<Text>,
    }
}

diesel::table! {
    user_roles (user_id, role_id) {
        user_id -> Uuid,
        role_id -> Int2,
        granted_at -> Timestamptz,
    }
}

diesel::table! {
    users (id) {
        id -> Uuid,
        username -> Text,
        password -> Text,
    }
}

diesel::joinable!(notifications -> sessions (session_id));
diesel::joinable!(notifications -> team_members (team_member_id));
diesel::joinable!(rfid_tags -> team_members (team_member_id));
diesel::joinable!(role_permissions -> resources (resource_slug));
diesel::joinable!(role_permissions -> roles (role_id));
diesel::joinable!(session_rsvp_messages -> sessions (session_id));
diesel::joinable!(session_rsvps -> sessions (session_id));
diesel::joinable!(session_rsvps -> team_members (team_member_id));
diesel::joinable!(sessions -> locations (location_id));
diesel::joinable!(team_member_sessions -> sessions (session_id));
diesel::joinable!(team_member_sessions -> team_members (team_member_id));
diesel::joinable!(user_roles -> roles (role_id));
diesel::joinable!(user_roles -> users (user_id));

diesel::allow_tables_to_appear_in_same_query!(
  locations,
  logos,
  notifications,
  resources,
  rfid_tags,
  role_permissions,
  roles,
  secrets,
  session_rsvp_messages,
  session_rsvps,
  sessions,
  settings,
  team_member_sessions,
  team_members,
  user_roles,
  users,
);
