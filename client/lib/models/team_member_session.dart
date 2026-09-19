import 'package:time_keeper/utils/time_utils.dart';

class TeamMemberSession {
  final String id;
  final String teamMemberId;
  final String sessionId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  TeamMemberSession({
    required this.id,
    required this.teamMemberId,
    required this.sessionId,
    required this.checkInTime,
    this.checkOutTime,
  });

  factory TeamMemberSession.fromJson(Map<String, dynamic> json) {
    return TeamMemberSession(
      id: json['id'] as String,
      teamMemberId: json['teamMemberId'] as String,
      sessionId: json['sessionId'] as String,
      checkInTime: parseServerTime(json['checkInTime'] as String),
      checkOutTime: parseServerTimeOrNull(json['checkOutTime']),
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
