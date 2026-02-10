import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/views/stats/stats_helpers.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class StatsMemberHoursTable extends StatelessWidget {
  final Map<String, MemberHoursData> memberHours;

  const StatsMemberHoursTable({super.key, required this.memberHours});

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

    final sorted = memberHours.values.toList()
      ..sort((a, b) => b.totalSecs.compareTo(a.totalSecs));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Member Hours',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${sorted.length} members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No member data for this period',
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
                    Expanded(flex: 2, child: TableHeaderText('Total')),
                  ],
                ),
              ),
              // Rows
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  itemBuilder: (context, i) {
                    final m = sorted[i];
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
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontWeight: i < 3
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: i < 3 ? theme.colorScheme.primary : null,
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: Text(m.name)),
                          Expanded(flex: 2, child: Text(memberType)),
                          Expanded(
                            flex: 2,
                            child: Text(
                              formatSecsAsHoursMinutes(m.regularSecs),
                            ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
