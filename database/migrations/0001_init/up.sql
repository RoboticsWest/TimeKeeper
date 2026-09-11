CREATE TABLE users (
    id            uuid PRIMARY KEY,
    username      text NOT NULL,
    password      text NOT NULL,

    CONSTRAINT users_username_key UNIQUE (username)
);

CREATE TABLE team_members (
    id                 uuid PRIMARY KEY,
    first_name         text NOT NULL,
    last_name          text NOT NULL,
    member_type        text NOT NULL CHECK (member_type IN ('student', 'mentor')),
    display_name       text,
    mobile_number      text,
    discord_username   text
);

CREATE TABLE locations (
    id         uuid PRIMARY KEY,
    location   text NOT NULL
);

CREATE TABLE secrets (
    key            text PRIMARY KEY,
    secret_bytes   bytea NOT NULL
);

CREATE TABLE settings (
    id                                     boolean PRIMARY KEY DEFAULT true,
    next_session_threshold_secs            bigint NOT NULL,
    discord_bot_token                      text NOT NULL DEFAULT '',
    discord_guild_id                       text NOT NULL DEFAULT '',
    discord_announcement_channel_id        text NOT NULL DEFAULT '',
    discord_notification_channel_id        text NOT NULL DEFAULT '',
    discord_self_link_enabled              boolean NOT NULL DEFAULT false,
    discord_name_sync_enabled              boolean NOT NULL DEFAULT false,
    discord_start_reminder_mins            bigint NOT NULL,
    discord_end_reminder_mins              bigint NOT NULL,
    discord_start_reminder_message         text NOT NULL,
    discord_end_reminder_message           text NOT NULL,
    discord_overtime_dm_enabled            boolean NOT NULL DEFAULT true,
    discord_overtime_dm_mins               bigint NOT NULL,
    discord_overtime_dm_message            text NOT NULL,
    discord_auto_checkout_dm_enabled       boolean NOT NULL DEFAULT true,
    discord_auto_checkout_dm_message       text NOT NULL,
    discord_checkout_enabled               boolean NOT NULL DEFAULT false,
    discord_enabled                        boolean NOT NULL DEFAULT false,
    timezone                               text NOT NULL DEFAULT '',
    primary_color                          text NOT NULL DEFAULT '#009485',
    secondary_color                        text NOT NULL DEFAULT '#005994',
    leaderboard_show_overtime              boolean NOT NULL DEFAULT true,
    leaderboard_member_types               text[] NOT NULL DEFAULT '{student,mentor}',
    discord_rsvp_reactions_enabled         boolean NOT NULL DEFAULT true,
    discord_auto_delete_start_reminder     boolean NOT NULL DEFAULT false,
    discord_auto_delete_end_reminder       boolean NOT NULL DEFAULT false,

    CONSTRAINT settings_singleton CHECK (id)
);

CREATE TABLE logos (
    id     boolean PRIMARY KEY DEFAULT true,
    data   bytea NOT NULL DEFAULT '',

    CONSTRAINT logos_singleton CHECK (id)
);

CREATE TABLE sessions (
    id             uuid PRIMARY KEY,
    start_time     timestamptz NOT NULL,
    end_time       timestamptz NOT NULL,
    location_id    uuid NOT NULL REFERENCES locations (id) ON DELETE RESTRICT,
    finished       boolean NOT NULL DEFAULT false
);

CREATE TABLE rfid_tags (
    id               uuid PRIMARY KEY,
    team_member_id   uuid NOT NULL REFERENCES team_members (id) ON DELETE CASCADE,
    tag              text NOT NULL,

    CONSTRAINT rfid_tags_tag_key UNIQUE (tag)
);

CREATE TABLE team_member_sessions (
    id                uuid PRIMARY KEY,
    team_member_id    uuid NOT NULL REFERENCES team_members (id) ON DELETE CASCADE,
    session_id        uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
    check_in_time     timestamptz NOT NULL,
    check_out_time    timestamptz
);

CREATE TABLE notifications (
    id                    uuid PRIMARY KEY,
    notification_type     text NOT NULL CHECK (notification_type IN ('session_start_reminder', 'session_end_reminder', 'overtime', 'auto_checkout')),
    session_id            uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
    team_member_id        uuid REFERENCES team_members (id) ON DELETE CASCADE,
    sent                  boolean NOT NULL DEFAULT false,
    discord_message_id    text
);

CREATE TABLE session_rsvps (
    id                uuid PRIMARY KEY,
    session_id        uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
    team_member_id    uuid NOT NULL REFERENCES team_members (id) ON DELETE CASCADE,
    status            text NOT NULL CHECK (status IN ('going', 'not_going')),

    CONSTRAINT session_rsvps_session_member_key UNIQUE (session_id, team_member_id)
);

CREATE TABLE session_rsvp_messages (
    discord_message_id   text PRIMARY KEY,
    session_id           uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE
);

-- Roles / resources / permissions (mirrors Stack's platform/database iam schema)

CREATE TABLE roles (
    id            smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name          text NOT NULL,
    description   text,
    is_super      boolean NOT NULL DEFAULT false,

    CONSTRAINT roles_name_key UNIQUE (name)
);

CREATE TABLE user_roles (
    user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id      smallint NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    granted_at   timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE resources (
    slug          text PRIMARY KEY,
    description   text
);

CREATE TYPE permission_level AS ENUM ('read', 'write', 'delete');

CREATE TABLE role_permissions (
    role_id         smallint NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    resource_slug   text NOT NULL REFERENCES resources (slug) ON DELETE CASCADE,
    level           permission_level NOT NULL,
    granted_at      timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (role_id, resource_slug)
);

INSERT INTO resources (slug) VALUES
    ('locations'),
    ('notifications'),
    ('rfid_tags'),
    ('sessions'),
    ('session_rsvps'),
    ('settings'),
    ('statistics'),
    ('team_members'),
    ('team_member_sessions'),
    ('users');

-- Ceiling permissions for every role: role_permissions rows directly granted, plus every
-- resource at `delete` for `is_super` roles (super roles aren't granted rows individually).
CREATE VIEW permissions_effective AS
    SELECT role_id, resource_slug, level FROM role_permissions
    UNION
    SELECT r.id AS role_id, res.slug AS resource_slug, 'delete'::permission_level AS level
    FROM roles r
    CROSS JOIN resources res
    WHERE r.is_super;

-- Per-user effective permission (max level across all of a user's roles) - the view app code queries.
CREATE VIEW user_permissions AS
    SELECT ur.user_id, pe.resource_slug, MAX(pe.level) AS level
    FROM user_roles ur
    JOIN permissions_effective pe ON pe.role_id = ur.role_id
    GROUP BY ur.user_id, pe.resource_slug;

-- Postgres-native change notifications: every table below NOTIFYs `db_changes` on write, so
-- subscribers never depend on application code remembering to publish a change.

CREATE FUNCTION notify_table_change() RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify(
        'db_changes',
        json_build_object(
            'table', TG_TABLE_NAME,
            'op', TG_OP,
            'id', COALESCE(NEW.id, OLD.id)
        )::text
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sessions_notify AFTER INSERT OR UPDATE OR DELETE ON sessions
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER locations_notify AFTER INSERT OR UPDATE OR DELETE ON locations
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER team_members_notify AFTER INSERT OR UPDATE OR DELETE ON team_members
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER team_member_sessions_notify AFTER INSERT OR UPDATE OR DELETE ON team_member_sessions
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER rfid_tags_notify AFTER INSERT OR UPDATE OR DELETE ON rfid_tags
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER notifications_notify AFTER INSERT OR UPDATE OR DELETE ON notifications
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER session_rsvps_notify AFTER INSERT OR UPDATE OR DELETE ON session_rsvps
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
