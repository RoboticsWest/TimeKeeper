DROP TRIGGER IF EXISTS team_member_stats_notify ON team_member_stats;
DROP TRIGGER IF EXISTS attendance_stats_notify ON attendance_stats;
DROP TRIGGER IF EXISTS team_members_create_stats ON team_members;
DROP TRIGGER IF EXISTS team_member_sessions_record_check_in ON team_member_sessions;
DROP FUNCTION IF EXISTS create_team_member_stats();
DROP FUNCTION IF EXISTS record_attendance_check_in();
DROP TABLE IF EXISTS team_member_stats;
DROP TABLE IF EXISTS attendance_stats;
