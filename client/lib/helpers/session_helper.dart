import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member_session.dart';

bool isMemberCheckedIn(String memberId, Iterable<TeamMemberSession> teamMemberSessions) {
  for (final ms in teamMemberSessions) {
    if (ms.teamMemberId == memberId && ms.checkOutTime == null) {
      return true;
    }
  }
  return false;
}

/// The instant a visit last changed: its checkout if it has one, otherwise its check-in.
///
/// This is the key the Attendance list and the server's `attendance` page both order by, so
/// "newest first" means the same thing on either side of the wire. `check_out_time` is always at
/// or after `check_in_time`, so no comparison is needed to pick the later of the two.
DateTime lastActivityOf(TeamMemberSession visit) => visit.checkOutTime ?? visit.checkInTime;

/// The session a check-in at [locationId] would land in right now, or null if there is none.
///
/// Mirrors the server's rule in `SessionLogic::check_in_out` so the roster can say which session
/// a member is about to join — and grey out a location where the answer is "none" — instead of
/// letting the admin press a button and read an error. Kept in one place precisely because two
/// copies of this rule would drift.
///
/// The rule: among unfinished sessions at that location whose window ([Session.startTime] minus
/// [checkInWindow] to [Session.endTime] plus [checkInWindow]) contains [now], the closest one,
/// where anything currently in progress counts as distance zero.
MapEntry<String, Session>? eligibleSessionAt({
  required String locationId,
  required Map<String, Session> sessions,
  required Duration checkInWindow,
  DateTime? now,
}) {
  final at = now ?? DateTime.now();
  MapEntry<String, Session>? best;
  Duration? bestDistance;

  for (final entry in sessions.entries) {
    final session = entry.value;
    if (session.finished || session.locationId != locationId) continue;

    if (at.isBefore(session.startTime.subtract(checkInWindow)) || at.isAfter(session.endTime.add(checkInWindow))) {
      continue;
    }

    final distance = at.isBefore(session.startTime)
        ? session.startTime.difference(at)
        : at.isAfter(session.endTime)
        ? at.difference(session.endTime)
        : Duration.zero;

    if (bestDistance == null || distance < bestDistance) {
      best = entry;
      bestDistance = distance;
    }
  }

  return best;
}

/// The attendance row holding a member's open visit, or null when they are not checked in.
MapEntry<String, TeamMemberSession>? openVisitOf(String memberId, Map<String, TeamMemberSession> teamMemberSessions) {
  for (final entry in teamMemberSessions.entries) {
    if (entry.value.teamMemberId == memberId && entry.value.checkOutTime == null) return entry;
  }
  return null;
}
