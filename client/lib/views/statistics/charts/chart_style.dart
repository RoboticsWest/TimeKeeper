import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// Shared axis, grid and tooltip styling for the statistics charts.
///
/// The two bar charts this replaces were ~85% identical by line count, which is
/// how they drifted out of sync. Grid and axes are deliberately recessive: the
/// data should be the only assertive thing on the panel.

/// Rounds [maxValue] up to a readable axis maximum. Returns a non-zero value
/// even for empty data so the chart still draws its frame.
double niceMaxY(double maxValue) {
  if (maxValue <= 0) return 1;
  final magnitude = 1.0 * _pow10((maxValue).floor().toString().length - 1);
  for (final step in [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 7.5, 10.0]) {
    final candidate = step * magnitude;
    if (candidate >= maxValue) return candidate;
  }
  return magnitude * 10;
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

/// Horizontal grid spacing giving roughly four or five lines.
double gridInterval(double maxY) => maxY <= 0 ? 1 : maxY / 4;

FlGridData statsGrid(BuildContext context, double maxY) {
  final theme = Theme.of(context);
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: gridInterval(maxY),
    getDrawingHorizontalLine: (_) => FlLine(color: theme.dividerColor, strokeWidth: 1),
  );
}

FlBorderData statsBorder() => FlBorderData(show: false);

/// Axis titles. [leftFormatter] renders a y value; [bottomBuilder] renders the
/// label for bucket index i, returning null to skip it (thinning dense axes).
FlTitlesData statsTitles(
  BuildContext context, {
  required double maxY,
  required String Function(double value) leftFormatter,
  required String? Function(int index) bottomBuilder,
  double leftReservedSize = 44,
}) {
  final theme = Theme.of(context);
  final style = TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10);

  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: gridInterval(maxY),
        reservedSize: leftReservedSize,
        getTitlesWidget: (value, meta) {
          if (value > maxY) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            child: Text(leftFormatter(value), style: style),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        getTitlesWidget: (value, meta) {
          final label = bottomBuilder(value.round());
          if (label == null) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            child: Text(label, style: style),
          );
        },
      ),
    ),
  );
}

/// Tooltip styling shared by the bar charts.
BarTouchData statsBarTouch(
  BuildContext context, {
  required List<String> Function(int index) linesFor,
  void Function(int index)? onTap,
}) {
  final theme = Theme.of(context);

  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
      tooltipBorderRadius: kBorderRadiusRow,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final lines = linesFor(group.x);
        if (lines.isEmpty) return null;
        return BarTooltipItem(
          lines.first,
          TextStyle(color: theme.colorScheme.onInverseSurface, fontSize: 11, fontWeight: FontWeight.w700),
          children: [
            for (final line in lines.skip(1))
              TextSpan(
                text: '\n$line',
                style: TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        );
      },
    ),
    touchCallback: onTap == null
        ? null
        : (event, response) {
            if (event is FlTapUpEvent && response?.spot != null) {
              onTap(response!.spot!.touchedBarGroup.x);
            }
          },
  );
}

/// Crosshair + tooltip for the line/area form of the activity chart.
LineTouchData statsLineTouch(BuildContext context, {required List<String> Function(int index) linesFor}) {
  final theme = Theme.of(context);

  return LineTouchData(
    getTouchedSpotIndicator: (barData, indexes) => [
      for (final _ in indexes)
        TouchedSpotIndicatorData(
          FlLine(color: theme.colorScheme.onSurfaceVariant, strokeWidth: 1),
          FlDotData(
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: bar.color ?? theme.colorScheme.primary,
              // 2px surface ring keeps overlapping marks separable.
              strokeWidth: 2,
              strokeColor: theme.colorScheme.surfaceContainerLowest,
            ),
          ),
        ),
    ],
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
      tooltipBorderRadius: kBorderRadiusRow,
      getTooltipItems: (spots) {
        if (spots.isEmpty) return [];
        final lines = linesFor(spots.first.x.round());
        return [
          for (var i = 0; i < spots.length; i++)
            if (i == 0)
              LineTooltipItem(lines.join('\n'), TextStyle(color: theme.colorScheme.onInverseSurface, fontSize: 11))
            else
              null,
        ];
      },
    ),
  );
}
