DROP INDEX IF EXISTS team_members_discord_id_key;
ALTER TABLE team_members DROP COLUMN discord_id;
ALTER TABLE team_members ADD COLUMN discord_username text;
