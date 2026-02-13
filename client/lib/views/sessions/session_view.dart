import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/session.pbgrpc.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/sessions/session_calendar.dart';
import 'package:time_keeper/views/sessions/session_stats.dart';
import 'package:time_keeper/views/sessions/session_table.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

class SessionView extends HookConsumerWidget {
  const SessionView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> sessions,
  ) {
    final ids = sessions.keys.toList();
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No sessions to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Sessions',
      message: Text(
        'Are you sure you want to delete all sessions? '
        '(${ids.length} ${ids.length == 1 ? 'session' : 'sessions'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final client = ref.read(sessionServiceProvider);
        for (final id in ids) {
          await client.deleteSession(DeleteSessionRequest(id: id));
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} sessions'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final theme = Theme.of(context);

    final showCalendar = useState(true);
    final selectedDate = useState<DateTime?>(null);

    // Sort: current first, then upcoming, then passed
    final sorted = sessions.entries.toList()..sort(compareSessionEntries);

    // Filter by selected calendar date
    final filtered = selectedDate.value != null
        ? sorted.where((entry) {
            final dt = entry.value.startTime.toDateTime();
            final sel = selectedDate.value!;
            return dt.year == sel.year &&
                dt.month == sel.month &&
                dt.day == sel.day;
          }).toList()
        : sorted;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Sessions', style: theme.textTheme.headlineMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showClearDialog(context, ref, sessions),
                icon: Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                label: Text('Clear All', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.calendar_month),
                    label: Text('Calendar'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.table_rows),
                    label: Text('Table'),
                  ),
                ],
                selected: {showCalendar.value},
                onSelectionChanged: (value) {
                  showCalendar.value = value.first;
                  if (!value.first) selectedDate.value = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Calendar
          if (showCalendar.value) ...[
            SessionCalendar(
              sessions: sessions,
              selectedDate: selectedDate.value,
              onDateSelected: (date) {
                if (selectedDate.value == date) {
                  selectedDate.value = null;
                } else {
                  selectedDate.value = date;
                }
              },
            ),
            if (selectedDate.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Showing: ${formatDate(selectedDate.value!)}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => selectedDate.value = null,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear filter'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],

          // Stats
          SessionStats(
            sessions: sessions,
            teamMemberSessions: teamMemberSessions,
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(child: SessionTable(sessions: filtered)),
        ],
      ),
    );
  }
}
