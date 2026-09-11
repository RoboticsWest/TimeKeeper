import 'package:time_keeper/models/team_member_session.dart';

bool isMemberCheckedIn(String memberId, Iterable<TeamMemberSession> teamMemberSessions) {
  for (final ms in teamMemberSessions) {
    if (ms.teamMemberId == memberId && ms.checkOutTime == null) {
      return true;
    }
  }
  return false;
}
