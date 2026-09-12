import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/stats_provider.dart';
import 'package:time_keeper/shapes.dart';
import 'package:time_keeper/views/statistics/stats_query.dart';

/// Range, location and member-type filters, plus CSV export.
///
/// Nine presets don't fit a SegmentedButton, so the range lives in a MenuAnchor
/// with "Custom range…" opening a date-range picker.
class StatsToolbar extends ConsumerWidget {
  /// Below this the title and the controls split onto separate lines.
  static const double _singleLineWidth = 900;

  final StatsQuery query;
  final VoidCallback onExport;

  const StatsToolbar({super.key, required this.query, required this.onExport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider);
    final notifier = ref.read(statsFilterProvider.notifier);

    Future<void> pickCustom() async {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2015),
        lastDate: DateTime(now.year + 1),
        initialDateRange: DateTimeRange(
          start: query.customStart ?? query.resolve().start,
          end: query.customEnd ?? now,
        ),
      );
      if (picked == null) return;
      notifier.setQuery(
        query.copyWith(
          range: StatsRange.custom,
          customStart: picked.start,
          customEnd: picked.end,
        ),
      );
    }

    final title = Row(
      children: [
        Icon(Icons.analytics, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Statistics',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            query.describe(),
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final controls = <Widget>[
      MenuAnchor(
        menuChildren: [
          for (final range in StatsRange.values)
            if (range != StatsRange.custom)
              MenuItemButton(
                onPressed: () => notifier.setQuery(query.copyWith(range: range)),
                child: Text(range.label),
              ),
          const Divider(height: 1),
          MenuItemButton(onPressed: pickCustom, child: const Text('Custom range…')),
        ],
        builder: (context, controller, child) => OutlinedButton.icon(
          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.date_range, size: 16),
          label: Text(query.range.label),
        ),
      ),
      _MultiSelect<String>(
        label: 'Locations',
        selected: query.locationIds,
        options: {
          for (final entry in locations.entries) entry.key: entry.value.location,
        },
        onChanged: (value) => notifier.setQuery(query.copyWith(locationIds: value)),
      ),
      _MultiSelect<TeamMemberType>(
        label: 'Member type',
        selected: query.memberTypes,
        options: {for (final type in TeamMemberType.values) type: type.name},
        onChanged: (value) => notifier.setQuery(query.copyWith(memberTypes: value)),
      ),
      OutlinedButton.icon(
        onPressed: onExport,
        icon: const Icon(Icons.download, size: 16),
        label: const Text('Export CSV'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Four controls plus a title do not fit a narrow pane on one line, and
        // a Row has no way to say so — it just overflows. Below the threshold
        // the controls drop to their own line and wrap among themselves.
        if (constraints.maxWidth >= _singleLineWidth) {
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              for (final control in controls) ...[const SizedBox(width: 8), control],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: controls),
          ],
        );
      },
    );
  }
}

/// Checkbox menu. An empty selection means "all", which is why the button reads
/// "All <label>" rather than showing zero selected.
class _MultiSelect<T> extends StatelessWidget {
  final String label;
  final Set<T> selected;
  final Map<T, String> options;
  final ValueChanged<Set<T>> onChanged;

  const _MultiSelect({
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = selected.isEmpty
        ? 'All ${label.toLowerCase()}'
        : '${selected.length} of ${options.length}';

    return MenuAnchor(
      menuChildren: [
        for (final entry in options.entries)
          CheckboxMenuButton(
            value: selected.contains(entry.key),
            onChanged: (checked) {
              final next = Set<T>.of(selected);
              if (checked ?? false) {
                next.add(entry.key);
              } else {
                next.remove(entry.key);
              }
              onChanged(next);
            },
            child: Text(entry.value),
          ),
        if (selected.isNotEmpty) ...[
          const Divider(height: 1),
          MenuItemButton(onPressed: () => onChanged(<T>{}), child: const Text('Clear')),
        ],
      ],
      builder: (context, controller, child) => OutlinedButton(
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
        ),
        child: Text(text),
      ),
    );
  }
}
