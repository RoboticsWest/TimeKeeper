import 'package:time_keeper/generated/db/db.pb.dart';

bool isMemberCheckedIn(String memberId, Iterable<Session> sessions) {
  for (final session in sessions) {
    for (final ms in session.memberSessions) {
      if (ms.teamMemberId == memberId &&
          ms.hasCheckInTime() &&
          !ms.hasCheckOutTime()) {
        return true;
      }
    }
  }
  return false;
}
