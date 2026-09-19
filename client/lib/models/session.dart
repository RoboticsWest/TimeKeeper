import 'package:time_keeper/utils/time_utils.dart';

class Session {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String locationId;
  final bool finished;

  /// When the session really began: the first check-in. Null until somebody arrives.
  ///
  /// Session statistics are computed from these, not by summing per-member attendance.
  /// Summing members answers "man-hours" — two 5-hour sessions with ten people each came out
  /// as 100 hours rather than 10.
  final DateTime? actualStartTime;

  /// When the session really ended: the last check-out, and only once nobody is still signed
  /// in. Null while the session is effectively still running.
  final DateTime? actualEndTime;

  Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.finished,
    this.actualStartTime,
    this.actualEndTime,
  });

  /// Scheduled length of the session.
  Duration get scheduledDuration => endTime.difference(startTime);

  /// How long the session actually ran, as of [asOf].
  ///
  /// Falls back to the scheduled window when nobody ever checked in, so a session with no
  /// attendance contributes its planned hours rather than vanishing from the totals.
  Duration actualDuration(DateTime asOf) {
    final start = actualStartTime;
    if (start == null) return Duration.zero;
    final end = actualEndTime ?? (finished ? endTime : asOf);
    final span = end.difference(start);
    return span.isNegative ? Duration.zero : span;
  }

  /// The part of the real run that fell inside the scheduled window.
  Duration regularDuration(DateTime asOf) {
    final start = actualStartTime;
    if (start == null) return Duration.zero;
    final end = actualEndTime ?? (finished ? endTime : asOf);

    final overlapStart = start.isAfter(startTime) ? start : startTime;
    final overlapEnd = end.isBefore(endTime) ? end : endTime;
    if (!overlapEnd.isAfter(overlapStart)) return Duration.zero;
    return overlapEnd.difference(overlapStart);
  }

  /// Time the session ran outside its scheduled window — early starts and late finishes.
  Duration overtimeDuration(DateTime asOf) {
    final total = actualDuration(asOf);
    final regular = regularDuration(asOf);
    final overtime = total - regular;
    return overtime.isNegative ? Duration.zero : overtime;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      startTime: parseServerTime(json['startTime'] as String),
      endTime: parseServerTime(json['endTime'] as String),
      locationId: json['locationId'] as String,
      finished: json['finished'] as bool,
      actualStartTime: parseServerTimeOrNull(json['actualStartTime']),
      actualEndTime: parseServerTimeOrNull(json['actualEndTime']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': toServerTime(startTime),
    'endTime': toServerTime(endTime),
    'locationId': locationId,
    'finished': finished,
    'actualStartTime': toServerTimeOrNull(actualStartTime),
    'actualEndTime': toServerTimeOrNull(actualEndTime),
  };
}
