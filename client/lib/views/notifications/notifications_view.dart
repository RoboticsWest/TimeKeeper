import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/providers/notification_page_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/notifications/notification_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/no_rows_notice.dart';
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

  /// Deletes every notification in one request. [total] comes from the pager rather than from a
  /// copy of the whole table held in memory.
  void _showClearDialog(BuildContext context, WidgetRef ref, int total) {
    if (total == 0) {
      SnackBarDialog.info(message: 'No notifications to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Notifications',
      message: Text(
        'Are you sure you want to delete all notifications? '
        '($total ${total == 1 ? 'notification' : 'notifications'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final result = await ref.read(notificationsProvider.notifier).clearAll();
        if (!context.mounted) return;
        switch (result) {
          case ApiSuccess(data: final deleted):
            SnackBarDialog.success(
              message: 'Deleted $deleted ${deleted == 1 ? 'notification' : 'notifications'}',
            ).show(context);
          case ApiFailure(userMessage: final message):
            SnackBarDialog.error(message: message).show(context);
        }
      },
    ).show(context);
  }

  /// Both labels come off the row: the query asks for the session (with its location) and the
  /// member, so there is nothing to look up against a local copy of those tables.
  String _formatSessionLabel(Notification n) {
    final session = n.session;
    if (session == null) return n.sessionId;

    final start = session.startTime;
    final times = '${formatDate(start)} ${formatTime(start)} - ${formatTime(session.endTime)}';
    final location = session.location?.location ?? '';
    return location.isEmpty ? times : '$times @ $location';
  }

  String _formatMemberName(Notification n) {
    final memberId = n.teamMemberId;
    if (memberId == null || memberId.isEmpty) return '-';
    return n.teamMember?.displayLabel ?? memberId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No collection is watched or built here. The list is server-paged and its rows carry the
    // session and member they name, so there is nothing local to resolve ids against; the dialogs
    // this view opens pick from the full sets themselves.
    final theme = Theme.of(context);

    final page = ref.watch(notificationPageProvider);
    final notifier = ref.read(notificationPageProvider.notifier);
    final currentPage = page.value;

    final filterController = useTextEditingController();
    final search = useDebouncedText(filterController);

    // Push the filter to the paged provider, restarting at page one. The term comes from
    // `useDebouncedText`, which subscribes to the controller — keying an effect on
    // `filterController.text` directly looks right but never fires, because a `TextField` writing
    // to its controller does not rebuild this widget.
    useEffect(() {
      notifier.setFilter(NotificationFilterState(search: search.value));
      return null;
    }, [search.value]);

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
                onPressed: () => _showClearDialog(context, ref, currentPage?.totalCount ?? 0),
                icon: Icon(Icons.delete_sweep, size: 18, color: theme.colorScheme.error),
                label: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableFilter(
            controller: filterController,
            hintText: 'Search by type, status, session or member...',
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
                          BaseTableCell(child: Text(_formatSessionLabel(n)), flex: 4),
                          BaseTableCell(child: Text(_formatMemberName(n)), flex: 2),
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
          if (currentPage != null && currentPage.items.isEmpty)
            NoRowsNotice(
              noun: 'notifications',
              filtered: search.value.trim().isNotEmpty,
              onClearFilters: () {
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
