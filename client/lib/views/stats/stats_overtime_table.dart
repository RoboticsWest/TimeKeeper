import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/views/stats/stats_helpers.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class StatsOvertimeTable extends StatelessWidget {
  final Map<String, MemberHoursData> memberHours;

  const StatsOvertimeTable({super.key, required this.memberHours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final evenColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.02);
    final oddColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);
    final warningBg = Colors.orange.withValues(alpha: 0.15);

    final sorted = memberHours.values.toList()
      ..sort((a, b) => b.overtimeSecs.compareTo(a.overtimeSecs));

    // Only show members who have some overtime
    final withOvertime = sorted.where((m) => m.overtimeSecs > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Overtime Flags',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${withOvertime.length} members with overtime',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (withOvertime.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No overtime recorded in this period',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              // Header
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 32, child: TableHeaderText('#')),
                    Expanded(flex: 3, child: TableHeaderText('Member')),
                    Expanded(flex: 2, child: TableHeaderText('Type')),
                    Expanded(flex: 2, child: TableHeaderText('Regular')),
                    Expanded(flex: 2, child: TableHeaderText('Overtime')),
                    Expanded(flex: 1, child: TableHeaderText('% Overtime')),
                  ],
                ),
              ),
              // Rows
              ...withOvertime.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final isHighOvertime = m.overtimePercent > 25;
                final bgColor = isHighOvertime
                    ? warningBg
                    : (i % 2 == 0 ? evenColor : oddColor);
                final memberType = m.memberType == TeamMemberType.STUDENT
                    ? 'Student'
                    : 'Mentor';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(color: bgColor),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: i < 3
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: i < 3 ? theme.colorScheme.error : null,
                          ),
                        ),
                      ),
                      Expanded(flex: 3, child: Text(m.name)),
                      Expanded(flex: 2, child: Text(memberType)),
                      Expanded(
                        flex: 2,
                        child: Text(formatSecsAsHoursMinutes(m.regularSecs)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          formatSecsAsHoursMinutes(m.overtimeSecs),
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${m.overtimePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: isHighOvertime
                                ? theme.colorScheme.error
                                : null,
                            fontWeight: isHighOvertime
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class AttendanceInsightsCards extends StatelessWidget {
  final AttendanceInsights insights;

  const AttendanceInsightsCards({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InsightCard(
          icon: Icons.login,
          label: 'Avg Check-in',
          value: insights.avgCheckInTime,
          color: Colors.green,
        ),
        _InsightCard(
          icon: Icons.logout,
          label: 'Avg Check-out',
          value: insights.avgCheckOutTime,
          color: Colors.orange,
        ),
        _InsightCard(
          icon: Icons.timelapse,
          label: 'Avg Visit Duration',
          value: insights.avgVisitDuration,
          color: Colors.blue,
        ),
        _InsightCard(
          icon: Icons.location_on,
          label: 'Top Location',
          value: insights.mostActiveLocation,
          color: theme.colorScheme.tertiary,
        ),
        _InsightCard(
          icon: Icons.calendar_today,
          label: 'Busiest Day',
          value: insights.busiestDay,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
