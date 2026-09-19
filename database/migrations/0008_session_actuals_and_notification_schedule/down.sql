-- Reverse of up.sql. The `status` detail (skipped/cancelled/failed) cannot survive a
-- round-trip through a single boolean; everything not 'sent' collapses to false, which is
-- the pre-migration meaning of "not yet sent".

DROP INDEX IF EXISTS notifications_unique_session_kind;
DROP INDEX IF EXISTS notifications_unique_member_kind;
DROP INDEX IF EXISTS notifications_due_idx;
DROP INDEX IF EXISTS notifications_session_status_idx;

ALTER TABLE notifications ADD COLUMN sent boolean NOT NULL DEFAULT false;
UPDATE notifications SET sent = (status = 'sent');

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_status_check;
ALTER TABLE notifications DROP COLUMN status;
ALTER TABLE notifications DROP COLUMN sent_at;
ALTER TABLE notifications DROP COLUMN scheduled_for;

ALTER TABLE settings DROP COLUMN auto_checkout_after_secs;
ALTER TABLE settings RENAME COLUMN check_in_window_secs TO next_session_threshold_secs;

ALTER TABLE sessions DROP COLUMN actual_end_time;
ALTER TABLE sessions DROP COLUMN actual_start_time;
