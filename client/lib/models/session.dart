class Session {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String locationId;
  final bool finished;

  Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.finished,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      locationId: json['locationId'] as String,
      finished: json['finished'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
    'locationId': locationId,
    'finished': finished,
  };
}
