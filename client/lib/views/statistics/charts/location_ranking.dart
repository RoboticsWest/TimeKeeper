import 'package:flutter/material.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';

/// Locations ranked by total time logged, as horizontal bars.
///
/// Replaces a pie chart of *average* attendance per session. Averages don't sum
/// to a whole, so pie slices of them were meaningless; a ranked bar answers
/// "which location is busiest" directly and stays readable past three entries.
class LocationRanking extends StatelessWidget {
  final List<LocationRankRow> rows;

  const LocationRanking({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSecs = rows.isEmpty ? 1 : rows.map((r) => r.total.inSeconds).reduce((a, b) => a > b ? a : b);

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final row = rows[index];
        final fraction = maxSecs > 0 ? row.total.inSeconds / maxSecs : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.name,
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Value wears text ink; the bar beside it carries identity.
                Text(
                  formatDuration(row.total),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Tooltip(
              message:
                  '${row.name}\n${formatDuration(row.total)} across ${row.sessionCount} sessions\n'
                  '${row.avgAttendance.toStringAsFixed(1)} people per session',
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: seriesColor(index, theme.brightness),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
