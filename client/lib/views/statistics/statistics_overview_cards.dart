import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';
import 'package:time_keeper/widgets/stat_card.dart';

class StatisticsOverviewCards extends StatelessWidget {
  final Map<String, Session> filteredSessions;
  final Map<String, MemberHoursData> memberHours;
  final AttendanceInsights insights;

  const StatisticsOverviewCards({
    super.key,
    required this.filteredSessions,
    required this.memberHours,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double totalRegular = 0;
    double totalOvertime = 0;
    for (final h in memberHours.values) {
      totalRegular += h.regularSecs;
      totalOvertime += h.overtimeSecs;
    }

    // Average scheduled session duration
    double avgSessionDuration = 0;
    final sessionsWithTimes = filteredSessions.values
        .where((s) => s.hasStartTime() && s.hasEndTime())
        .toList();
    if (sessionsWithTimes.isNotEmpty) {
      double totalScheduledSecs = 0;
      for (final s in sessionsWithTimes) {
        totalScheduledSecs += s.endTime
            .toDateTime()
            .difference(s.startTime.toDateTime())
            .inSeconds;
      }
      avgSessionDuration = totalScheduledSecs / sessionsWithTimes.length;
    }

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
          value: formatSecsAsHoursMinutes(totalRegular + totalOvertime),
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
          value: formatSecsAsHoursMinutes(totalOvertime),
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
