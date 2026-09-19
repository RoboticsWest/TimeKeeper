-- Indexes for the filtered, paged queries (`attendance`, `sessionPage`, `teamMemberPage`).
--
-- Before this the only indexes on these tables were their primary keys, so every one of those
-- queries was a sequential scan plus a sort — including the COUNT that sizes the pager. That is
-- survivable at a few hundred rows and is not at the tens of thousands of attendance records a
-- season produces, which is the case pagination exists for.
--
-- Postgres does not index foreign keys automatically, so the join and lookup columns below were
-- unindexed too: `get_by_session_id` and `get_by_member_id` are on the kiosk's hot path and were
-- scanning the whole table on every check-in.

-- Attendance -------------------------------------------------------------------------------
-- Matches the query's ORDER BY exactly (check_in_time DESC, id DESC), so paging can walk the
-- index instead of sorting the whole filtered set to throw most of it away.
CREATE INDEX team_member_sessions_check_in_desc_idx
    ON team_member_sessions (check_in_time DESC, id DESC);

CREATE INDEX team_member_sessions_session_id_idx ON team_member_sessions (session_id);
CREATE INDEX team_member_sessions_team_member_id_idx ON team_member_sessions (team_member_id);

-- "Who is still checked in" — a small slice of a large table, so a partial index stays tiny
-- however much history accumulates behind it.
CREATE INDEX team_member_sessions_open_idx
    ON team_member_sessions (session_id)
    WHERE check_out_time IS NULL;

-- Sessions ---------------------------------------------------------------------------------
CREATE INDEX sessions_start_desc_idx ON sessions (start_time DESC, id DESC);
CREATE INDEX sessions_location_id_idx ON sessions (location_id);

-- The scheduler's repeated question: which sessions are not finished yet.
CREATE INDEX sessions_unfinished_idx
    ON sessions (start_time)
    WHERE NOT finished;

-- Team members -----------------------------------------------------------------------------
CREATE INDEX team_members_member_type_idx ON team_members (member_type);
CREATE INDEX team_members_name_idx ON team_members (last_name, first_name, id);

-- Notifications ----------------------------------------------------------------------------
-- 0008 added indexes for the send loop; this covers the session-scoped lookup the UI does.
CREATE INDEX notifications_team_member_id_idx ON notifications (team_member_id);
