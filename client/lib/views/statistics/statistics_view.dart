import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/stats_provider.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/utils/csv_utils.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/charts/activity_chart.dart';
import 'package:time_keeper/views/statistics/charts/check_in_heatmap_chart.dart';
import 'package:time_keeper/views/statistics/charts/location_ranking.dart';
import 'package:time_keeper/views/statistics/panels/day_inspector.dart';
import 'package:time_keeper/views/statistics/panels/kpi_strip.dart';
import 'package:time_keeper/views/statistics/panels/members_grid.dart';
import 'package:time_keeper/views/statistics/panels/stats_toolbar.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/views/statistics/stats_query.dart';
import 'package:time_keeper/widgets/dashboard/chart_legend.dart';
import 'package:time_keeper/widgets/dashboard/panel.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

/// Statistics dashboard.
///
/// This widget does zero arithmetic — every number on screen comes from a
/// provider keyed by [StatsQuery], so changing the metric toggle or re-sorting
/// a grid recomputes nothing.
class StatisticsView extends HookConsumerWidget {
  const StatisticsView({super.key});

  /// Above this the charts pair up two to a row; below it they stack.
  static const double _wide = 1280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(statsQueryProvider);
    final kpis = ref.watch(statsKpisProvider(query));
    final previous = ref.watch(previousKpisProvider(query));
    final series = ref.watch(hoursSeriesProvider(query));
    final locations = ref.watch(locationRankingProvider(query));
    final members = ref.watch(memberHoursRowsProvider(query));
    final heatmap = ref.watch(checkInHeatmapProvider(query));

    final metric = useState(ActivityMetric.hours);
    final selectedDay = useState<DateTime?>(null);
    final overtimeOnly = useState(false);

    final dayRows = selectedDay.value == null
        ? const <DayMemberRow>[]
        : ref.watch(dayDetailProvider(query, selectedDay.value!));

    final memberRows = overtimeOnly.value ? members.where((row) => row.overtime > Duration.zero).toList() : members;

    Future<void> exportCsv() async {
      final csv = buildCsv(
        ['Member', 'Type', 'Regular', 'Overtime', 'Total', 'Sessions', 'Overtime %'],
        [
          for (final row in memberRows)
            [
              row.name,
              row.memberType.name,
              formatDuration(row.regular),
              formatDuration(row.overtime),
              formatDuration(row.total),
              row.sessionCount.toString(),
              (row.overtimeRatio * 100).toStringAsFixed(1),
            ],
        ],
      );
      final saved = await saveCsvFile(csv, 'timekeeper-statistics.csv');
      if (saved && context.mounted) {
        SnackBarDialog.success(message: 'Statistics exported').show(context);
      }
    }

    final brightness = Theme.of(context).brightness;

    Widget activityPanel() => DashboardPanel(
      title: 'Activity over time',
      subtitle: query.describe(),
      isEmpty: series.isEmpty,
      actions: [
        SegmentedButton<ActivityMetric>(
          segments: [for (final value in ActivityMetric.values) ButtonSegment(value: value, label: Text(value.label))],
          selected: {metric.value},
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (value) => metric.value = value.first,
        ),
        const SizedBox(width: 8),
        SegmentedButton<StatsBucket>(
          segments: [
            for (final value in StatsBucket.values)
              if (value != StatsBucket.auto) ButtonSegment(value: value, label: Text(value.label)),
          ],
          selected: {query.effectiveBucket()},
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (value) {
            selectedDay.value = null;
            ref.read(statsFilterProvider.notifier).setQuery(query.copyWith(bucket: value.first));
          },
        ),
      ],
      footer: metric.value == ActivityMetric.hours
          ? ChartLegend(
              entries: [
                ChartLegendEntry(label: 'Regular', color: seriesColor(0, brightness)),
                ChartLegendEntry(label: 'Overtime', color: seriesColor(1, brightness)),
              ],
            )
          : null,
      child: ActivityChart(
        series: series,
        metric: metric.value,
        bucket: query.effectiveBucket(),
        selected: selectedDay.value,
        onSelect: (day) => selectedDay.value = selectedDay.value == day ? null : day,
      ),
    );

    Widget locationPanel() => DashboardPanel(
      title: 'Location ranking',
      subtitle: 'By total time logged',
      isEmpty: locations.isEmpty,
      child: LocationRanking(rows: locations),
    );

    Widget membersPanel() => DashboardPanel(
      title: 'Members',
      subtitle: '${memberRows.length} in range',
      actions: [
        FilterChip(
          label: const Text('Overtime only'),
          selected: overtimeOnly.value,
          onSelected: (value) => overtimeOnly.value = value,
        ),
      ],
      isEmpty: memberRows.isEmpty,
      child: MembersGrid(rows: memberRows),
    );

    Widget heatmapPanel() => DashboardPanel(
      title: 'Check-in rhythm',
      subtitle: 'Check-ins by weekday and hour',
      isEmpty: heatmap.maxCount == 0,
      child: CheckInHeatmapChart(data: heatmap),
    );

    Widget dayPanel() => DashboardPanel(
      title: 'Day detail — ${formatDate(selectedDay.value!)}',
      subtitle: '${dayRows.length} members',
      height: 220,
      actions: [
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close, size: 18),
          onPressed: () => selectedDay.value = null,
        ),
      ],
      isEmpty: dayRows.isEmpty,
      child: DayInspector(rows: dayRows),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wide;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Both of these size themselves — the toolbar wraps to a second
              // line when it runs out of room and the strip's height follows
              // its column count, so neither can be pinned to a fixed height.
              StatsToolbar(query: query, onExport: exportCsv),
              const SizedBox(height: 8),
              KpiStrip(kpis: kpis, previous: previous),
              const SizedBox(height: 8),
              if (isWide)
                SizedBox(
                  height: 280,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: activityPanel()),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: locationPanel()),
                    ],
                  ),
                )
              else ...[
                SizedBox(height: 280, child: activityPanel()),
                const SizedBox(height: 8),
                SizedBox(height: 240, child: locationPanel()),
              ],
              // Sits below the charts so opening it never reflows them.
              if (selectedDay.value != null) ...[const SizedBox(height: 8), dayPanel()],
              const SizedBox(height: 8),
              if (isWide)
                SizedBox(
                  height: 360,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: membersPanel()),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: heatmapPanel()),
                    ],
                  ),
                )
              else ...[
                SizedBox(height: 360, child: membersPanel()),
                const SizedBox(height: 8),
                SizedBox(height: 260, child: heatmapPanel()),
              ],
            ],
          ),
        );
      },
    );
  }
}
