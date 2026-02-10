import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/statistics_data.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';

export 'package:time_keeper/models/statistics_data.dart';
export 'package:time_keeper/utils/formatting.dart'
    show formatSecsAsHoursMinutes;

/// Regular vs overtime for a single member session.
({double regularSecs, double overtimeSecs}) computeMemberSessionHours(
  TeamMemberSession ms,
  Session session,
) {
  final sessionStart = session.startTime.toDateTime();
  final sessionEnd = session.endTime.toDateTime();
  final checkIn = ms.checkInTime.toDateTime();
  final checkOut = ms.hasCheckOutTime()
      ? ms.checkOutTime.toDateTime()
      : DateTime.now();

  final totalSecs = checkOut.difference(checkIn).inSeconds.toDouble();
  if (totalSecs <= 0) return (regularSecs: 0, overtimeSecs: 0);

  final overlapStart = checkIn.isAfter(sessionStart) ? checkIn : sessionStart;
  final overlapEnd = checkOut.isBefore(sessionEnd) ? checkOut : sessionEnd;
  final regularSecs = overlapEnd.isAfter(overlapStart)
      ? overlapEnd.difference(overlapStart).inSeconds.toDouble()
      : 0.0;

  return (regularSecs: regularSecs, overtimeSecs: totalSecs - regularSecs);
}

Map<String, MemberHoursData> computeMemberHours(
  Map<String, Session> sessions,
  Map<String, TeamMember> teamMembers,
) {
  final result = <String, MemberHoursData>{};

  for (final session in sessions.values) {
    if (!session.hasStartTime() || !session.hasEndTime()) continue;
    for (final ms in session.memberSessions) {
      if (!ms.hasCheckInTime()) continue;
      final member = teamMembers[ms.teamMemberId];
      final name = member != null
          ? '${member.firstName} ${member.lastName}'
          : ms.teamMemberId;
      final memberType = member?.memberType ?? TeamMemberType.STUDENT;

      final (:regularSecs, :overtimeSecs) = computeMemberSessionHours(
        ms,
        session,
      );

      final entry = result.putIfAbsent(
        ms.teamMemberId,
        () => MemberHoursData(
          memberId: ms.teamMemberId,
          name: name,
          memberType: memberType,
        ),
      );
      entry.regularSecs += regularSecs;
      entry.overtimeSecs += overtimeSecs;
    }
  }

  return result;
}

List<DayHoursData> computeDailyHours(Map<String, Session> sessions) {
  final byDay = <String, DayHoursData>{};

  for (final session in sessions.values) {
    if (!session.hasStartTime() || !session.hasEndTime()) continue;
    for (final ms in session.memberSessions) {
      if (!ms.hasCheckInTime()) continue;
      final (:regularSecs, :overtimeSecs) = computeMemberSessionHours(
        ms,
        session,
      );
      final date = ms.checkInTime.toDateTime();
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      byDay.putIfAbsent(
        key,
        () => DayHoursData(date: DateTime(date.year, date.month, date.day)),
      );
      byDay[key]!.regularSecs += regularSecs;
      byDay[key]!.overtimeSecs += overtimeSecs;
    }
  }

  return byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
}

List<DayAttendanceData> computeDailyAttendance(Map<String, Session> sessions) {
  final byDay = <String, Set<String>>{};
  final dates = <String, DateTime>{};

  for (final session in sessions.values) {
    for (final ms in session.memberSessions) {
      if (!ms.hasCheckInTime()) continue;
      final date = ms.checkInTime.toDateTime();
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(key, () => <String>{});
      byDay[key]!.add(ms.teamMemberId);
      dates.putIfAbsent(key, () => DateTime(date.year, date.month, date.day));
    }
  }

  final result =
      byDay.entries
          .map(
            (e) => DayAttendanceData(
              date: dates[e.key]!,
              uniqueMembers: e.value.length,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  return result;
}

List<DayMemberDetail> computeDayMemberDetails(
  DateTime day,
  Map<String, Session> sessions,
  Map<String, TeamMember> teamMembers,
) {
  final accum = <String, DayMemberDetail>{};

  for (final session in sessions.values) {
    if (!session.hasStartTime() || !session.hasEndTime()) continue;
    for (final ms in session.memberSessions) {
      if (!ms.hasCheckInTime()) continue;
      final checkInDate = ms.checkInTime.toDateTime();
      if (checkInDate.year != day.year ||
          checkInDate.month != day.month ||
          checkInDate.day != day.day) {
        continue;
      }

      final member = teamMembers[ms.teamMemberId];
      final name = member != null
          ? '${member.firstName} ${member.lastName}'
          : ms.teamMemberId;
      final memberType = member?.memberType ?? TeamMemberType.STUDENT;
      final (:regularSecs, :overtimeSecs) = computeMemberSessionHours(
        ms,
        session,
      );

      final existing = accum[ms.teamMemberId];
      if (existing != null) {
        accum[ms.teamMemberId] = DayMemberDetail(
          memberId: ms.teamMemberId,
          name: name,
          memberType: memberType,
          regularSecs: existing.regularSecs + regularSecs,
          overtimeSecs: existing.overtimeSecs + overtimeSecs,
        );
      } else {
        accum[ms.teamMemberId] = DayMemberDetail(
          memberId: ms.teamMemberId,
          name: name,
          memberType: memberType,
          regularSecs: regularSecs,
          overtimeSecs: overtimeSecs,
        );
      }
    }
  }

  return accum.values.toList()
    ..sort((a, b) => b.totalSecs.compareTo(a.totalSecs));
}

List<LocationAttendanceData> computeLocationAttendance(
  Map<String, Session> sessions,
  Map<String, Location> locations,
) {
  final byLocation = <String, LocationAttendanceData>{};

  for (final session in sessions.values) {
    final locId = session.locationId;
    final locName = locations[locId]?.location ?? locId;
    final count = session.memberSessions
        .where((ms) => ms.hasCheckInTime())
        .length;
    if (count == 0) continue;

    byLocation.putIfAbsent(
      locId,
      () => LocationAttendanceData(locationId: locId, locationName: locName),
    );
    byLocation[locId]!.checkInCount += count;
  }

  return byLocation.values.toList()
    ..sort((a, b) => b.checkInCount.compareTo(a.checkInCount));
}

AttendanceInsights computeInsights(
  Map<String, Session> sessions,
  Map<String, Location> locations,
) {
  int totalCheckInMinutes = 0;
  int totalCheckOutMinutes = 0;
  int checkInCount = 0;
  int checkOutCount = 0;
  double totalVisitSecs = 0;
  int visitCount = 0;
  final memberIds = <String>{};
  final dayOfWeekCounts = <int, int>{};
  int totalAttendance = 0;

  for (final session in sessions.values) {
    for (final ms in session.memberSessions) {
      if (!ms.hasCheckInTime()) continue;
      memberIds.add(ms.teamMemberId);
      totalAttendance++;

      final checkIn = ms.checkInTime.toDateTime();
      totalCheckInMinutes += checkIn.hour * 60 + checkIn.minute;
      checkInCount++;

      dayOfWeekCounts[checkIn.weekday] =
          (dayOfWeekCounts[checkIn.weekday] ?? 0) + 1;

      if (ms.hasCheckOutTime()) {
        final checkOut = ms.checkOutTime.toDateTime();
        totalCheckOutMinutes += checkOut.hour * 60 + checkOut.minute;
        checkOutCount++;

        totalVisitSecs += checkOut.difference(checkIn).inSeconds;
        visitCount++;
      }
    }
  }

  String avgCheckIn = '-';
  if (checkInCount > 0) {
    final avgMins = totalCheckInMinutes ~/ checkInCount;
    avgCheckIn = formatTimeOfDay(avgMins ~/ 60, avgMins % 60);
  }

  String avgCheckOut = '-';
  if (checkOutCount > 0) {
    final avgMins = totalCheckOutMinutes ~/ checkOutCount;
    avgCheckOut = formatTimeOfDay(avgMins ~/ 60, avgMins % 60);
  }

  String avgVisit = '-';
  if (visitCount > 0) {
    avgVisit = formatSecsAsHoursMinutes(totalVisitSecs / visitCount);
  }

  String mostActive = '-';
  if (sessions.isNotEmpty) {
    final locCounts = <String, int>{};
    for (final session in sessions.values) {
      final count = session.memberSessions
          .where((ms) => ms.hasCheckInTime())
          .length;
      if (count > 0) {
        locCounts[session.locationId] =
            (locCounts[session.locationId] ?? 0) + count;
      }
    }
    if (locCounts.isNotEmpty) {
      final topLocId = locCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      mostActive = locations[topLocId]?.location ?? topLocId;
    }
  }

  String busiest = '-';
  if (dayOfWeekCounts.isNotEmpty) {
    final topDay = dayOfWeekCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    busiest = weekdayFull[topDay - 1];
  }

  final avgAttendance = sessions.isNotEmpty
      ? totalAttendance / sessions.length
      : 0.0;

  return AttendanceInsights(
    avgCheckInTime: avgCheckIn,
    avgCheckOutTime: avgCheckOut,
    avgVisitDuration: avgVisit,
    mostActiveLocation: mostActive,
    busiestDay: busiest,
    uniqueMembers: memberIds.length,
    avgAttendancePerSession: avgAttendance,
  );
}

/// Filter sessions by time range based on session start time.
Map<String, Session> filterSessionsByRange(
  Map<String, Session> sessions,
  StatisticsRange range,
) {
  if (range == StatisticsRange.all) return sessions;

  final now = DateTime.now();
  late final DateTime start;
  late final DateTime end;

  switch (range) {
    case StatisticsRange.day:
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day + 1);
    case StatisticsRange.week:
      final monday = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(monday.year, monday.month, monday.day);
      end = DateTime(monday.year, monday.month, monday.day + 7);
    case StatisticsRange.month:
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1);
    case StatisticsRange.all:
      return sessions;
  }

  return Map.fromEntries(
    sessions.entries.where((entry) {
      if (!entry.value.hasStartTime()) return false;
      final dt = entry.value.startTime.toDateTime();
      return !dt.isBefore(start) && dt.isBefore(end);
    }),
  );
}
