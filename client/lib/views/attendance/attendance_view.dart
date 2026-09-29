import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/attendance_page_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/attendance/attendance_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/searchable_dropdown.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/no_rows_notice.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/colors.dart';

class AttendanceView extends HookConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only the filter dropdowns read these collections now — the *rows* carry their own member and
    // session, resolved server-side in the page query. That is what the nested fields are for.
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    // The page itself carries its own loading state.
    final page = ref.watch(attendancePageProvider);
    final notifier = ref.read(attendancePageProvider.notifier);
    final currentPage = page.value;

    // --- Filter state ---------------------------------------------------------------
    final filterController = useTextEditingController();
    final search = useDebouncedText(filterController);
    final selectedSessionId = useState<String?>(null);
    final selectedLocationId = useState<String?>(null);
    final dateRange = useState(AttendanceDateRange.allTime);
    final memberType = useState<String>('all');
    final status = useState(AttendanceStatusFilter.all);

    // Push every filter change to the paged provider, restarting at page one. The search term
    // comes from `useDebouncedText`, which subscribes to the controller — keying this effect on
    // `filterController.text` directly looks right but never fires, because a `TextField` writing
    // to its controller does not rebuild this widget.
    useEffect(
      () {
        notifier.setFilter(
          AttendanceFilterState(
            search: search.value,
            sessionId: selectedSessionId.value,
            locationId: selectedLocationId.value,
            dateRange: dateRange.value,
            memberTypes: memberType.value == 'all' ? const [] : [memberType.value],
            status: status.value,
          ),
        );
        return null;
      },
      [
        search.value,
        selectedSessionId.value,
        selectedLocationId.value,
        dateRange.value,
        memberType.value,
        status.value,
      ],
    );

    // --- Dropdown item builders -----------------------------------------------------
    final sessionItems = sessions.entries.toList()..sort(compareSessionEntries);
    final sessionDropdownItems = sessionItems.map((entry) {
      final session = entry.value;
      final location = locations[session.locationId];
      final locationName = location?.location ?? 'Unknown';
      final dateStr = formatDate(session.startTime);
      final statusLabelText = statusLabel(getSessionStatus(session));
      return (key: entry.key, label: '$dateStr @ $locationName ($statusLabelText)');
    }).toList();

    final locationItems = locations.entries.toList()
      ..sort((a, b) => a.value.location.toLowerCase().compareTo(b.value.location.toLowerCase()));
    final locationDropdownItems = locationItems.map((entry) => (key: entry.key, label: entry.value.location)).toList();

    final hasActiveFilters =
        selectedSessionId.value != null ||
        selectedLocationId.value != null ||
        dateRange.value != AttendanceDateRange.allTime ||
        memberType.value != 'all' ||
        status.value != AttendanceStatusFilter.all ||
        search.value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Attendance', style: theme.textTheme.headlineMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showClearDialog(context, ref, currentPage?.totalCount ?? 0),
                icon: Icon(Icons.delete_sweep, size: 18, color: theme.colorScheme.error),
                label: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown + chip filters
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: SearchableDropdown(
                  label: 'Session',
                  items: sessionDropdownItems,
                  selectedKey: selectedSessionId.value,
                  onSelected: (key) {
                    selectedSessionId.value = key == selectedSessionId.value ? null : key;
                  },
                ),
              ),
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
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<AttendanceDateRange>(
                  initialValue: dateRange.value,
                  decoration: const InputDecoration(labelText: 'When', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: AttendanceDateRange.allTime, child: Text('Any time')),
                    DropdownMenuItem(value: AttendanceDateRange.today, child: Text('Today')),
                    DropdownMenuItem(value: AttendanceDateRange.last7Days, child: Text('Last 7 days')),
                    DropdownMenuItem(value: AttendanceDateRange.last30Days, child: Text('Last 30 days')),
                  ],
                  onChanged: (value) {
                    if (value != null) dateRange.value = value;
                  },
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'student', label: Text('Students')),
                  ButtonSegment(value: 'mentor', label: Text('Mentors')),
                ],
                selected: {memberType.value},
                onSelectionChanged: (value) => memberType.value = value.first,
              ),
              SegmentedButton<AttendanceStatusFilter>(
                segments: const [
                  ButtonSegment(value: AttendanceStatusFilter.all, label: Text('All states')),
                  ButtonSegment(value: AttendanceStatusFilter.checkedIn, label: Text('Checked in')),
                  ButtonSegment(value: AttendanceStatusFilter.completed, label: Text('Completed')),
                ],
                selected: {status.value},
                onSelectionChanged: (value) => status.value = value.first,
              ),
              if (hasActiveFilters)
                IconButton(
                  onPressed: () {
                    filterController.clear();
                    search.submit();
                    selectedSessionId.value = null;
                    selectedLocationId.value = null;
                    dateRange.value = AttendanceDateRange.allTime;
                    memberType.value = 'all';
                    status.value = AttendanceStatusFilter.all;
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Text search (debounced, applied in SQL)
          TableFilter(
            controller: filterController,
            hintText: 'Search members...',
            onSubmitted: search.submit,
            isPending: search.isPending,
            matchCount: currentPage?.totalCount,
          ),
          const SizedBox(height: 12),

          Expanded(
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : EditTable(
                    alternatingRows: true,
                    // Six dense columns; the same per-flex minimum the notifications table uses
                    // keeps them from forcing a horizontal scrollbar in a half-width pane.
                    minFlexWidth: 90,
                    headers: [
                      BaseTableCell(child: TableHeaderText('Member'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Session'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Check In'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Check Out'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Last Update'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Status')),
                    ],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((ms) {
                      // Straight off the row: the query asked for the member and the session's
                      // location, so there is nothing to look up.
                      final memberName = ms.teamMember?.displayLabel ?? 'Unknown';

                      final rowSession = ms.session;
                      final sessionLabel = rowSession == null
                          ? 'Unknown session'
                          : '${formatDate(rowSession.startTime)} @ ${rowSession.location?.location ?? 'Unknown'}';

                      final checkInStr = '${formatDate(ms.checkInTime)} ${formatTime(ms.checkInTime)}';
                      final checkOutStr = ms.checkOutTime != null
                          ? '${formatDate(ms.checkOutTime!)} ${formatTime(ms.checkOutTime!)}'
                          : '—';
                      final isCheckedIn = ms.checkOutTime == null;
                      // The column the list is ordered by, spelled out — otherwise a table sorted
                      // on "whichever of these two is later" reads as sorted on neither.
                      final lastUpdate = lastActivityOf(ms);

                      return EditTableRow(
                        key: ValueKey(ms.id),
                        onEdit: () => showAttendanceDialog(
                          context,
                          ref,
                          id: ms.id,
                          existing: ms,
                          memberName: memberName,
                          sessionLabel: sessionLabel,
                        ),
                        onDelete: () => showDeleteAttendanceDialog(context, ref, id: ms.id, memberName: memberName),
                        cells: [
                          BaseTableCell(child: Text(memberName), flex: 2),
                          BaseTableCell(child: Text(sessionLabel), flex: 2),
                          BaseTableCell(child: Text(checkInStr), flex: 2),
                          BaseTableCell(child: Text(checkOutStr), flex: 2),
                          BaseTableCell(
                            child: Text(formatRelativeTime(lastUpdate), style: theme.textTheme.bodySmall),
                            flex: 2,
                          ),
                          BaseTableCell(
                            child: Text(
                              isCheckedIn ? 'Checked In' : 'Completed',
                              style: TextStyle(
                                color: isCheckedIn ? supportSuccessColor.shade700 : null,
                                fontWeight: isCheckedIn ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          if (currentPage != null && currentPage.items.isEmpty)
            NoRowsNotice(
              noun: 'attendance records',
              filtered: hasActiveFilters,
              onClearFilters: () {
                filterController.clear();
                search.submit();
                selectedSessionId.value = null;
                selectedLocationId.value = null;
                dateRange.value = AttendanceDateRange.allTime;
                memberType.value = 'all';
                status.value = AttendanceStatusFilter.all;
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

  /// Deletes every attendance record in one request.
  ///
  /// [total] is the pager's unfiltered count. This used to read the whole collection to build a
  /// list of ids and then delete them one HTTP request at a time — on a remote server, minutes of
  /// sequential round trips and one change event per row to every connected client.
  Future<void> _showClearDialog(BuildContext context, WidgetRef ref, int total) async {
    if (total == 0) {
      SnackBarDialog.info(message: 'No attendance records to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Attendance',
      message: Text(
        'Are you sure you want to delete all attendance records? '
        '($total ${total == 1 ? 'record' : 'records'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final result = await ref.read(teamMemberSessionsProvider.notifier).clearAll();
        if (!context.mounted) return;
        switch (result) {
          case ApiSuccess(data: final deleted):
            SnackBarDialog.success(
              message: 'Deleted $deleted attendance ${deleted == 1 ? 'record' : 'records'}',
            ).show(context);
          case ApiFailure(userMessage: final message):
            SnackBarDialog.error(message: message).show(context);
        }
      },
    ).show(context);
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
            Text('Could not load attendance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
