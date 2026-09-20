import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/attendance_page_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/attendance/attendance_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/searchable_dropdown.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/colors.dart';

class AttendanceView extends HookConsumerWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(teamMembersSyncProvider);
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    // The page itself carries its own loading state.
    final page = ref.watch(attendancePageProvider);
    final notifier = ref.read(attendancePageProvider.notifier);
    final currentPage = page.value;

    // --- Filter state ---------------------------------------------------------------
    final filterController = useTextEditingController();
    final searchText = useState('');
    final selectedSessionId = useState<String?>(null);
    final selectedLocationId = useState<String?>(null);
    final dateRange = useState(AttendanceDateRange.allTime);
    final memberType = useState<String>('all');
    final status = useState(AttendanceStatusFilter.all);

    // Debounce the search terms before they hit the server query.
    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 350), () {
        searchText.value = filterController.text;
      });
      return timer.cancel;
    }, [filterController.text]);

    // Push every filter change to the paged provider, restarting at page one.
    useEffect(
      () {
        notifier.setFilter(
          AttendanceFilterState(
            search: searchText.value,
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
        searchText.value,
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
        searchText.value.trim().isNotEmpty;

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
                onPressed: () => _showClearDialog(context, ref),
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
          TableFilter(controller: filterController, hintText: 'Search members...'),
          const SizedBox(height: 12),

          Expanded(
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : EditTable(
                    alternatingRows: true,
                    headers: [
                      BaseTableCell(child: TableHeaderText('Member'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Session'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Check In'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Check Out'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Status')),
                    ],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((ms) {
                      final member = teamMembers[ms.teamMemberId];
                      final memberName =
                          member?.displayName ??
                          (member != null ? '${member.firstName} ${member.lastName}' : 'Unknown');

                      final session = sessions[ms.sessionId];
                      final location = session != null ? locations[session.locationId] : null;
                      final sessionLabel = session != null
                          ? '${formatDate(session.startTime)} @ ${location?.location ?? 'Unknown'}'
                          : 'Unknown session';

                      final checkInStr = '${formatDate(ms.checkInTime)} ${formatTime(ms.checkInTime)}';
                      final checkOutStr = ms.checkOutTime != null
                          ? '${formatDate(ms.checkOutTime!)} ${formatTime(ms.checkOutTime!)}'
                          : '—';
                      final isCheckedIn = ms.checkOutTime == null;

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
          if (currentPage != null)
            PaginationBar(
              totalCount: currentPage.totalCount,
              offset: currentPage.offset,
              pageSize: notifier.currentPageSize,
              hasMore: currentPage.hasMore,
              onPageSizeChanged: notifier.setPageSize,
              onPrevious: notifier.previousPage,
              onNext: notifier.nextPage,
            ),
        ],
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context, WidgetRef ref) async {
    // Reads the whole collection only when the destructive action is actually invoked.
    final teamMemberSessions = ref.read(teamMemberSessionsProvider);
    final ids = teamMemberSessions.keys.toList();
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No attendance records to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Attendance',
      message: Text(
        'Are you sure you want to delete all attendance records? '
        '(${ids.length} ${ids.length == 1 ? 'record' : 'records'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final notifier = ref.read(teamMemberSessionsProvider.notifier);
        for (final id in ids) {
          await notifier.delete(id);
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} attendance records'),
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
