import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/attendance_counts_provider.dart';
import 'package:time_keeper/widgets/dashboard/kpi_tile.dart';

class SessionStats extends ConsumerWidget {
  final Map<String, Session> sessions;

  const SessionStats({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    // One aggregate row from the server. This tile used to be a `Set` built by walking every
    // attendance record the client had downloaded.
    final uniqueMembers = ref.watch(attendanceSummaryProvider).value?.members;

    final activeSessions = sessions.values.where((s) {
      final status = getSessionStatus(s);
      return status == SessionStatus.current || status == SessionStatus.overtime;
    }).length;
    final upcomingSessions = sessions.values.where((s) => getSessionStatus(s) == SessionStatus.upcoming).length;
    final thisMonth = sessions.values.where((s) {
      final dt = s.startTime;
      return dt.year == now.year && dt.month == now.month;
    }).length;

    return Row(
      children: [
        for (final tile in [
          (icon: Icons.event, label: 'Total', value: '${sessions.length}'),
          (icon: Icons.play_circle, label: 'Active', value: '$activeSessions'),
          (icon: Icons.schedule, label: 'Upcoming', value: '$upcomingSessions'),
          (icon: Icons.calendar_month, label: 'This Month', value: '$thisMonth'),
          (icon: Icons.people, label: 'Unique Members', value: uniqueMembers?.toString() ?? '—'),
        ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: KpiTile(icon: tile.icon, label: tile.label, value: tile.value),
            ),
          ),
      ],
    );
  }
}
