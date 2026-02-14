import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/notification.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/widgets/searchable_dropdown.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

const _notificationTypeLabels = {
  NotificationType.SESSION_START_REMINDER: 'Session Start Reminder',
  NotificationType.SESSION_END_REMINDER: 'Session End Reminder',
  NotificationType.OVERTIME: 'Overtime',
  NotificationType.AUTO_CHECKOUT: 'Auto Checkout',
};

String notificationTypeLabel(NotificationType type) {
  return _notificationTypeLabels[type] ?? 'Unknown';
}

void showNotificationDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  Notification? existing,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit Notification' : 'Add Notification',
    message: _NotificationForm(
      isEdit: isEdit,
      notificationId: id,
      existing: existing,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteNotificationDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
}) {
  ConfirmDialog.warn(
    title: 'Delete Notification',
    message: const Text('Are you sure you want to delete this notification?'),
    confirmText: 'Delete',
    onConfirmAsyncGrpc: () async {
      final client = ref.read(notificationServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteNotification(DeleteNotificationRequest(id: id)),
      );
    },
    showResultDialog: true,
    successMessage: const Text('Notification has been deleted'),
  ).show(context);
}

class _NotificationForm extends HookConsumerWidget {
  final bool isEdit;
  final String? notificationId;
  final Notification? existing;

  const _NotificationForm({
    required this.isEdit,
    this.notificationId,
    this.existing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);

    final selectedType = useState(
      existing?.notificationType ?? NotificationType.SESSION_START_REMINDER,
    );
    final selectedSessionId = useState<String?>(existing?.sessionId);
    final selectedMemberId = useState<String?>(
      existing?.hasTeamMemberId() == true ? existing!.teamMemberId : null,
    );
    final sent = useState(existing?.sent ?? false);
    final isLoading = useState(false);

    // Build sorted session list (oldest first)
    final sortedSessions = sessions.entries.toList()
      ..sort(
        (a, b) => a.value.startTime.seconds.toInt().compareTo(
          b.value.startTime.seconds.toInt(),
        ),
      );

    // Build sorted member list
    final sortedMembers = teamMembers.entries.toList()
      ..sort((a, b) {
        final aName = a.value.displayName.isNotEmpty
            ? a.value.displayName
            : a.value.firstName;
        final bName = b.value.displayName.isNotEmpty
            ? b.value.displayName
            : b.value.firstName;
        return aName.compareTo(bName);
      });

    return SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification type
          DropdownButtonFormField<NotificationType>(
            initialValue: selectedType.value,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: _notificationTypeLabels.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) selectedType.value = value;
            },
          ),
          const SizedBox(height: 16),

          // Session (searchable)
          SearchableDropdown(
            label: 'Session',
            items: [
              for (final entry in sortedSessions)
                (
                  key: entry.key,
                  label: () {
                    final s = entry.value;
                    final start = s.startTime.toDateTime();
                    final end = s.endTime.toDateTime();
                    final loc = locations[s.locationId]?.location ?? '';
                    return loc.isNotEmpty
                        ? '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)} @ $loc'
                        : '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)}';
                  }(),
                ),
            ],
            selectedKey: selectedSessionId.value,
            onSelected: (key) => selectedSessionId.value = key,
          ),
          const SizedBox(height: 16),

          // Team member (searchable, optional)
          SearchableDropdown(
            label: 'Team Member (optional)',
            items: [
              (key: '', label: 'None'),
              for (final entry in sortedMembers)
                (
                  key: entry.key,
                  label: entry.value.displayName.isNotEmpty
                      ? entry.value.displayName
                      : '${entry.value.firstName} ${entry.value.lastName}',
                ),
            ],
            selectedKey: selectedMemberId.value ?? '',
            onSelected: (key) =>
                selectedMemberId.value = key.isEmpty ? null : key,
          ),
          const SizedBox(height: 16),

          // Sent toggle
          SwitchListTile(
            title: const Text('Sent'),
            contentPadding: EdgeInsets.zero,
            value: sent.value,
            onChanged: (value) => sent.value = value,
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (selectedSessionId.value == null) return;

                        isLoading.value = true;
                        try {
                          final client = ref.read(notificationServiceProvider);
                          final GrpcResult<dynamic> result;
                          if (isEdit) {
                            result = await callGrpcEndpoint(
                              () => client.updateNotification(
                                UpdateNotificationRequest(
                                  id: notificationId,
                                  notificationType: selectedType.value,
                                  sessionId: selectedSessionId.value,
                                  teamMemberId: selectedMemberId.value,
                                  sent: sent.value,
                                ),
                              ),
                            );
                          } else {
                            result = await callGrpcEndpoint(
                              () => client.createNotification(
                                CreateNotificationRequest(
                                  notificationType: selectedType.value,
                                  sessionId: selectedSessionId.value!,
                                  teamMemberId: selectedMemberId.value,
                                  sent: sent.value,
                                ),
                              ),
                            );
                          }

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            switch (result) {
                              case GrpcSuccess():
                                SnackBarDialog.success(
                                  message: isEdit
                                      ? 'Notification updated'
                                      : 'Notification created',
                                ).show(context);
                              case GrpcFailure():
                                SnackBarDialog.fromGrpcStatus(
                                  result: result,
                                ).show(context);
                            }
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
