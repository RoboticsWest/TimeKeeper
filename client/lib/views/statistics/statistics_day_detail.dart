import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class StatisticsDayDetail extends StatelessWidget {
  final DateTime selectedDay;
  final List<DayMemberDetail> members;
  final VoidCallback onClose;

  const StatisticsDayDetail({
    super.key,
    required this.selectedDay,
    required this.members,
    required this.onClose,
  });

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

    final weekday = weekdayFull[selectedDay.weekday - 1];
    final month = monthAbbr[selectedDay.month - 1];
    final dateStr = '$weekday, $month ${selectedDay.day}';

    double totalRegular = 0;
    double totalOvertime = 0;
    for (final m in members) {
      totalRegular += m.regularSecs;
      totalOvertime += m.overtimeSecs;
    }

    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${members.length} members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${formatSecsAsHoursMinutes(totalRegular)} regular',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (totalOvertime > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '+${formatSecsAsHoursMinutes(totalOvertime)} overtime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Close',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              Center(
                child: Text(
                  'No check-ins on this day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              // Header row
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: TableHeaderText('Member')),
                    Expanded(flex: 2, child: TableHeaderText('Type')),
                    Expanded(flex: 2, child: TableHeaderText('Regular')),
                    Expanded(flex: 2, child: TableHeaderText('Overtime')),
                    Expanded(flex: 2, child: TableHeaderText('Total')),
                  ],
                ),
              ),
              // Member rows
              ...members.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final memberType = m.memberType == TeamMemberType.STUDENT
                    ? 'Student'
                    : 'Mentor';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: i % 2 == 0 ? evenColor : oddColor,
                  ),
                  child: Row(
                    children: [
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
                          style: m.overtimeSecs > 0
                              ? TextStyle(color: theme.colorScheme.error)
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          formatSecsAsHoursMinutes(m.totalSecs),
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
