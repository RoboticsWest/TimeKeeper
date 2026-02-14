import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/location.pbgrpc.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/views/locations/location_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class LocationsView extends HookConsumerWidget {
  const LocationsView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> locations,
  ) {
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
        final client = ref.read(locationServiceProvider);
        for (final id in ids) {
          await client.deleteLocation(DeleteLocationRequest(id: id));
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} locations'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    final sorted = locations.entries.toList()
      ..sort((a, b) => a.value.location.compareTo(b.value.location));

    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      return entry.value.location.toLowerCase().contains(filterText);
    }).toList();

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
                  child: Text(
                    'Location Name',
                    style: TextStyle(color: Colors.white),
                  ),
                  flex: 3,
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
                final location = entry.value;
                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () => showLocationDialog(
                    context,
                    ref,
                    id: id,
                    existingName: location.location,
                  ),
                  onDelete: () => showDeleteLocationDialog(
                    context,
                    ref,
                    id: id,
                    name: location.location,
                  ),
                  cells: [
                    BaseTableCell(child: Text(location.location), flex: 3),
                  ],
                );
              }).toList(),
              onAdd: () => showLocationDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
