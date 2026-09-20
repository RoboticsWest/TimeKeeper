import 'dart:async';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/notification_page_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/notifications/notification_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/colors.dart';

/// Colour for a notification's lifecycle state, from the reserved support palette.
Color _statusColor(String status) {
  switch (status) {
    case NotificationStatus.sent:
      return supportSuccessColor.shade700;
    case NotificationStatus.pending:
      return supportInfoColor;
    case NotificationStatus.failed:
      return supportErrorColor;
    case NotificationStatus.skipped:
    case NotificationStatus.cancelled:
    default:
      return neutralColor.shade400;
  }
}

/// When the notification went out, or is due to.
String _scheduleLabel(Notification n) {
  final sentAt = n.sentAt;
  if (sentAt != null) return formatDateTime(sentAt);
  final due = n.scheduledFor;
  if (due != null) return formatDateTime(due);
  return '\u2014';
}

class NotificationsView extends HookConsumerWidget {
  const NotificationsView({super.key});

  void _showClearDialog(BuildContext context, WidgetRef ref, Map<String, Notification> notifications) {
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
        final notifier = ref.read(notificationsProvider.notifier);
        for (final id in ids) {
          await notifier.delete(id);
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} notifications'),
    ).show(context);
  }

  String _formatSessionLabel(Map<String, Session> sessions, Map<String, Location> locations, String sessionId) {
    final session = sessions[sessionId];
    if (session == null) return sessionId;
    final start = session.startTime;
    final end = session.endTime;
    final location = locations[session.locationId]?.location ?? '';
    if (location.isNotEmpty) {
      return '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)} @ $location';
    }
    return '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)}';
  }

  String _formatMemberName(Map<String, TeamMember> teamMembers, String? memberId) {
    if (memberId == null || memberId.isEmpty) return '-';
    final member = teamMembers[memberId];
    if (member == null) return memberId;
    if (member.displayName != null && member.displayName!.isNotEmpty) {
      return member.displayName!;
    }
    return '${member.firstName} ${member.lastName}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationsSyncProvider);
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    ref.watch(teamMembersSyncProvider);
    final notifications = ref.watch(notificationsProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final theme = Theme.of(context);

    // The list itself is paged server-side; the maps above only resolve ids to display names.
    final page = ref.watch(notificationPageProvider);
    final notifier = ref.read(notificationPageProvider.notifier);
    final currentPage = page.value;

    final filterController = useTextEditingController();
    final searchText = useState('');

    // Debounce the search term before it hits the server query.
    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 350), () {
        searchText.value = filterController.text;
      });
      return timer.cancel;
    }, [filterController.text]);

    // Push the filter to the paged provider, restarting at page one.
    useEffect(() {
      notifier.setFilter(NotificationFilterState(search: searchText.value));
      return null;
    }, [searchText.value]);

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
                icon: Icon(Icons.delete_sweep, size: 18, color: theme.colorScheme.error),
                label: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableFilter(controller: filterController),
          const SizedBox(height: 12),
          Expanded(
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : EditTable(
                    alternatingRows: true,
                    // Five text-heavy columns spread across 12 flex units would force a 1552px
                    // minimum width (that is what chronically overflowed a half-width pane even
                    // when empty). Like attendance, notifications is five dense columns — 90px
                    // per flex unit lands the same ~1192px natural width it sits at.
                    minFlexWidth: 90,
                    headers: [
                      BaseTableCell(child: TableHeaderText('Type'), flex: 3),
                      BaseTableCell(child: TableHeaderText('Session'), flex: 4),
                      BaseTableCell(child: TableHeaderText('Member'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Status'), flex: 1),
                      BaseTableCell(child: TableHeaderText('When'), flex: 2),
                    ],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((n) {
                      final id = n.id;
                      return EditTableRow(
                        key: ValueKey(id),
                        onEdit: () => showNotificationDialog(context, ref, id: id, existing: n),
                        onDelete: () => showDeleteNotificationDialog(context, ref, id: id),
                        cells: [
                          BaseTableCell(child: Text(notificationTypeLabel(n.notificationType)), flex: 3),
                          BaseTableCell(child: Text(_formatSessionLabel(sessions, locations, n.sessionId)), flex: 4),
                          BaseTableCell(child: Text(_formatMemberName(teamMembers, n.teamMemberId)), flex: 2),
                          BaseTableCell(
                            child: Text(
                              NotificationStatus.label(n.status),
                              style: TextStyle(color: _statusColor(n.status), fontWeight: FontWeight.w500),
                            ),
                            flex: 1,
                          ),
                          BaseTableCell(child: Text(_scheduleLabel(n), style: theme.textTheme.bodySmall), flex: 2),
                        ],
                      );
                    }).toList(),
                    onAdd: () => showNotificationDialog(context, ref),
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
            Text('Could not load notifications', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
