-- Link team members to Discord by snowflake ID rather than username.
--
-- Usernames are mutable, so every link silently rotted the moment a member
-- renamed themselves. Existing links cannot be migrated (a username is not
-- recoverable to an ID without hitting the API for each one), so they are
-- dropped; members re-link with `!link`, and re-running "Import Members from
-- Discord" re-links everyone it can match by display name.
--
-- Stored as text for consistency with every other snowflake in this schema
-- (settings.discord_guild_id, notifications.discord_message_id), which are
-- parsed with .parse::<u64>() at their use sites.
ALTER TABLE team_members DROP COLUMN discord_username;
ALTER TABLE team_members ADD COLUMN discord_id text;

CREATE UNIQUE INDEX team_members_discord_id_key
    ON team_members (discord_id)
    WHERE discord_id IS NOT NULL;
