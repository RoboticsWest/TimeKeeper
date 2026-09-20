-- When a member actually joined, rather than when they first happened to scan in.
--
-- "In TimeKeeper since" was derived from the earliest check-in, because nothing in the schema
-- recorded when a member was added. That reads as an em dash for anybody who has been on the
-- roster for months but has never checked in - which is exactly the person most likely to look.
--
-- Lives on team_member_stats rather than team_members for the same reason the rest of these do:
-- nothing needs a join date to run a session, and the business tables stay untouched.
ALTER TABLE team_member_stats ADD COLUMN joined_at timestamptz DEFAULT now();

COMMENT ON COLUMN team_member_stats.joined_at IS
    'When the member was added. NULL only when no evidence of it survives.';


-- Backfill ---------------------------------------------------------------------------------------
--
-- Two independent sources, and the earlier of the two wins:
--
--   * The member's own id. `PgTeamMemberRepository::add` mints `Uuid::now_v7()`, and a v7 UUID
--     carries its creation time in its first 48 bits as unix milliseconds. For every member added
--     through the app this is not an estimate - it is the exact instant the row was written.
--   * Their earliest check-in, which is what this column replaces.
--
-- The earliest of the two, because a member cannot attend a session before they exist: attendance
-- older than the id means the row was imported or re-created later, and the check-in is then the
-- earlier real evidence of them being here. Taking the id's time alone would date a whole
-- imported season to the afternoon somebody ran the import.

-- Milliseconds out of a v7 UUID, or NULL for any id that is not v7.
--
-- The version nibble is the 13th hex digit. Guarding on it matters: the same 48 bits in a v4 id
-- are random, and would silently backfill a join date somewhere in the year 10,000.
CREATE FUNCTION uuid_v7_timestamp(id uuid) RETURNS timestamptz AS $$
DECLARE
    hex   text := replace(id::text, '-', '');
    epoch_ms bigint;
    stamp timestamptz;
BEGIN
    IF substr(hex, 13, 1) <> '7' THEN
        RETURN NULL;
    END IF;

    epoch_ms := ('x' || substr(hex, 1, 12))::bit(48)::bigint;
    stamp := to_timestamp(epoch_ms / 1000.0);

    -- A v7 id from a clock that was badly wrong is worse than no answer at all, so anything
    -- outside the range this project could plausibly have existed in is discarded.
    IF stamp < timestamptz '2020-01-01' OR stamp > now() + interval '1 day' THEN
        RETURN NULL;
    END IF;

    RETURN stamp;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

UPDATE team_member_stats s
SET joined_at = LEAST(
        uuid_v7_timestamp(s.team_member_id),
        (SELECT MIN(ms.check_in_time) FROM team_member_sessions ms WHERE ms.team_member_id = s.team_member_id)
    )
-- LEAST ignores NULLs, so a member with only one of the two sources still gets that one, and a
-- member with neither is left NULL rather than being dated to the moment this migration ran.
WHERE uuid_v7_timestamp(s.team_member_id) IS NOT NULL
   OR EXISTS (SELECT 1 FROM team_member_sessions ms WHERE ms.team_member_id = s.team_member_id);
