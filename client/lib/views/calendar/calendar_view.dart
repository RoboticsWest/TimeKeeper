import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/calendar/calendar_table.dart';
import 'package:time_keeper/views/sessions/session_calendar.dart';

class CalendarView extends HookConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final sessions = ref.watch(sessionsProvider);
    final theme = Theme.of(context);

    final showCalendar = useState(true);
    final selectedDate = useState<DateTime?>(null);

    final sorted = sessions.entries.toList()..sort(compareSessionEntries);

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
              Icon(Icons.calendar_month, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Calendar', style: theme.textTheme.headlineMedium),
              const Spacer(),
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

          // Table
          Expanded(child: CalendarTable(sessions: filtered)),
        ],
      ),
    );
  }
}
