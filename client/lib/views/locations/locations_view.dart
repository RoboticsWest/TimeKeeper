import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/location_page_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/views/locations/location_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class LocationsView extends HookConsumerWidget {
  const LocationsView({super.key});

  void _showClearDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> locations) {
    final ids = locations.keys.toList();
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No locations to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: 'Clear All Locations',
      message: Text(
        'Are you sure you want to delete all locations? '
        '(${ids.length} ${ids.length == 1 ? 'location' : 'locations'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final notifier = ref.read(locationsProvider.notifier);
        for (final id in ids) {
          await notifier.delete(id);
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} locations'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The unpaged map still backs "Clear All", which deletes every location rather than the
    // page on screen.
    ref.watch(locationsSyncProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    // The table itself is paged server-side.
    final page = ref.watch(locationPageProvider);
    final notifier = ref.read(locationPageProvider.notifier);
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
      notifier.setFilter(LocationFilterState(search: searchText.value));
      return null;
    }, [searchText.value]);

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
                onPressed: () => _showClearDialog(context, ref, locations),
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
