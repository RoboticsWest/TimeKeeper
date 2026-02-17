import 'package:time_keeper/generated/db/db.pb.dart';

/// Time range filter for the statistics dashboard.
enum StatisticsRange { day, week, month, all }

String statisticsRangeLabel(StatisticsRange range) {
  switch (range) {
    case StatisticsRange.day:
      return 'Today';
    case StatisticsRange.week:
      return 'This Week';
    case StatisticsRange.month:
      return 'This Month';
    case StatisticsRange.all:
      return 'All Time';
  }
}

class MemberHoursData {
  final String memberId;
  final String name;
  final TeamMemberType memberType;
  double regularSecs;
  double overtimeSecs;

  MemberHoursData({
    required this.memberId,
    required this.name,
    required this.memberType,
    this.regularSecs = 0,
    this.overtimeSecs = 0,
  });

  double get totalSecs => regularSecs + overtimeSecs;
  double get overtimePercent =>
      totalSecs > 0 ? (overtimeSecs / totalSecs) * 100 : 0;
}

class DayHoursData {
  final DateTime date;
  double regularSecs;
  double overtimeSecs;

  DayHoursData({
    required this.date,
    this.regularSecs = 0,
    this.overtimeSecs = 0,
  });
}

class DayAttendanceData {
  final DateTime date;
  int uniqueMembers;

  DayAttendanceData({required this.date, this.uniqueMembers = 0});
}

class DayMemberDetail {
  final String memberId;
  final String name;
  final TeamMemberType memberType;
  final double regularSecs;
  final double overtimeSecs;

  DayMemberDetail({
    required this.memberId,
    required this.name,
    required this.memberType,
    required this.regularSecs,
    required this.overtimeSecs,
  });

  double get totalSecs => regularSecs + overtimeSecs;
}

class AverageLocationAttendanceData {
  final String locationId;
  final String locationName;
  double checkInCount;

  AverageLocationAttendanceData({
    required this.locationId,
    required this.locationName,
    this.checkInCount = 0,
  });
}

class AttendanceInsights {
  final String avgCheckInTime;
  final String avgCheckOutTime;
  final String avgVisitDuration;
  final String mostActiveLocation;
  final String busiestDay;
  final int uniqueMembers;
  final double avgAttendancePerSession;

  AttendanceInsights({
    required this.avgCheckInTime,
    required this.avgCheckOutTime,
    required this.avgVisitDuration,
    required this.mostActiveLocation,
    required this.busiestDay,
    required this.uniqueMembers,
    required this.avgAttendancePerSession,
  });
}
