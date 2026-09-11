class SessionRsvp {
  final String id;
  final String sessionId;
  final String teamMemberId;
  final String status;

  SessionRsvp({required this.id, required this.sessionId, required this.teamMemberId, required this.status});

  factory SessionRsvp.fromJson(Map<String, dynamic> json) {
    return SessionRsvp(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      teamMemberId: json['teamMemberId'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'sessionId': sessionId, 'teamMemberId': teamMemberId, 'status': status};
}

/// Matches the `session_rsvps.status` CHECK constraint on the server.
class RsvpStatus {
  static const going = 'going';
  static const notGoing = 'not_going';
}
