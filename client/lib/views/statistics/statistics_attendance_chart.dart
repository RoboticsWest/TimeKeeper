import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';

class StatisticsAttendanceChart extends StatelessWidget {
  final List<DayAttendanceData> dailyAttendance;
  final DateTime? selectedDay;
  final ValueChanged<DateTime?> onDaySelected;

  const StatisticsAttendanceChart({
    super.key,
    required this.dailyAttendance,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = theme.colorScheme.secondary;
    final selectedColor = theme.colorScheme.primary;
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
                Icon(Icons.people, size: 18, color: barColor),
                const SizedBox(width: 8),
                Text(
                  'People per Day',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedDay != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => onDaySelected(null),
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear selection'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: dailyAttendance.isEmpty
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
                        barGroups: dailyAttendance.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          final isSelected =
                              selectedDay != null &&
                              d.date.year == selectedDay!.year &&
                              d.date.month == selectedDay!.month &&
                              d.date.day == selectedDay!.day;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: d.uniqueMembers.toDouble(),
                                color: isSelected ? selectedColor : barColor,
                                width: dailyAttendance.length > 14 ? 8 : 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
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
                                if (idx < 0 || idx >= dailyAttendance.length) {
                                  return const SizedBox();
                                }
                                final d = dailyAttendance[idx].date;
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
                              reservedSize: 28,
                              interval: _gridInterval(),
                              getTitlesWidget: (value, meta) {
                                if (value != value.roundToDouble()) {
                                  return const SizedBox();
                                }
                                return Text(
                                  '${value.toInt()}',
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
                              if (idx >= 0 && idx < dailyAttendance.length) {
                                final tappedDate = dailyAttendance[idx].date;
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
                              final d = dailyAttendance[group.x];
                              return BarTooltipItem(
                                '${d.uniqueMembers} members',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
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
    for (final d in dailyAttendance) {
      if (d.uniqueMembers > max) max = d.uniqueMembers.toDouble();
    }
    return (max * 1.2).ceilToDouble().clamp(1, double.infinity);
  }

  double _gridInterval() {
    final max = _maxY();
    if (max <= 5) return 1;
    if (max <= 15) return 2;
    if (max <= 30) return 5;
    return 10;
  }
}
