import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/widgets/stat_card.dart';

class SessionStats extends StatelessWidget {
  final Map<String, Session> sessions;

  const SessionStats({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final activeSessions = sessions.values.where((s) {
      final status = getSessionStatus(s);
      return status == SessionStatus.current ||
          status == SessionStatus.overtime;
    }).length;
    final upcomingSessions = sessions.values
        .where((s) => getSessionStatus(s) == SessionStatus.upcoming)
        .length;
    final thisMonth = sessions.values.where((s) {
      final dt = s.startTime.toDateTime();
      return dt.year == now.year && dt.month == now.month;
    }).length;

    final uniqueMembers = <String>{};
    for (final session in sessions.values) {
      for (final ms in session.memberSessions) {
        uniqueMembers.add(ms.teamMemberId);
      }
    }

    return Row(
      children: [
        StatCard(
          icon: Icons.event,
          label: 'Total',
          value: '${sessions.length}',
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.play_circle,
          label: 'Active',
          value: '$activeSessions',
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.schedule,
          label: 'Upcoming',
          value: '$upcomingSessions',
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.calendar_month,
          label: 'This Month',
          value: '$thisMonth',
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.people,
          label: 'Unique Members',
          value: '${uniqueMembers.length}',
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}
