ALTER TABLE team_member_stats DROP COLUMN IF EXISTS joined_at;
DROP FUNCTION IF EXISTS uuid_v7_timestamp(uuid);
