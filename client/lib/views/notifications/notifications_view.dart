import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/notification.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/notifications/notification_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class NotificationsView extends HookConsumerWidget {
  const NotificationsView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, Notification> notifications,
  ) {
    final ids = notifications.keys.toList();
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No notifications to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Notifications',
      message: Text(
        'Are you sure you want to delete all notifications? '
        '(${ids.length} ${ids.length == 1 ? 'notification' : 'notifications'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final client = ref.read(notificationServiceProvider);
        for (final id in ids) {
          await client.deleteNotification(DeleteNotificationRequest(id: id));
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} notifications'),
    ).show(context);
  }

  String _formatSessionLabel(
    Map<String, Session> sessions,
    Map<String, Location> locations,
    String sessionId,
  ) {
    final session = sessions[sessionId];
    if (session == null) return sessionId;
    final start = session.startTime.toDateTime();
    final end = session.endTime.toDateTime();
    final location = locations[session.locationId]?.location ?? '';
    if (location.isNotEmpty) {
      return '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)} @ $location';
    }
    return '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)}';
  }

  String _formatMemberName(
    Map<String, TeamMember> teamMembers,
    String? memberId,
  ) {
    if (memberId == null || memberId.isEmpty) return '-';
    final member = teamMembers[memberId];
    if (member == null) return memberId;
    if (member.displayName.isNotEmpty) return member.displayName;
    return '${member.firstName} ${member.lastName}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final notifications = ref.watch(notificationsProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    final sorted = notifications.entries.toList()
      ..sort((a, b) {
        // Sort by session start time descending, then by type
        final sessionA = sessions[a.value.sessionId];
        final sessionB = sessions[b.value.sessionId];
        final startA = sessionA?.startTime.seconds.toInt() ?? 0;
        final startB = sessionB?.startTime.seconds.toInt() ?? 0;
        final cmp = startB.compareTo(startA);
        if (cmp != 0) return cmp;
        return a.value.notificationType.value.compareTo(
          b.value.notificationType.value,
        );
      });

    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      final n = entry.value;
      final typeLabel = notificationTypeLabel(n.notificationType);
      final sessionLabel = _formatSessionLabel(
        sessions,
        locations,
        n.sessionId,
      );
      final memberLabel = _formatMemberName(
        teamMembers,
        n.hasTeamMemberId() ? n.teamMemberId : null,
      );
      final sentLabel = n.sent ? 'sent' : 'pending';
      return typeLabel.toLowerCase().contains(filterText) ||
          sessionLabel.toLowerCase().contains(filterText) ||
          memberLabel.toLowerCase().contains(filterText) ||
          sentLabel.contains(filterText);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Notifications', style: theme.textTheme.headlineMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showClearDialog(context, ref, notifications),
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
                  child: Text('Type', style: TextStyle(color: Colors.white)),
                  flex: 3,
                ),
                BaseTableCell(
                  child: Text('Session', style: TextStyle(color: Colors.white)),
                  flex: 4,
                ),
                BaseTableCell(
                  child: Text('Member', style: TextStyle(color: Colors.white)),
                  flex: 2,
                ),
                BaseTableCell(
                  child: Text('Status', style: TextStyle(color: Colors.white)),
                  flex: 1,
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
                final n = entry.value;
                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () =>
                      showNotificationDialog(context, ref, id: id, existing: n),
                  onDelete: () =>
                      showDeleteNotificationDialog(context, ref, id: id),
                  cells: [
                    BaseTableCell(
                      child: Text(notificationTypeLabel(n.notificationType)),
                      flex: 3,
                    ),
                    BaseTableCell(
                      child: Text(
                        _formatSessionLabel(sessions, locations, n.sessionId),
                      ),
                      flex: 4,
                    ),
                    BaseTableCell(
                      child: Text(
                        _formatMemberName(
                          teamMembers,
                          n.hasTeamMemberId() ? n.teamMemberId : null,
                        ),
                      ),
                      flex: 2,
                    ),
                    BaseTableCell(
                      child: Text(
                        n.sent ? 'Sent' : 'Pending',
                        style: TextStyle(
                          color: n.sent ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                );
              }).toList(),
              onAdd: () => showNotificationDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
