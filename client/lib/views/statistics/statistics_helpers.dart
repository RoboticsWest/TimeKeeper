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
  Session session, {
  List<TeamMemberSession>? allMembersForSession,
}) {
  final sessionStart = session.startTime.toDateTime();
  final sessionEnd = session.endTime.toDateTime();
  final checkIn = ms.checkInTime.toDateTime();
  final checkOut = ms.hasCheckOutTime()
      ? ms.checkOutTime.toDateTime()
      : DateTime.now();

  // Determine earliest check-in & latest checkout among all members if provided
  DateTime earliestCheckIn = checkIn;
  DateTime latestCheckOut = checkOut;

  if (allMembersForSession != null && allMembersForSession.isNotEmpty) {
    for (final memberMs in allMembersForSession) {
      final ci = memberMs.checkInTime.toDateTime();
      final co = memberMs.hasCheckOutTime()
          ? memberMs.checkOutTime.toDateTime()
          : DateTime.now();
      if (ci.isBefore(earliestCheckIn)) earliestCheckIn = ci;
      if (co.isAfter(latestCheckOut)) latestCheckOut = co;
    }
  }

  // Effective regular period inside session window
  final effectiveStart = earliestCheckIn.isAfter(sessionStart)
      ? earliestCheckIn
      : sessionStart;
  final effectiveEnd = latestCheckOut.isBefore(sessionEnd)
      ? latestCheckOut
      : sessionEnd;

  final regularSecs = effectiveEnd.isAfter(effectiveStart)
      ? effectiveEnd.difference(effectiveStart).inSeconds.toDouble()
      : 0.0;

  // Overtime: before sessionStart or after sessionEnd
  double overtimeSecs = 0.0;
  if (earliestCheckIn.isBefore(sessionStart)) {
    overtimeSecs += sessionStart
        .difference(earliestCheckIn)
        .inSeconds
        .toDouble();
  }
  if (latestCheckOut.isAfter(sessionEnd)) {
    overtimeSecs += latestCheckOut.difference(sessionEnd).inSeconds.toDouble();
  }

  return (regularSecs: regularSecs, overtimeSecs: overtimeSecs);
}

Map<String, MemberHoursData> computeMemberHours(
  Map<String, Session> sessions,
  Map<String, TeamMember> teamMembers,
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  final result = <String, MemberHoursData>{};

  // Group member sessions by session ID for correct earliest/latest
  final sessionsToMembers = <String, List<TeamMemberSession>>{};
  for (final ms in teamMemberSessions.values) {
    if (!ms.hasCheckInTime()) continue;
    sessionsToMembers.putIfAbsent(ms.sessionId, () => []).add(ms);
  }

  for (final ms in teamMemberSessions.values) {
    if (!ms.hasCheckInTime()) continue;
    final session = sessions[ms.sessionId];
    if (session == null || !session.hasStartTime() || !session.hasEndTime()) {
      continue;
    }

    final member = teamMembers[ms.teamMemberId];
    final name = member?.displayName ?? ms.teamMemberId;
    final memberType = member?.memberType ?? TeamMemberType.STUDENT;

    final allMembers = sessionsToMembers[ms.sessionId];

    final (:regularSecs, :overtimeSecs) = computeMemberSessionHours(
      ms,
      session,
      allMembersForSession: allMembers,
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

  return result;
}

List<DayHoursData> computeDailyHours(
  Map<String, Session> sessions,
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  final byDay = <String, DayHoursData>{};

  for (final sessionEntry in sessions.entries) {
    final session = sessionEntry.value;
    if (!session.hasStartTime() || !session.hasEndTime() || !session.finished)
      continue;

    final sessionStart = session.startTime.toDateTime();
    final sessionEnd = session.endTime.toDateTime();

    DateTime? earliestCheckIn;
    DateTime? latestCheckOut;

    for (final ms in teamMemberSessions.values) {
      if (ms.sessionId != sessionEntry.key || !ms.hasCheckInTime()) continue;
      final checkIn = ms.checkInTime.toDateTime();
      final checkOut = ms.hasCheckOutTime()
          ? ms.checkOutTime.toDateTime()
          : DateTime.now();

      if (earliestCheckIn == null || checkIn.isBefore(earliestCheckIn)) {
        earliestCheckIn = checkIn;
      }
      if (latestCheckOut == null || checkOut.isAfter(latestCheckOut)) {
        latestCheckOut = checkOut;
      }
    }

    if (earliestCheckIn == null || latestCheckOut == null) continue;

    // Regular time: from session start to either last checkout or session end (whichever is earlier)
    final effectiveEnd = latestCheckOut.isBefore(sessionEnd)
        ? latestCheckOut
        : sessionEnd;
    final effectiveStart = earliestCheckIn.isAfter(sessionStart)
        ? earliestCheckIn
        : sessionStart;

    final regularSecs = effectiveEnd.isAfter(effectiveStart)
        ? effectiveEnd.difference(effectiveStart).inSeconds.toDouble()
        : 0.0;

    // Overtime: only if last checkout > planned session end
    final overtimeSecs = latestCheckOut.isAfter(sessionEnd)
        ? latestCheckOut.difference(sessionEnd).inSeconds.toDouble()
        : 0.0;

    final date = DateTime(
      sessionStart.year,
      sessionStart.month,
      sessionStart.day,
    );
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    byDay.putIfAbsent(key, () => DayHoursData(date: date));
    byDay[key]!.regularSecs += regularSecs;
    byDay[key]!.overtimeSecs += overtimeSecs;
  }

  return byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
}

List<DayAttendanceData> computeDailyAttendance(
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  final byDay = <String, Set<String>>{};
  final dates = <String, DateTime>{};

  for (final ms in teamMemberSessions.values) {
    if (!ms.hasCheckInTime()) continue;
    final date = ms.checkInTime.toDateTime();
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    byDay.putIfAbsent(key, () => <String>{});
    byDay[key]!.add(ms.teamMemberId);
    dates.putIfAbsent(key, () => DateTime(date.year, date.month, date.day));
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
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  final accum = <String, DayMemberDetail>{};

  for (final ms in teamMemberSessions.values) {
    if (!ms.hasCheckInTime()) continue;
    final checkInDate = ms.checkInTime.toDateTime();
    if (checkInDate.year != day.year ||
        checkInDate.month != day.month ||
        checkInDate.day != day.day) {
      continue;
    }

    final session = sessions[ms.sessionId];
    if (session == null || !session.hasStartTime() || !session.hasEndTime()) {
      continue;
    }

    final member = teamMembers[ms.teamMemberId];
    final name = member?.displayName ?? ms.teamMemberId;
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

  return accum.values.toList()
    ..sort((a, b) => b.totalSecs.compareTo(a.totalSecs));
}

// Helper class to accumulate totals per location
class _LocationAccumulator {
  final String locationId;
  final String locationName;
  int totalCheckIns = 0; // sum of unique members per session
  int sessionCount = 0; // number of sessions counted

  _LocationAccumulator(this.locationId, this.locationName);
}

List<AverageLocationAttendanceData> computeLocationAttendance(
  Map<String, Session> sessions,
  Map<String, Location> locations,
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  final Map<String, _LocationAccumulator> accum = {};

  for (final entry in sessions.entries) {
    final session = entry.value;
    if (!session.finished) continue;

    final locId = session.locationId;
    final locName = locations[locId]?.location ?? locId;

    final members = teamMemberSessions.values
        .where((ms) => ms.sessionId == entry.key && ms.hasCheckInTime())
        .map((ms) => ms.teamMemberId)
        .toSet();

    if (members.isEmpty) continue;

    accum.putIfAbsent(locId, () => _LocationAccumulator(locId, locName));
    accum[locId]!.totalCheckIns += members.length;
    accum[locId]!.sessionCount += 1;
  }

  return accum.values.map((acc) {
    final avg = acc.sessionCount > 0 ? acc.totalCheckIns / acc.sessionCount : 0;
    return AverageLocationAttendanceData(
      locationId: acc.locationId,
      locationName: acc.locationName,
      checkInCount: avg.toDouble(),
    );
  }).toList()..sort((a, b) => b.checkInCount.compareTo(a.checkInCount));
}

AttendanceInsights computeInsights(
  Map<String, Session> sessions,
  Map<String, Location> locations,
  Map<String, TeamMemberSession> teamMemberSessions,
) {
  int totalCheckInMinutes = 0;
  int checkInCount = 0;
  double totalVisitSecs = 0;
  int visitCount = 0;
  final memberIds = <String>{};
  final dayOfWeekCounts = <int, int>{};
  // Track unique members per session for accurate avg attendance
  final uniqueMembersPerSession = <String, Set<String>>{};
  // Track the final (latest) checkout per member per day
  final finalCheckouts = <String, DateTime>{};

  for (final ms in teamMemberSessions.values) {
    if (!ms.hasCheckInTime()) continue;
    // Only count member sessions that belong to a filtered session
    if (!sessions.containsKey(ms.sessionId)) continue;

    memberIds.add(ms.teamMemberId);

    // Track unique attendance per session
    uniqueMembersPerSession
        .putIfAbsent(ms.sessionId, () => <String>{})
        .add(ms.teamMemberId);

    final checkIn = ms.checkInTime.toDateTime();
    totalCheckInMinutes += checkIn.hour * 60 + checkIn.minute;
    checkInCount++;

    dayOfWeekCounts[checkIn.weekday] =
        (dayOfWeekCounts[checkIn.weekday] ?? 0) + 1;

    if (ms.hasCheckOutTime()) {
      final checkOut = ms.checkOutTime.toDateTime();

      totalVisitSecs += checkOut.difference(checkIn).inSeconds;
      visitCount++;

      // Keep only the latest checkout per member per day
      final key =
          '${ms.teamMemberId}_${checkOut.year}-${checkOut.month}-${checkOut.day}';
      final existing = finalCheckouts[key];
      if (existing == null || checkOut.isAfter(existing)) {
        finalCheckouts[key] = checkOut;
      }
    }
  }

  String avgCheckIn = '-';
  if (checkInCount > 0) {
    final avgMins = totalCheckInMinutes ~/ checkInCount;
    avgCheckIn = formatTimeOfDay(avgMins ~/ 60, avgMins % 60);
  }

  // Average checkout time based on final checkout per member per day
  String avgCheckOut = '-';
  if (finalCheckouts.isNotEmpty) {
    int totalCheckOutMinutes = 0;
    for (final checkOut in finalCheckouts.values) {
      totalCheckOutMinutes += checkOut.hour * 60 + checkOut.minute;
    }
    final avgMins = totalCheckOutMinutes ~/ finalCheckouts.length;
    avgCheckOut = formatTimeOfDay(avgMins ~/ 60, avgMins % 60);
  }

  String avgVisit = '-';
  if (visitCount > 0) {
    avgVisit = formatSecsAsHoursMinutes(totalVisitSecs / visitCount);
  }

  String mostActive = '-';
  if (teamMemberSessions.isNotEmpty) {
    final locCounts = <String, int>{};
    for (final ms in teamMemberSessions.values) {
      if (!ms.hasCheckInTime()) continue;
      final session = sessions[ms.sessionId];
      if (session == null) continue;
      locCounts[session.locationId] = (locCounts[session.locationId] ?? 0) + 1;
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

  double avgAttendance = 0;

  final finishedSessions = sessions.entries
      .where((e) => e.value.finished)
      .map((e) => e.key)
      .toSet();

  if (finishedSessions.isNotEmpty) {
    int totalUniqueAttendance = 0;

    for (final sessionId in finishedSessions) {
      final members = uniqueMembersPerSession[sessionId];
      if (members != null) {
        totalUniqueAttendance += members.length;
      }
    }

    avgAttendance = totalUniqueAttendance / finishedSessions.length;
  }

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
