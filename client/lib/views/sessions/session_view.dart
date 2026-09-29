import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_page_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/sessions/session_calendar.dart';
import 'package:time_keeper/views/sessions/session_stats.dart';
import 'package:time_keeper/views/sessions/session_table.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/searchable_dropdown.dart';
import 'package:time_keeper/widgets/tables/no_rows_notice.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class SessionView extends HookConsumerWidget {
  const SessionView({super.key});

  /// Deletes every session in one request. Their attendance, notifications and RSVPs cascade.
  void _showClearDialog(BuildContext context, WidgetRef ref, int total) {
    if (total == 0) {
      SnackBarDialog.info(message: 'No sessions to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Sessions',
      message: Text(
        'Are you sure you want to delete all sessions? '
        '($total ${total == 1 ? 'session' : 'sessions'}, along with their attendance and reminders)',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final result = await ref.read(sessionsProvider.notifier).clearAll();
        if (!context.mounted) return;
        switch (result) {
          case ApiSuccess(data: final deleted):
            SnackBarDialog.success(message: 'Deleted $deleted ${deleted == 1 ? 'session' : 'sessions'}').show(context);
          case ApiFailure(userMessage: final message):
            SnackBarDialog.error(message: message).show(context);
        }
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    final showCalendar = useState(true);

    // The day the calendar has selected. It feeds the *same* server filter the table mode's day
    // picker does, so both modes read one list in one order — they used to be two code paths
    // with two different sorts, which is why the table looked like it reshuffled when the mode
    // was switched.
    final selectedDate = useState<DateTime?>(null);

    final filterController = useTextEditingController();
    final search = useDebouncedText(filterController);

    final selectedLocationId = useState<String?>(null);
    final finishedFilter = useState<String>('all');
    final dayFilter = useState<DateTime?>(null);

    final page = ref.watch(sessionPageProvider);
    final notifier = ref.read(sessionPageProvider.notifier);
    final currentPage = page.value;

    final activeDay = showCalendar.value ? selectedDate.value : dayFilter.value;

    useEffect(() {
      notifier.setFilter(
        SessionFilterState(
          locationId: selectedLocationId.value,
          finished: finishedFilter.value == 'all' ? null : finishedFilter.value == 'finished',
          day: activeDay,
          search: search.value,
        ),
      );
      return null;
    }, [selectedLocationId.value, finishedFilter.value, activeDay, search.value]);

    final locationItems = locations.entries.toList()
      ..sort((a, b) => a.value.location.toLowerCase().compareTo(b.value.location.toLowerCase()));
    final locationDropdownItems = locationItems.map((entry) => (key: entry.key, label: entry.value.location)).toList();

    final hasTableFilters =
        selectedLocationId.value != null ||
        finishedFilter.value != 'all' ||
        activeDay != null ||
        search.value.trim().isNotEmpty;

    Future<void> pickDay() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: dayFilter.value ?? now,
        firstDate: now.subtract(const Duration(days: 365 * 5)),
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) dayFilter.value = picked;
    }

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
                onPressed: () => _showClearDialog(context, ref, sessions.length),
                icon: Icon(Icons.delete_sweep, size: 18, color: theme.colorScheme.error),
                label: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
              ),
              const SizedBox(width: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Icons.calendar_month), label: Text('Calendar')),
                  ButtonSegment(value: false, icon: Icon(Icons.table_rows), label: Text('Table')),
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
                    Text('Showing: ${formatDate(selectedDate.value!)}', style: theme.textTheme.titleSmall),
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
          SessionStats(sessions: sessions),
          const SizedBox(height: 16),

          // Filters. Shown in both modes: they narrow the one list below, and hiding them in
          // calendar mode only meant the calendar's table could not be narrowed at all.
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: SearchableDropdown(
                  label: 'Location',
                  items: locationDropdownItems,
                  selectedKey: selectedLocationId.value,
                  onSelected: (key) {
                    selectedLocationId.value = key == selectedLocationId.value ? null : key;
                  },
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'scheduled', label: Text('Scheduled')),
                  ButtonSegment(value: 'finished', label: Text('Finished')),
                ],
                selected: {finishedFilter.value},
                onSelectionChanged: (value) => finishedFilter.value = value.first,
              ),
              // In calendar mode the day comes from the calendar itself, so a second day
              // picker beside it would be two controls fighting over one filter.
              if (!showCalendar.value)
                OutlinedButton.icon(
                  onPressed: pickDay,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(dayFilter.value == null ? 'Pick a day' : formatDate(dayFilter.value!)),
                ),
              if (hasTableFilters)
                IconButton(
                  onPressed: () {
                    selectedLocationId.value = null;
                    finishedFilter.value = 'all';
                    dayFilter.value = null;
                    selectedDate.value = null;
                    filterController.clear();
                    search.submit();
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Searching by location name happens in SQL, so it reaches sessions on later pages.
          TableFilter(
            controller: filterController,
            hintText: 'Search by location...',
            onSubmitted: search.submit,
            isPending: search.isPending,
            matchCount: currentPage?.totalCount,
          ),
          const SizedBox(height: 12),

          // Table
          Expanded(
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : SessionTable(sessions: currentPage.items.map((session) => MapEntry(session.id, session)).toList()),
          ),
          if (currentPage != null && currentPage.items.isEmpty)
            NoRowsNotice(
              noun: 'sessions',
              filtered: hasTableFilters,
              onClearFilters: () {
                selectedLocationId.value = null;
                finishedFilter.value = 'all';
                dayFilter.value = null;
                selectedDate.value = null;
                filterController.clear();
                search.submit();
              },
            ),
          if (currentPage != null)
            PaginationBar(
              totalCount: currentPage.totalCount,
              offset: currentPage.offset,
              pageSize: notifier.currentPageSize,
              hasMore: currentPage.hasMore,
              onPageSizeChanged: notifier.setPageSize,
              onPrevious: notifier.previousPage,
              onNext: notifier.nextPage,
              onFirst: notifier.firstPage,
              onLast: notifier.lastPage,
            ),
        ],
      ),
    );
  }
}

/// Replaces the table area while a fresh page is loading or has failed.
class _LoadingOrError<T> extends StatelessWidget {
  final AsyncValue<T> page;
  final Future<void> Function() onRetry;

  const _LoadingOrError({required this.page, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (page.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load sessions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
