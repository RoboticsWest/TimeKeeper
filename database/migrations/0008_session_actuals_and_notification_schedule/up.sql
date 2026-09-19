-- Three related changes, all driven by the same root problem: the schema recorded what was
-- *planned* and who was *present*, but never what actually happened to a session as a whole.
--
--   1. sessions gain actual_start_time / actual_end_time, so session-level statistics stop
--      being derived by summing per-member hours (which answered "man-hours", not "hours").
--   2. settings splits the overloaded next_session_threshold_secs into a check-in window and
--      a separate, configurable auto-checkout delay.
--   3. notifications become scheduled, session-bound rows with a real lifecycle, instead of
--      a `sent` flag whose absence meant "send it (again)".


-- 1 ------------------------------------------------------------------------------------------
-- When the session really began and ended: the first check-in and the last check-out.
-- NULL means "not determined yet" - nobody has checked in, or somebody is still checked in.
-- Scheduled start_time/end_time stay exactly as they were; overtime is the difference.

ALTER TABLE sessions ADD COLUMN actual_start_time timestamptz;
ALTER TABLE sessions ADD COLUMN actual_end_time timestamptz;

-- Backfill from attendance already on record. actual_end_time is deliberately left NULL when
-- any member of that session is still checked out (check_out_time IS NULL): the session has
-- no real end yet, and MAX() would otherwise invent one from whoever happened to leave first.
UPDATE sessions s
SET actual_start_time = agg.first_in,
    actual_end_time   = agg.last_out
FROM (
    SELECT session_id,
           MIN(check_in_time) AS first_in,
           CASE
               WHEN COUNT(*) FILTER (WHERE check_out_time IS NULL) > 0 THEN NULL
               ELSE MAX(check_out_time)
           END AS last_out
    FROM team_member_sessions
    GROUP BY session_id
) agg
WHERE s.id = agg.session_id;


-- 2 ------------------------------------------------------------------------------------------
-- next_session_threshold_secs was doing two unrelated jobs: it bounded how far from a session
-- a kiosk scan could still check you in, AND it decided when lingering members were forcibly
-- checked out. Those want opposite values - a generous check-in window, a long checkout grace -
-- so they are now two settings.

ALTER TABLE settings RENAME COLUMN next_session_threshold_secs TO check_in_window_secs;

-- How long after a session's scheduled end its stragglers are auto-checked-out. The other
-- trigger - the next session at that location actually starting - is unconditional and needs
-- no setting. 24h default.
ALTER TABLE settings ADD COLUMN auto_checkout_after_secs bigint NOT NULL DEFAULT 86400;


-- 3 ------------------------------------------------------------------------------------------
-- Notifications become a schedule rather than a log.
--
-- Before: a row existed only once a message had been sent, and `sent` was always true on it.
-- "Should I send this?" was answered by the *absence* of a row, so deleting a row - or an
-- admin clearing the table - meant the reminder fired again. There was also no way to say
-- "don't send this one" ahead of time.
--
-- After: rows are created up front when the session is created, carry when they are due
-- (scheduled_for) and what became of them (status). Absence no longer means anything; a row
-- in a terminal status is never re-sent, and `cancelled` is how a user opts out of a reminder.

ALTER TABLE notifications ADD COLUMN scheduled_for timestamptz;
ALTER TABLE notifications ADD COLUMN sent_at timestamptz;
ALTER TABLE notifications ADD COLUMN status text NOT NULL DEFAULT 'pending';

-- Existing rows only ever existed because something was sent.
UPDATE notifications SET status = 'sent' WHERE sent;
UPDATE notifications SET status = 'pending' WHERE NOT sent;

-- Nothing recorded when a legacy notification was sent; its session's schedule is the closest
-- honest answer, and it keeps the column non-null for every row that claims to have been sent.
UPDATE notifications n
SET sent_at = s.start_time,
    scheduled_for = s.start_time
FROM sessions s
WHERE n.session_id = s.id AND n.status = 'sent';

ALTER TABLE notifications DROP COLUMN sent;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_status_check
    CHECK (status IN ('pending', 'sent', 'skipped', 'cancelled', 'failed'));

-- The send loop's hot path: "what is due for this session".
CREATE INDEX notifications_session_status_idx ON notifications (session_id, status);
CREATE INDEX notifications_due_idx ON notifications (status, scheduled_for);

-- One reminder of a given kind per session per member. Postgres treats NULLs as distinct in a
-- plain UNIQUE, which would let duplicate session-wide reminders (team_member_id IS NULL)
-- through, so the session-wide case gets its own partial index.
CREATE UNIQUE INDEX notifications_unique_member_kind
    ON notifications (session_id, notification_type, team_member_id)
    WHERE team_member_id IS NOT NULL;

CREATE UNIQUE INDEX notifications_unique_session_kind
    ON notifications (session_id, notification_type)
    WHERE team_member_id IS NULL;
