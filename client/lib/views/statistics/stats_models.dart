import 'package:flutter/foundation.dart';
import 'package:time_keeper/models/team_member.dart';

/// One bucket of the activity series.
@immutable
class HoursBucket {
  /// Start of the bucket (a day, the Monday of a week, or the 1st of a month).
  final DateTime start;
  final Duration regular;
  final Duration overtime;

  /// Distinct members who checked in during this bucket.
  final int headcount;

  const HoursBucket({required this.start, required this.regular, required this.overtime, required this.headcount});

  Duration get total => regular + overtime;
}

/// One row of the members grid.
@immutable
class MemberHoursRow {
  final String memberId;
  final String name;
  final TeamMemberType memberType;
  final Duration regular;
  final Duration overtime;
  final int sessionCount;

  const MemberHoursRow({
    required this.memberId,
    required this.name,
    required this.memberType,
    required this.regular,
    required this.overtime,
    required this.sessionCount,
  });

  Duration get total => regular + overtime;

  /// Overtime as a fraction of total time, 0–1.
  double get overtimeRatio {
    final totalSecs = total.inSeconds;
    return totalSecs > 0 ? overtime.inSeconds / totalSecs : 0;
  }
}

/// One row of the location ranking.
@immutable
class LocationRankRow {
  final String locationId;
  final String name;
  final Duration total;
  final int sessionCount;
  final int headcount;

  const LocationRankRow({
    required this.locationId,
    required this.name,
    required this.total,
    required this.sessionCount,
    required this.headcount,
  });

  /// Mean distinct attendees per session at this location.
  double get avgAttendance => sessionCount > 0 ? headcount / sessionCount : 0;
}

/// Weekday x hour check-in density.
@immutable
class CheckInHeatmap {
  /// `counts[weekday 0..6][hour 0..23]`, weekday 0 = Monday.
  final List<List<int>> counts;
  final int maxCount;

  const CheckInHeatmap({required this.counts, required this.maxCount});

  static CheckInHeatmap get empty => CheckInHeatmap(counts: List.generate(7, (_) => List.filled(24, 0)), maxCount: 0);
}

/// Typed attendance insights.
///
/// Typed rather than pre-formatted strings: five of the seven fields used to be
/// display strings, which made period-over-period deltas impossible — you
/// cannot subtract "3:05 PM". Formatting now happens in the widget layer.
@immutable
class AttendanceInsights {
  /// Mean check-in time as minutes from midnight, or null with no data.
  final int? avgCheckInMinute;

  /// Mean of each member's final check-out per day, as minutes from midnight.
  final int? avgCheckOutMinute;
  final Duration? avgVisit;
  final String? busiestLocationId;

  /// 1 = Monday, 7 = Sunday.
  final int? busiestWeekday;
  final int uniqueMembers;
  final double avgAttendancePerSession;

  const AttendanceInsights({
    this.avgCheckInMinute,
    this.avgCheckOutMinute,
    this.avgVisit,
    this.busiestLocationId,
    this.busiestWeekday,
    this.uniqueMembers = 0,
    this.avgAttendancePerSession = 0,
  });
}

/// Headline numbers for the KPI strip.
@immutable
class StatsKpis {
  final Duration totalHours;
  final Duration regularHours;
  final Duration overtimeHours;
  final int sessionCount;
  final int uniqueMembers;
  final int checkInCount;
  final Duration avgVisit;
  final double avgAttendancePerSession;

  const StatsKpis({
    this.totalHours = Duration.zero,
    this.regularHours = Duration.zero,
    this.overtimeHours = Duration.zero,
    this.sessionCount = 0,
    this.uniqueMembers = 0,
    this.checkInCount = 0,
    this.avgVisit = Duration.zero,
    this.avgAttendancePerSession = 0,
  });

  double get overtimeRatio => totalHours.inSeconds > 0 ? overtimeHours.inSeconds / totalHours.inSeconds : 0;
}

/// One member's contribution on a drilled-into day.
@immutable
class DayMemberRow {
  final String memberId;
  final String name;
  final TeamMemberType memberType;
  final DateTime firstCheckIn;
  final DateTime? lastCheckOut;
  final Duration regular;
  final Duration overtime;

  const DayMemberRow({
    required this.memberId,
    required this.name,
    required this.memberType,
    required this.firstCheckIn,
    required this.lastCheckOut,
    required this.regular,
    required this.overtime,
  });

  Duration get total => regular + overtime;
}
