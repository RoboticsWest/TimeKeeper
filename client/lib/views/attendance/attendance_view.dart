import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/team_member_session.pbgrpc.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/attendance/attendance_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class AttendanceView extends HookConsumerWidget {
  const AttendanceView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> teamMemberSessions,
  ) {
    final ids = teamMemberSessions.keys.toList();
    if (ids.isEmpty) {
      SnackBarDialog.info(
        message: 'No attendance records to delete',
      ).show(context);
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
        final client = ref.read(teamMemberSessionServiceProvider);
        for (final id in ids) {
          await client.deleteTeamMemberSession(
            DeleteTeamMemberSessionRequest(id: id),
          );
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} attendance records'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    // Sort by check-in time descending (most recent first)
    final sorted = teamMemberSessions.entries.toList()
      ..sort((a, b) {
        final aTime = a.value.hasCheckInTime()
            ? a.value.checkInTime.seconds.toInt()
            : 0;
        final bTime = b.value.hasCheckInTime()
            ? b.value.checkInTime.seconds.toInt()
            : 0;
        return bTime.compareTo(aTime);
      });

    // Apply text filter
    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      final ms = entry.value;

      final member = teamMembers[ms.teamMemberId];
      final memberName = member?.displayName ?? '';
      final firstName = member?.firstName ?? '';
      final lastName = member?.lastName ?? '';

      final session = sessions[ms.sessionId];
      final location = session != null ? locations[session.locationId] : null;
      final locationName = location?.location ?? '';

      final sessionDate = session != null && session.hasStartTime()
          ? formatDate(session.startTime.toDateTime())
          : '';

      final status = ms.hasCheckOutTime() ? 'completed' : 'checked in';

      return memberName.toLowerCase().contains(filterText) ||
          firstName.toLowerCase().contains(filterText) ||
          lastName.toLowerCase().contains(filterText) ||
          locationName.toLowerCase().contains(filterText) ||
          sessionDate.toLowerCase().contains(filterText) ||
          status.contains(filterText);
    }).toList();

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
                onPressed: () =>
                    _showClearDialog(context, ref, teamMemberSessions),
                icon: Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                label: Text('Clear All', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableFilter(controller: filterController),
          const SizedBox(height: 12),
          Expanded(
            child: EditTable(
              alternatingRows: true,
              headers: [
                BaseTableCell(
                  child: Text('Member', style: TextStyle(color: Colors.white)),
                  flex: 2,
                ),
                BaseTableCell(
                  child: Text('Session', style: TextStyle(color: Colors.white)),
                  flex: 2,
                ),
                BaseTableCell(
                  child: Text(
                    'Check In',
                    style: TextStyle(color: Colors.white),
                  ),
                  flex: 2,
                ),
                BaseTableCell(
                  child: Text(
                    'Check Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  flex: 2,
                ),
                BaseTableCell(
                  child: Text('Status', style: TextStyle(color: Colors.white)),
                ),
              ],
              headerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              editRows: filtered.map((entry) {
                final id = entry.key;
                final ms = entry.value;

                final member = teamMembers[ms.teamMemberId];
                final memberName =
                    member?.displayName ??
                    (member != null
                        ? '${member.firstName} ${member.lastName}'
                        : 'Unknown');

                final session = sessions[ms.sessionId];
                final location = session != null
                    ? locations[session.locationId]
                    : null;

                final sessionLabel = session != null && session.hasStartTime()
                    ? '${formatDate(session.startTime.toDateTime())} @ ${location?.location ?? 'Unknown'}'
                    : 'Unknown session';

                final checkInStr = ms.hasCheckInTime()
                    ? '${formatDate(ms.checkInTime.toDateTime())} ${formatTime(ms.checkInTime.toDateTime())}'
                    : '—';

                final checkOutStr = ms.hasCheckOutTime()
                    ? '${formatDate(ms.checkOutTime.toDateTime())} ${formatTime(ms.checkOutTime.toDateTime())}'
                    : '—';

                final isCheckedIn =
                    ms.hasCheckInTime() && !ms.hasCheckOutTime();

                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () => showAttendanceDialog(
                    context,
                    ref,
                    id: id,
                    existing: ms,
                    memberName: memberName,
                    sessionLabel: sessionLabel,
                  ),
                  onDelete: () => showDeleteAttendanceDialog(
                    context,
                    ref,
                    id: id,
                    memberName: memberName,
                  ),
                  cells: [
                    BaseTableCell(child: Text(memberName), flex: 2),
                    BaseTableCell(child: Text(sessionLabel), flex: 2),
                    BaseTableCell(child: Text(checkInStr), flex: 2),
                    BaseTableCell(child: Text(checkOutStr), flex: 2),
                    BaseTableCell(
                      child: Text(
                        isCheckedIn ? 'Checked In' : 'Completed',
                        style: TextStyle(
                          color: isCheckedIn ? Colors.green : null,
                          fontWeight: isCheckedIn
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
