-- Recorded statistics, kept apart from the tables that run the club.
--
-- Everything `!mystats` shows was derived from attendance rows, which works right up until the
-- row state cannot tell two different events apart. The auto-checkout writes the checkout as
-- exactly the session's scheduled end (`session/logic.rs`), and so does a deliberate `!checkout`
-- run after the session has ended - so "forgot to sign out" and "signed out late, on purpose"
-- were the same row, and the first was counted for both. Derivation has a second problem
-- besides: it is retroactive. Editing a session's end time silently rewrites how many times
-- somebody "forgot" to sign out last month.
--
-- These two tables record what happened *when it happened*. They are deliberately separate from
-- the business tables and reference them rather than extending them: nothing here is needed to
-- run a session, check somebody in, or roster a team. Drop both tables and TimeKeeper still
-- works - it just loses the stat card and the achievements.
--
--   attendance_stats   - one row per attendance, recording facts about that specific check-in
--                        that the attendance row itself cannot express.
--   team_member_stats  - lifetime per-member counters that must survive history being edited or
--                        pruned, which a COUNT over attendance rows does not.
--
-- Both are backfilled from the best evidence currently available, so existing members do not
-- start from zero. The backfill uses the old heuristic and inherits its one ambiguity - a
-- pre-migration manual late checkout is recorded as 'auto'. There is no evidence left to do
-- better, and from here on the distinction is recorded rather than guessed.


-- Per-attendance facts -------------------------------------------------------------------------
--
-- Keyed on the attendance row itself, so there is exactly one stats row per check-in and it
-- cannot drift out of step. ON DELETE CASCADE because a stat about a deleted attendance is
-- meaningless.
CREATE TABLE attendance_stats (
    team_member_session_id uuid PRIMARY KEY REFERENCES team_member_sessions(id) ON DELETE CASCADE,

    -- Who ended the attendance. 'none' while they are still checked in.
    checkout_kind text NOT NULL DEFAULT 'none',

    -- How the checkout was made. 'auto' pairs with checkout_kind 'auto'; 'unknown' is what the
    -- backfill uses for history that predates this column.
    checkout_source text NOT NULL DEFAULT 'unknown',

    -- Whether the checkout landed after the session's scheduled end. Stored rather than compared
    -- against sessions.end_time on read, so that editing a session later cannot rewrite it.
    checked_out_late boolean NOT NULL DEFAULT false,

    recorded_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT attendance_stats_checkout_kind_valid
        CHECK (checkout_kind IN ('none', 'manual', 'auto')),
    CONSTRAINT attendance_stats_checkout_source_valid
        CHECK (checkout_source IN ('kiosk', 'rfid', 'discord', 'admin', 'auto', 'unknown')),
    -- An attendance nobody has checked out of cannot have been checked out late, and an open
    -- attendance has no source yet.
    CONSTRAINT attendance_stats_open_rows_are_blank
        CHECK (checkout_kind <> 'none' OR (checked_out_late = false AND checkout_source = 'unknown'))
);

-- Every achievement that reads these filters on the kind, over one member's rows.
CREATE INDEX attendance_stats_checkout_kind_idx ON attendance_stats (checkout_kind);

-- Backfill: the heuristic this table replaces, applied once to the history that predates it.
INSERT INTO attendance_stats (team_member_session_id, checkout_kind, checkout_source, checked_out_late, recorded_at)
SELECT ms.id,
       CASE
           WHEN ms.check_out_time IS NULL     THEN 'none'
           WHEN ms.check_out_time = s.end_time THEN 'auto'
           ELSE 'manual'
       END,
       CASE
           WHEN ms.check_out_time IS NULL      THEN 'unknown'
           WHEN ms.check_out_time = s.end_time THEN 'auto'
           ELSE 'unknown'
       END,
       CASE
           -- Strictly after: a checkout landing exactly on the end is the auto-checkout, which
           -- is not a late stay.
           WHEN ms.check_out_time > s.end_time THEN true
           ELSE false
       END,
       COALESCE(ms.check_out_time, ms.check_in_time)
FROM team_member_sessions ms
JOIN sessions s ON s.id = ms.session_id;


-- Lifetime per-member counters -----------------------------------------------------------------
--
-- These are monotonic on purpose. A COUNT over attendance answers "how many rows exist now",
-- which drops when a session is deleted; these answer "how many times did this happen to this
-- member", which is what a milestone should be measured against. They only ever go up, so an
-- achievement earned cannot be taken away by an admin tidying up old sessions.
CREATE TABLE team_member_stats (
    team_member_id uuid PRIMARY KEY REFERENCES team_members(id) ON DELETE CASCADE,

    -- Every check-in ever, including ones whose session has since been deleted.
    check_ins bigint NOT NULL DEFAULT 0,

    -- Overtime DMs actually delivered to this member. Derivable from `notifications` today, but
    -- that table is a work queue rather than a permanent log.
    overtime_warnings bigint NOT NULL DEFAULT 0,

    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT team_member_stats_counters_non_negative
        CHECK (check_ins >= 0 AND overtime_warnings >= 0)
);

-- Backfill from what is still on record. Members with no history get a zeroed row, so the server
-- can always assume a row exists rather than branching on its absence.
INSERT INTO team_member_stats (team_member_id, check_ins, overtime_warnings)
SELECT tm.id,
       COALESCE(attendance.count, 0),
       COALESCE(warnings.count, 0)
FROM team_members tm
LEFT JOIN (
    SELECT team_member_id, COUNT(*) AS count
    FROM team_member_sessions
    GROUP BY team_member_id
) attendance ON attendance.team_member_id = tm.id
LEFT JOIN (
    SELECT team_member_id, COUNT(*) AS count
    FROM notifications
    WHERE notification_type = 'overtime' AND status = 'sent' AND team_member_id IS NOT NULL
    GROUP BY team_member_id
) warnings ON warnings.team_member_id = tm.id;

-- Opening a stats row, and counting the check-in, belongs to the database for the same reason:
-- attendance rows are created by the kiosk, by the PIN pad, by a CSV import of past seasons, and
-- by psql. A counter the server increments is a counter that is wrong the first time somebody
-- takes a path the server does not own.
CREATE FUNCTION record_attendance_check_in() RETURNS trigger AS $$
BEGIN
    INSERT INTO attendance_stats (team_member_session_id) VALUES (NEW.id)
    ON CONFLICT (team_member_session_id) DO NOTHING;

    -- ON CONFLICT DO UPDATE rather than a bare UPDATE: a member created before this migration
    -- has a row from the backfill, but one created by a route that skipped the trigger below
    -- may not, and their first check-in should create the counter at 1 rather than vanish.
    INSERT INTO team_member_stats (team_member_id, check_ins) VALUES (NEW.team_member_id, 1)
    ON CONFLICT (team_member_id) DO UPDATE
        SET check_ins = team_member_stats.check_ins + 1,
            updated_at = now();

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER team_member_sessions_record_check_in AFTER INSERT ON team_member_sessions
    FOR EACH ROW EXECUTE FUNCTION record_attendance_check_in();


-- A new member needs a counter row the moment they exist, or their first check-in has nothing to
-- increment. Done in the database rather than the server so a member created by any route - the
-- app, a script, psql - is covered.
CREATE FUNCTION create_team_member_stats() RETURNS trigger AS $$
BEGIN
    INSERT INTO team_member_stats (team_member_id) VALUES (NEW.id)
    ON CONFLICT (team_member_id) DO NOTHING;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER team_members_create_stats AFTER INSERT ON team_members
    FOR EACH ROW EXECUTE FUNCTION create_team_member_stats();


-- Realtime ---------------------------------------------------------------------------------------
--
-- Neither table has a plain `id` column, so `notify_table_change()` (0001/0007) does not fit.
-- `notify_owner_change()` (0011) is the right shape anyway: a client does not subscribe to
-- "attendance stats", it subscribes to attendance and to team members. Reporting the change as
-- an UPDATE of the owning row makes the existing `teamMemberSessionChanges` and
-- `teamMemberChanges` subscriptions fire, and the server re-fetches the row with its stats.
CREATE TRIGGER attendance_stats_notify AFTER INSERT OR UPDATE OR DELETE ON attendance_stats
    FOR EACH ROW EXECUTE FUNCTION notify_owner_change('team_member_sessions', 'team_member_session_id');

CREATE TRIGGER team_member_stats_notify AFTER INSERT OR UPDATE OR DELETE ON team_member_stats
    FOR EACH ROW EXECUTE FUNCTION notify_owner_change('team_members', 'team_member_id');
