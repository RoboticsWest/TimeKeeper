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
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'teamMemberId': teamMemberId,
    'sessionId': sessionId,
    'checkInTime': checkInTime.toUtc().toIso8601String(),
    'checkOutTime': checkOutTime?.toUtc().toIso8601String(),
  };
}
