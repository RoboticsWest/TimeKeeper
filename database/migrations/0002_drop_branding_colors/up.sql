-- Branding colors are no longer server-configurable. The client ships a
-- hand-authored light/dark theme, so these columns had no remaining readers.
ALTER TABLE settings DROP COLUMN IF EXISTS primary_color;
ALTER TABLE settings DROP COLUMN IF EXISTS secondary_color;
