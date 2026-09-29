import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/utils/time_utils.dart';

class TeamMemberSession {
  final String id;
  final String teamMemberId;
  final String sessionId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  /// The member this visit belongs to, when the query asked for them.
  ///
  /// Null when the selection set only requested ids — the kiosk's open-visit set does that, because
  /// it resolves names against the roster it already holds. A list view asks for the nested member
  /// instead and renders straight from it, which is what stops it needing a local copy of the
  /// roster at all.
  final TeamMember? teamMember;

  /// The session this visit belongs to, when the query asked for it. Carries its own nested
  /// location for the same reason.
  final Session? session;

  TeamMemberSession({
    required this.id,
    required this.teamMemberId,
    required this.sessionId,
    required this.checkInTime,
    this.checkOutTime,
    this.teamMember,
    this.session,
  });

  factory TeamMemberSession.fromJson(Map<String, dynamic> json) {
    final member = json['teamMember'] as Map<String, dynamic>?;
    final session = json['session'] as Map<String, dynamic>?;

    return TeamMemberSession(
      id: json['id'] as String,
      teamMemberId: json['teamMemberId'] as String,
      sessionId: json['sessionId'] as String,
      checkInTime: parseServerTime(json['checkInTime'] as String),
      checkOutTime: parseServerTimeOrNull(json['checkOutTime']),
      teamMember: member == null ? null : TeamMember.fromJson(member),
      session: session == null ? null : Session.fromJson(session),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'teamMemberId': teamMemberId,
    'sessionId': sessionId,
    'checkInTime': toServerTime(checkInTime),
    'checkOutTime': toServerTimeOrNull(checkOutTime),
  };
}
