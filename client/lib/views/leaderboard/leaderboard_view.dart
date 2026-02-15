import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/statistics.pb.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/providers/statistics_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/animated/infinite_vertical_list.dart';

class LeaderboardView extends ConsumerWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return leaderboard.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load leaderboard')),
      data: (response) => _LeaderboardTable(entries: response.entries),
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _LeaderboardTable({required this.entries});

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Leaderboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${entries.length} members',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Center(child: _HeaderText('#'))),
                Expanded(flex: 3, child: _HeaderText('Member')),
                Expanded(flex: 2, child: _HeaderText('Type')),
                Expanded(flex: 2, child: _HeaderText('Session')),
                Expanded(flex: 2, child: _HeaderText('Week')),
                Expanded(flex: 2, child: _HeaderText('Total')),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No data yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : AnimatedInfiniteVerticalList(
                    childHeight: 40,
                    children: List.generate(entries.length, (i) {
                      return Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: i % 2 == 0 ? evenColor : oddColor,
                        ),
                        child: _LeaderboardRow(rank: i + 1, entry: entries[i]),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final member = entry.teamMember;
    final name = member.displayName;
    final memberType = member.memberType == TeamMemberType.STUDENT
        ? 'Student'
        : 'Mentor';

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                color: rank <= 3 ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ),
        Expanded(flex: 3, child: Center(child: Text(name))),
        Expanded(flex: 2, child: Center(child: Text(memberType))),
        Expanded(flex: 2, child: _HoursCell(bucket: entry.activeSession)),
        Expanded(flex: 2, child: _HoursCell(bucket: entry.thisWeek)),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              formatSecsAsHoursMinutes(entry.totalSecs),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _HoursCell extends StatelessWidget {
  final HoursBucket bucket;

  const _HoursCell({required this.bucket});

  @override
  Widget build(BuildContext context) {
    if (bucket.regularSecs == 0 && bucket.overtimeSecs == 0) {
      return const Center(child: Text('-'));
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatSecsAsHoursMinutes(bucket.regularSecs)),
          if (bucket.overtimeSecs > 0) ...[
            const SizedBox(width: 4),
            Text(
              '+${formatSecsAsHoursMinutes(bucket.overtimeSecs)}',
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
