import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/shared_ticker_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/views/statistics/stats_query.dart';

part 'stats_provider.g.dart';

/// Regular vs overtime split for a single member session, clipped to the
/// session's planned window. Time outside that window is overtime.
({Duration regular, Duration overtime}) splitMemberSession(
  TeamMemberSession ms,
  Session session,
  DateTime asOf,
) {
  final checkOut = ms.checkOutTime ?? asOf;
  final total = checkOut.difference(ms.checkInTime);
  if (total <= Duration.zero) return (regular: Duration.zero, overtime: Duration.zero);

  final overlapStart = ms.checkInTime.isAfter(session.startTime) ? ms.checkInTime : session.startTime;
  final overlapEnd = checkOut.isBefore(session.endTime) ? checkOut : session.endTime;
  final regular = overlapEnd.isAfter(overlapStart) ? overlapEnd.difference(overlapStart) : Duration.zero;

  return (regular: regular, overtime: total - regular);
}

/// The dashboard's filter state.
@riverpod
class StatsFilter extends _$StatsFilter {
  @override
  StatsQuery build() => StatsQuery(asOf: _quantise(DateTime.now()));

  void setQuery(StatsQuery query) => state = query;
}

/// Minute resolution: open sessions keep accruing time, but quantising here
/// means the aggregates recompute once a minute rather than on every tick.
DateTime _quantise(DateTime value) =>
    DateTime(value.year, value.month, value.day, value.hour, value.minute);

/// The active query, with `asOf` refreshed from the shared ticker.
@riverpod
StatsQuery statsQuery(Ref ref) {
  final filter = ref.watch(statsFilterProvider);
  final now = ref.watch(sharedTickerProvider(const Duration(seconds: 30))).value ?? DateTime.now();
  return filter.copyWith(asOf: _quantise(now));
}

/// Everything downstream aggregates read from.
///
/// Filters and indexes exactly once. The old helpers each re-scanned every
/// member session per session (O(n*m)); `msBySession` and `msByMember` here
/// turn those into single passes.
class StatsScope {
  final StatsQuery query;
  final DateWindow window;
  final Map<String, Session> sessions;
  final Map<String, Location> locations;
  final Map<String, TeamMember> members;

  /// In-range member sessions, indexed by session id.
  final Map<String, List<TeamMemberSession>> msBySession;

  /// In-range member sessions, indexed by member id.
  final Map<String, List<TeamMemberSession>> msByMember;

  const StatsScope({
    required this.query,
    required this.window,
    required this.sessions,
    required this.locations,
    required this.members,
    required this.msBySession,
    required this.msByMember,
  });

  DateTime get asOf => query.asOf;

  Iterable<TeamMemberSession> get allMemberSessions => msBySession.values.expand((list) => list);
}

/// Filters sessions and member sessions by the query, then indexes them.
@riverpod
StatsScope statsScope(Ref ref, StatsQuery query) {
  ref.watch(sessionsSyncProvider);
  ref.watch(teamMembersSyncProvider);
  ref.watch(locationsSyncProvider);
  ref.watch(teamMemberSessionsSyncProvider);

  final allSessions = ref.watch(sessionsProvider);
  final members = ref.watch(teamMembersProvider);
  final locations = ref.watch(locationsProvider);
  final allMemberSessions = ref.watch(teamMemberSessionsProvider);

  final window = query.resolve();

  final sessions = <String, Session>{};
  for (final entry in allSessions.entries) {
    final session = entry.value;
    if (!window.contains(session.startTime)) continue;
    if (query.locationIds.isNotEmpty && !query.locationIds.contains(session.locationId)) continue;
    sessions[entry.key] = session;
  }

  final msBySession = <String, List<TeamMemberSession>>{};
  final msByMember = <String, List<TeamMemberSession>>{};
  for (final ms in allMemberSessions.values) {
    if (!sessions.containsKey(ms.sessionId)) continue;
    if (query.memberTypes.isNotEmpty) {
      final type = members[ms.teamMemberId]?.memberType;
      if (type == null || !query.memberTypes.contains(type)) continue;
    }
    msBySession.putIfAbsent(ms.sessionId, () => []).add(ms);
    msByMember.putIfAbsent(ms.teamMemberId, () => []).add(ms);
  }

  return StatsScope(
    query: query,
    window: window,
    sessions: sessions,
    locations: locations,
    members: members,
    msBySession: msBySession,
    msByMember: msByMember,
  );
}

/// Start of the bucket containing [value].
DateTime bucketStart(DateTime value, StatsBucket bucket) {
  switch (bucket) {
    case StatsBucket.month:
      return DateTime(value.year, value.month);
    case StatsBucket.week:
      final day = DateTime(value.year, value.month, value.day);
      return day.subtract(Duration(days: day.weekday - 1));
    case StatsBucket.day:
    case StatsBucket.auto:
      return DateTime(value.year, value.month, value.day);
  }
}

DateTime _nextBucket(DateTime start, StatsBucket bucket) {
  switch (bucket) {
    case StatsBucket.month:
      return DateTime(start.year, start.month + 1);
    case StatsBucket.week:
      return start.add(const Duration(days: 7));
    case StatsBucket.day:
    case StatsBucket.auto:
      return start.add(const Duration(days: 1));
  }
}

/// Hours and headcount per bucket.
///
/// Unlike the helper it replaces, this includes unfinished sessions — the KPI
/// overtime figure always counted them, so excluding them here made the chart
/// disagree with the headline number above it.
@riverpod
List<HoursBucket> hoursSeries(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));
  final bucket = query.effectiveBucket();

  final regular = <DateTime, Duration>{};
  final overtime = <DateTime, Duration>{};
  final heads = <DateTime, Set<String>>{};

  for (final entry in scope.msBySession.entries) {
    final session = scope.sessions[entry.key];
    if (session == null) continue;
    final key = bucketStart(session.startTime, bucket);

    for (final ms in entry.value) {
      final split = splitMemberSession(ms, session, scope.asOf);
      regular[key] = (regular[key] ?? Duration.zero) + split.regular;
      overtime[key] = (overtime[key] ?? Duration.zero) + split.overtime;
      heads.putIfAbsent(key, () => <String>{}).add(ms.teamMemberId);
    }
  }

  if (regular.isEmpty) return const [];

  // Emit a continuous series so gaps read as zero rather than closing up.
  final keys = regular.keys.toList()..sort();
  final series = <HoursBucket>[];
  for (var cursor = keys.first; !cursor.isAfter(keys.last); cursor = _nextBucket(cursor, bucket)) {
    series.add(
      HoursBucket(
        start: cursor,
        regular: regular[cursor] ?? Duration.zero,
        overtime: overtime[cursor] ?? Duration.zero,
        headcount: heads[cursor]?.length ?? 0,
      ),
    );
  }
  return series;
}

/// Per-member totals, sorted by total time descending.
@riverpod
List<MemberHoursRow> memberHoursRows(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));
  final rows = <MemberHoursRow>[];

  for (final entry in scope.msByMember.entries) {
    final member = scope.members[entry.key];
    var regular = Duration.zero;
    var overtime = Duration.zero;

    for (final ms in entry.value) {
      final session = scope.sessions[ms.sessionId];
      if (session == null) continue;
      final split = splitMemberSession(ms, session, scope.asOf);
      regular += split.regular;
      overtime += split.overtime;
    }

    rows.add(
      MemberHoursRow(
        memberId: entry.key,
        name: member?.displayName ?? entry.key,
        memberType: member?.memberType ?? TeamMemberType.student,
        regular: regular,
        overtime: overtime,
        sessionCount: entry.value.map((ms) => ms.sessionId).toSet().length,
      ),
    );
  }

  rows.sort((a, b) => b.total.compareTo(a.total));
  return rows;
}

/// Locations ranked by total time logged.
@riverpod
List<LocationRankRow> locationRanking(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));

  final totals = <String, Duration>{};
  final sessionCounts = <String, int>{};
  final heads = <String, int>{};

  for (final entry in scope.sessions.entries) {
    final memberSessions = scope.msBySession[entry.key];
    if (memberSessions == null || memberSessions.isEmpty) continue;

    final locationId = entry.value.locationId;
    var total = Duration.zero;
    for (final ms in memberSessions) {
      final split = splitMemberSession(ms, entry.value, scope.asOf);
      total += split.regular + split.overtime;
    }

    totals[locationId] = (totals[locationId] ?? Duration.zero) + total;
    sessionCounts[locationId] = (sessionCounts[locationId] ?? 0) + 1;
    heads[locationId] =
        (heads[locationId] ?? 0) + memberSessions.map((ms) => ms.teamMemberId).toSet().length;
  }

  final rows = [
    for (final entry in totals.entries)
      LocationRankRow(
        locationId: entry.key,
        name: scope.locations[entry.key]?.location ?? entry.key,
        total: entry.value,
        sessionCount: sessionCounts[entry.key] ?? 0,
        headcount: heads[entry.key] ?? 0,
      ),
  ];

  rows.sort((a, b) => b.total.compareTo(a.total));
  return rows;
}

/// Weekday x hour check-in density.
@riverpod
CheckInHeatmap checkInHeatmap(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));

  final counts = List.generate(7, (_) => List.filled(24, 0));
  var max = 0;

  for (final ms in scope.allMemberSessions) {
    final weekday = ms.checkInTime.weekday - 1;
    final hour = ms.checkInTime.hour;
    final next = counts[weekday][hour] + 1;
    counts[weekday][hour] = next;
    if (next > max) max = next;
  }

  return CheckInHeatmap(counts: counts, maxCount: max);
}

/// Typed attendance insights over the current scope.
@riverpod
AttendanceInsights attendanceInsights(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));

  var checkInMinuteTotal = 0;
  var checkInCount = 0;
  var visitTotal = Duration.zero;
  var visitCount = 0;
  final weekdayCounts = <int, int>{};
  final locationCounts = <String, int>{};
  // Latest check-out per member per day.
  final finalCheckOuts = <String, DateTime>{};

  for (final entry in scope.msBySession.entries) {
    final session = scope.sessions[entry.key];
    if (session == null) continue;

    for (final ms in entry.value) {
      final checkIn = ms.checkInTime;
      checkInMinuteTotal += checkIn.hour * 60 + checkIn.minute;
      checkInCount++;
      weekdayCounts[checkIn.weekday] = (weekdayCounts[checkIn.weekday] ?? 0) + 1;
      locationCounts[session.locationId] = (locationCounts[session.locationId] ?? 0) + 1;

      final checkOut = ms.checkOutTime;
      if (checkOut != null) {
        visitTotal += checkOut.difference(checkIn);
        visitCount++;
        final key = '${ms.teamMemberId}_${checkOut.year}-${checkOut.month}-${checkOut.day}';
        final existing = finalCheckOuts[key];
        if (existing == null || checkOut.isAfter(existing)) finalCheckOuts[key] = checkOut;
      }
    }
  }

  int? avgCheckOutMinute;
  if (finalCheckOuts.isNotEmpty) {
    var total = 0;
    for (final checkOut in finalCheckOuts.values) {
      total += checkOut.hour * 60 + checkOut.minute;
    }
    avgCheckOutMinute = total ~/ finalCheckOuts.length;
  }

  final finished = scope.sessions.entries.where((e) => e.value.finished).toList();
  var avgAttendance = 0.0;
  if (finished.isNotEmpty) {
    var attendance = 0;
    for (final entry in finished) {
      attendance += scope.msBySession[entry.key]?.map((ms) => ms.teamMemberId).toSet().length ?? 0;
    }
    avgAttendance = attendance / finished.length;
  }

  return AttendanceInsights(
    avgCheckInMinute: checkInCount > 0 ? checkInMinuteTotal ~/ checkInCount : null,
    avgCheckOutMinute: avgCheckOutMinute,
    avgVisit: visitCount > 0 ? Duration(seconds: visitTotal.inSeconds ~/ visitCount) : null,
    busiestLocationId: locationCounts.isEmpty
        ? null
        : locationCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key,
    busiestWeekday: weekdayCounts.isEmpty
        ? null
        : weekdayCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key,
    uniqueMembers: scope.msByMember.length,
    avgAttendancePerSession: avgAttendance,
  );
}

/// Headline numbers for the KPI strip.
@riverpod
StatsKpis statsKpis(Ref ref, StatsQuery query) {
  final scope = ref.watch(statsScopeProvider(query));
  final insights = ref.watch(attendanceInsightsProvider(query));

  var regular = Duration.zero;
  var overtime = Duration.zero;
  var checkIns = 0;

  for (final entry in scope.msBySession.entries) {
    final session = scope.sessions[entry.key];
    if (session == null) continue;
    for (final ms in entry.value) {
      final split = splitMemberSession(ms, session, scope.asOf);
      regular += split.regular;
      overtime += split.overtime;
      checkIns++;
    }
  }

  return StatsKpis(
    totalHours: regular + overtime,
    regularHours: regular,
    overtimeHours: overtime,
    sessionCount: scope.sessions.length,
    uniqueMembers: scope.msByMember.length,
    checkInCount: checkIns,
    avgVisit: insights.avgVisit ?? Duration.zero,
    avgAttendancePerSession: insights.avgAttendancePerSession,
  );
}

/// KPIs for the period immediately before the query's window, for deltas.
/// Null when the range has no meaningful predecessor (all time).
@riverpod
StatsKpis? previousKpis(Ref ref, StatsQuery query) {
  final previous = query.previousPeriod();
  if (previous == null) return null;

  // Expressed as a custom range covering the previous window, so it flows
  // through exactly the same aggregation path as the current one.
  final shifted = query.copyWith(
    range: StatsRange.custom,
    customStart: previous.start,
    customEnd: previous.end.subtract(const Duration(days: 1)),
  );
  return ref.watch(statsKpisProvider(shifted));
}

/// Per-member breakdown for a drilled-into bucket.
@riverpod
List<DayMemberRow> dayDetail(Ref ref, StatsQuery query, DateTime day) {
  final scope = ref.watch(statsScopeProvider(query));
  final bucket = query.effectiveBucket();
  final start = bucketStart(day, bucket);
  final end = _nextBucket(start, bucket);

  final regular = <String, Duration>{};
  final overtime = <String, Duration>{};
  final firstIn = <String, DateTime>{};
  final lastOut = <String, DateTime?>{};
  final seen = <String>{};

  for (final entry in scope.msBySession.entries) {
    final session = scope.sessions[entry.key];
    if (session == null) continue;
    if (session.startTime.isBefore(start) || !session.startTime.isBefore(end)) continue;

    for (final ms in entry.value) {
      final split = splitMemberSession(ms, session, scope.asOf);
      final id = ms.teamMemberId;
      regular[id] = (regular[id] ?? Duration.zero) + split.regular;
      overtime[id] = (overtime[id] ?? Duration.zero) + split.overtime;

      final existingIn = firstIn[id];
      if (existingIn == null || ms.checkInTime.isBefore(existingIn)) firstIn[id] = ms.checkInTime;

      final checkOut = ms.checkOutTime;
      if (!seen.contains(id)) {
        lastOut[id] = checkOut;
        seen.add(id);
      } else {
        final existingOut = lastOut[id];
        // A single open session leaves the whole day open.
        if (checkOut == null) {
          lastOut[id] = null;
        } else if (existingOut != null && checkOut.isAfter(existingOut)) {
          lastOut[id] = checkOut;
        }
      }
    }
  }

  final rows = [
    for (final id in regular.keys)
      DayMemberRow(
        memberId: id,
        name: scope.members[id]?.displayName ?? id,
        memberType: scope.members[id]?.memberType ?? TeamMemberType.student,
        firstCheckIn: firstIn[id]!,
        lastCheckOut: lastOut[id],
        regular: regular[id]!,
        overtime: overtime[id]!,
      ),
  ];

  rows.sort((a, b) => b.total.compareTo(a.total));
  return rows;
}
