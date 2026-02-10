import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';

class StatisticsHoursChart extends StatelessWidget {
  final List<DayHoursData> dailyHours;
  final DateTime? selectedDay;
  final ValueChanged<DateTime?> onDaySelected;

  const StatisticsHoursChart({
    super.key,
    required this.dailyHours,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final textColor = theme.colorScheme.onSurface;
    final gridColor = theme.colorScheme.outlineVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Hours per Day',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (selectedDay != null) ...[
                  TextButton.icon(
                    onPressed: () => onDaySelected(null),
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear selection'),
                  ),
                  const SizedBox(width: 8),
                ],
                _LegendDot(color: primaryColor, label: 'Regular'),
                const SizedBox(width: 12),
                _LegendDot(color: errorColor, label: 'Overtime'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: dailyHours.isEmpty
                  ? Center(
                      child: Text(
                        'No data for this period',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _maxY(),
                        barGroups: dailyHours.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          final isSelected =
                              selectedDay != null &&
                              d.date.year == selectedDay!.year &&
                              d.date.month == selectedDay!.month &&
                              d.date.day == selectedDay!.day;
                          final opacity = selectedDay != null && !isSelected
                              ? 0.35
                              : 1.0;
                          final regularHours = d.regularSecs / 3600;
                          final overtimeHours = d.overtimeSecs / 3600;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: regularHours + overtimeHours,
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    regularHours,
                                    primaryColor.withValues(alpha: opacity),
                                  ),
                                  if (overtimeHours > 0)
                                    BarChartRodStackItem(
                                      regularHours,
                                      regularHours + overtimeHours,
                                      errorColor.withValues(alpha: opacity),
                                    ),
                                ],
                                width: dailyHours.length > 14 ? 8 : 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                color: Colors.transparent,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= dailyHours.length) {
                                  return const SizedBox();
                                }
                                final d = dailyHours[idx].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${weekdayAbbr[d.weekday - 1]} ${d.day}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}h',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _gridInterval(),
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: gridColor, strokeWidth: 0.5),
                        ),
                        barTouchData: BarTouchData(
                          touchCallback: (event, response) {
                            if (event is FlTapUpEvent &&
                                response?.spot != null) {
                              final idx = response!.spot!.touchedBarGroupIndex;
                              if (idx >= 0 && idx < dailyHours.length) {
                                final tappedDate = dailyHours[idx].date;
                                if (selectedDay != null &&
                                    tappedDate.year == selectedDay!.year &&
                                    tappedDate.month == selectedDay!.month &&
                                    tappedDate.day == selectedDay!.day) {
                                  onDaySelected(null);
                                } else {
                                  onDaySelected(tappedDate);
                                }
                              }
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final d = dailyHours[group.x];
                              final regular = formatSecsAsHoursMinutes(
                                d.regularSecs,
                              );
                              final overtime = formatSecsAsHoursMinutes(
                                d.overtimeSecs,
                              );
                              return BarTooltipItem(
                                'Regular: $regular\nOvertime: $overtime',
                                TextStyle(color: Colors.white, fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _maxY() {
    double max = 0;
    for (final d in dailyHours) {
      final total = (d.regularSecs + d.overtimeSecs) / 3600;
      if (total > max) max = total;
    }
    return (max * 1.2).ceilToDouble().clamp(1, double.infinity);
  }

  double _gridInterval() {
    final max = _maxY();
    if (max <= 4) return 1;
    if (max <= 12) return 2;
    if (max <= 24) return 4;
    return 8;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
