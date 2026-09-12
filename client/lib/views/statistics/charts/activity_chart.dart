import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/charts/chart_style.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/views/statistics/stats_query.dart';

/// What the activity panel is plotting.
enum ActivityMetric {
  hours('Hours'),
  headcount('People');

  const ActivityMetric(this.label);

  final String label;
}

/// Hours (regular + overtime, stacked) or headcount over time.
///
/// Headcount is a *metric toggle* on this same panel rather than a second
/// chart: hours and people share an x axis but not a y scale, and putting them
/// on one plot would mean two y axes — never correct.
///
/// Columns up to 31 buckets, switching to a stacked area beyond that, where
/// individual columns stop being separable.
class ActivityChart extends StatelessWidget {
  final List<HoursBucket> series;
  final List<HoursBucket> previousSeries;
  final ActivityMetric metric;
  final StatsBucket bucket;
  final DateTime? selected;
  final void Function(DateTime day)? onSelect;

  const ActivityChart({
    super.key,
    required this.series,
    this.previousSeries = const [],
    required this.metric,
    required this.bucket,
    this.selected,
    this.onSelect,
  });

  static const int _columnLimit = 31;

  String _label(DateTime date) {
    switch (bucket) {
      case StatsBucket.month:
        return monthAbbr[date.month - 1];
      case StatsBucket.week:
        return '${date.day} ${monthAbbr[date.month - 1]}';
      case StatsBucket.day:
      case StatsBucket.auto:
        return '${date.day}/${date.month}';
    }
  }

  double _value(HoursBucket b) =>
      metric == ActivityMetric.headcount ? b.headcount.toDouble() : b.total.inMinutes / 60;

  List<String> _tooltip(int index) {
    if (index < 0 || index >= series.length) return const [];
    final b = series[index];
    if (metric == ActivityMetric.headcount) {
      return [_label(b.start), '${b.headcount} people'];
    }
    return [
      _label(b.start),
      'Regular ${formatDuration(b.regular)}',
      if (b.overtime > Duration.zero) 'Overtime ${formatDuration(b.overtime)}',
      'Total ${formatDuration(b.total)}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final regularColor = seriesColor(0, brightness);
    final overtimeColor = seriesColor(1, brightness);
    final headcountColor = seriesColor(2, brightness);

    final maxValue = series.isEmpty
        ? 0.0
        : series.map(_value).reduce((a, b) => a > b ? a : b);
    final maxY = niceMaxY(maxValue);

    String formatLeft(double value) =>
        metric == ActivityMetric.headcount ? value.round().toString() : '${value.round()}h';

    // Thin the x axis so labels never collide.
    final step = (series.length / 12).ceil().clamp(1, 999);
    String? bottomLabel(int index) {
      if (index < 0 || index >= series.length) return null;
      if (index % step != 0) return null;
      return _label(series[index].start);
    }

    if (series.length > _columnLimit || metric == ActivityMetric.headcount) {
      return LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: statsGrid(context, maxY),
          borderData: statsBorder(),
          titlesData: statsTitles(
            context,
            maxY: maxY,
            leftFormatter: formatLeft,
            bottomBuilder: bottomLabel,
          ),
          lineTouchData: statsLineTouch(context, linesFor: _tooltip),
          lineBarsData: [
            if (previousSeries.isNotEmpty)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < previousSeries.length && i < series.length; i++)
                    FlSpot(i.toDouble(), _value(previousSeries[i])),
                ],
                isCurved: false,
                barWidth: 2,
                // Ghosted previous period, behind the current one.
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                dotData: const FlDotData(show: false),
              ),
            LineChartBarData(
              spots: [
                for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), _value(series[i])),
              ],
              isCurved: false,
              barWidth: 2,
              color: metric == ActivityMetric.headcount ? headcountColor : regularColor,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (metric == ActivityMetric.headcount ? headcountColor : regularColor)
                    .withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: statsGrid(context, maxY),
        borderData: statsBorder(),
        titlesData: statsTitles(
          context,
          maxY: maxY,
          leftFormatter: formatLeft,
          bottomBuilder: bottomLabel,
        ),
        barTouchData: statsBarTouch(
          context,
          linesFor: _tooltip,
          onTap: onSelect == null
              ? null
              : (index) {
                  if (index >= 0 && index < series.length) onSelect!(series[index].start);
                },
        ),
        barGroups: [
          for (var i = 0; i < series.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: _value(series[i]),
                  width: 14,
                  // Rounded data-end only; the base stays square on the axis.
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  rodStackItems: [
                    BarChartRodStackItem(0, series[i].regular.inMinutes / 60, regularColor),
                    BarChartRodStackItem(
                      // 2px-equivalent gap between stacked segments.
                      series[i].regular.inMinutes / 60,
                      _value(series[i]),
                      overtimeColor,
                    ),
                  ],
                  color: regularColor,
                  borderSide: selected != null && series[i].start == selected
                      ? BorderSide(color: theme.colorScheme.onSurface, width: 1.5)
                      : BorderSide.none,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
