-- Indexes matching the "last activity" orderings the Attendance and Notifications pages use.
--
-- Both lists are ordered by an *expression* over two nullable columns, not by a bare column:
-- attendance by whichever of check-out/check-in is later, notifications by the instant the list
-- actually displays. `0010`'s plain column indexes cannot serve either, so every page load went
-- back to a sequential scan plus a top-N sort — the exact cost `0010` was added to remove.
--
-- Measured on 60k attendance rows: 675 buffers and a full sort (13.2 ms with the page's joins)
-- without this, versus 53 buffers and an index scan (0.1 ms) with it.
--
-- The expressions and their sort direction have to match the queries *exactly* or the planner
-- will not use them. Keep these in step with `query_page` in the two repositories:
--   * team_member_session/repository.rs — COALESCE(check_out_time, check_in_time) DESC, ...
--   * notification/repository.rs        — COALESCE(sent_at, scheduled_for) DESC NULLS LAST, ...
-- `DESC NULLS LAST` is spelled out for notifications because DESC alone defaults to NULLS FIRST,
-- which is a different ordering and a different index.

CREATE INDEX team_member_sessions_last_activity_idx
    ON team_member_sessions ((COALESCE(check_out_time, check_in_time)) DESC, check_in_time DESC, id DESC);

CREATE INDEX notifications_when_idx
    ON notifications ((COALESCE(sent_at, scheduled_for)) DESC NULLS LAST, id DESC);
