ALTER TABLE settings DROP COLUMN quick_pin_enabled;
DROP INDEX IF EXISTS team_members_quick_pin_key;
ALTER TABLE team_members DROP COLUMN quick_pin;
