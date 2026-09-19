import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';

/// Weekday x hour check-in density.
///
/// Replaces three vague string "insight" cards ("busiest day", "average
/// check-in"), which stated a single derived value with no way to see the shape
/// behind it. A sequential single-hue ramp: light means near zero.
class CheckInHeatmapChart extends StatelessWidget {
  final CheckInHeatmap data;

  const CheckInHeatmapChart({super.key, required this.data});

  /// Hours shown. A robotics team is not checking in at 4am, and cropping
  /// leaves each remaining cell wide enough to read.
  static const int _firstHour = 7;
  static const int _lastHour = 23;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    for (var day = 0; day < 7; day++)
                      Expanded(
                        child: Center(
                          child: Text(
                            weekdayAbbr[day],
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (var day = 0; day < 7; day++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var hour = _firstHour; hour <= _lastHour; hour++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(0.5),
                                  child: Tooltip(
                                    message:
                                        '${weekdayFull[day]} ${formatTimeOfDay(hour, 0)}\n'
                                        '${data.counts[day][hour]} check-ins',
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: data.maxCount == 0
                                            ? theme.colorScheme.surfaceContainerHigh
                                            : Color.lerp(
                                                theme.colorScheme.surfaceContainerHigh,
                                                base,
                                                data.counts[day][hour] / data.maxCount,
                                              ),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 28),
            Expanded(
              child: Row(
                children: [
                  for (var hour = _firstHour; hour <= _lastHour; hour++)
                    Expanded(
                      child: Center(
                        child: Text(
                          hour % 3 == 0 ? '$hour' : '',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
