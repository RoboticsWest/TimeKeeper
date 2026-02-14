import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';
import 'package:time_keeper/widgets/stat_card.dart';

class StatisticsOverviewCards extends StatelessWidget {
  final Map<String, Session> filteredSessions;
  final Map<String, TeamMemberSession> teamMemberSessions;
  final Map<String, MemberHoursData> memberHours;
  final AttendanceInsights insights;

  const StatisticsOverviewCards({
    super.key,
    required this.filteredSessions,
    required this.teamMemberSessions,
    required this.memberHours,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sessionsWithTimes = filteredSessions.entries
        .where((e) => e.value.hasStartTime() && e.value.hasEndTime())
        .toList();

    // Total hours = sum of scheduled session durations
    double totalScheduledSecs = 0;
    double avgSessionDuration = 0;
    for (final e in sessionsWithTimes) {
      totalScheduledSecs += e.value.endTime
          .toDateTime()
          .difference(e.value.startTime.toDateTime())
          .inSeconds;
    }
    if (sessionsWithTimes.isNotEmpty) {
      avgSessionDuration = totalScheduledSecs / sessionsWithTimes.length;
    }

    // Total overtime = per session, how much time extended beyond the
    // scheduled window. For each session: earliest check-in before start
    // counts as pre-overtime, latest check-out after end counts as
    // post-overtime.
    double totalOvertimeSecs = 0;
    for (final e in sessionsWithTimes) {
      final session = e.value;
      final sessionStart = session.startTime.toDateTime();
      final sessionEnd = session.endTime.toDateTime();

      DateTime? earliestCheckIn;
      DateTime? latestCheckOut;

      for (final ms in teamMemberSessions.values) {
        if (ms.sessionId != e.key || !ms.hasCheckInTime()) continue;
        final checkIn = ms.checkInTime.toDateTime();
        if (earliestCheckIn == null || checkIn.isBefore(earliestCheckIn)) {
          earliestCheckIn = checkIn;
        }
        final checkOut = ms.hasCheckOutTime()
            ? ms.checkOutTime.toDateTime()
            : DateTime.now();
        if (latestCheckOut == null || checkOut.isAfter(latestCheckOut)) {
          latestCheckOut = checkOut;
        }
      }

      // Pre-overtime: time before session start
      if (earliestCheckIn != null && earliestCheckIn.isBefore(sessionStart)) {
        totalOvertimeSecs += sessionStart.difference(earliestCheckIn).inSeconds;
      }
      // Post-overtime: time after session end
      if (latestCheckOut != null && latestCheckOut.isAfter(sessionEnd)) {
        totalOvertimeSecs += latestCheckOut.difference(sessionEnd).inSeconds;
      }
    }

    // Total hours includes scheduled time + overtime
    final totalHoursSecs = totalScheduledSecs + totalOvertimeSecs;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StatCard(
          icon: Icons.event,
          label: 'Total Sessions',
          value: '${filteredSessions.length}',
          color: theme.colorScheme.primary,
        ),
        StatCard(
          icon: Icons.schedule,
          label: 'Total Hours',
          value: formatSecsAsHoursMinutes(totalHoursSecs),
          color: theme.colorScheme.secondary,
        ),
        StatCard(
          icon: Icons.timer,
          label: 'Avg Session Duration',
          value: formatSecsAsHoursMinutes(avgSessionDuration),
          color: Colors.blue,
        ),
        StatCard(
          icon: Icons.warning_amber,
          label: 'Total Overtime',
          value: formatSecsAsHoursMinutes(totalOvertimeSecs),
          color: theme.colorScheme.error,
        ),
        StatCard(
          icon: Icons.people,
          label: 'Unique Members',
          value: '${insights.uniqueMembers}',
          color: Colors.green,
        ),
        StatCard(
          icon: Icons.groups,
          label: 'Avg Attendance',
          value: insights.avgAttendancePerSession.toStringAsFixed(1),
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }
}
