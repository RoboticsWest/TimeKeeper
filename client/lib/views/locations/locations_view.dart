import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/providers/location_page_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/views/locations/location_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/widgets/tables/no_rows_notice.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class LocationsView extends HookConsumerWidget {
  const LocationsView({super.key});

  /// Deletes every location in one request.
  ///
  /// [total] comes from the pager, which already counts every row matching no filter — so this no
  /// longer needs the whole table in memory just to say how many rows it is about to remove, and
  /// the confirmed count comes back from the server.
  void _showClearDialog(BuildContext context, WidgetRef ref, int total) {
    if (total == 0) {
      SnackBarDialog.info(message: 'No locations to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Locations',
      message: Text(
        'Are you sure you want to delete all locations? '
        '($total ${total == 1 ? 'location' : 'locations'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final result = await ref.read(locationsProvider.notifier).clearAll();
        if (!context.mounted) return;
        switch (result) {
          case ApiSuccess(data: final deleted):
            SnackBarDialog.success(
              message: 'Deleted $deleted ${deleted == 1 ? 'location' : 'locations'}',
            ).show(context);
          case ApiFailure(userMessage: final message):
            SnackBarDialog.error(message: message).show(context);
        }
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribed for the live updates the pager refetches on; the unpaged map itself is not read
    // here — "Clear All" is one server-side mutation now, not a loop over every id.
    ref.watch(locationsSyncProvider);
    final theme = Theme.of(context);

    // The table itself is paged server-side.
    final page = ref.watch(locationPageProvider);
    final notifier = ref.read(locationPageProvider.notifier);
    final currentPage = page.value;

    final filterController = useTextEditingController();
    final search = useDebouncedText(filterController);

    // Push the filter to the paged provider, restarting at page one. The term comes from
    // `useDebouncedText`, which subscribes to the controller — keying an effect on
    // `filterController.text` directly looks right but never fires, because a `TextField` writing
    // to its controller does not rebuild this widget.
    useEffect(() {
      notifier.setFilter(LocationFilterState(search: search.value));
      return null;
    }, [search.value]);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Locations', style: theme.textTheme.headlineMedium),
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
            hintText: 'Search locations...',
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
                    headers: [BaseTableCell(child: TableHeaderText('Location Name'), flex: 3)],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((location) {
                      final id = location.id;
                      return EditTableRow(
                        key: ValueKey(id),
                        onEdit: () => showLocationDialog(context, ref, id: id, existingName: location.location),
                        onDelete: () => showDeleteLocationDialog(context, ref, id: id, name: location.location),
                        cells: [BaseTableCell(child: Text(location.location), flex: 3)],
                      );
                    }).toList(),
                    onAdd: () => showLocationDialog(context, ref),
                  ),
          ),
          if (currentPage != null && currentPage.items.isEmpty)
            NoRowsNotice(
              noun: 'locations',
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
            Text('Could not load locations', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
