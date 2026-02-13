import 'package:time_keeper/generated/db/db.pb.dart';

bool isMemberCheckedIn(
  String memberId,
  Iterable<TeamMemberSession> teamMemberSessions,
) {
  for (final ms in teamMemberSessions) {
    if (ms.teamMemberId == memberId &&
        ms.hasCheckInTime() &&
        !ms.hasCheckOutTime()) {
      return true;
    }
  }
  return false;
}
