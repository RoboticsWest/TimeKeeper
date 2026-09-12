import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/widgets/dashboard/kpi_tile.dart';

/// Eight headline numbers with period-over-period deltas.
class KpiStrip extends StatelessWidget {
  final StatsKpis kpis;
  final StatsKpis? previous;

  const KpiStrip({super.key, required this.kpis, this.previous});

  /// Fixed row height. The strip sizes itself from this and its column count,
  /// which is the point — the caller used to wrap it in a hardcoded SizedBox
  /// that did not match the grid's real height, so half the tiles were sliced
  /// off at narrow widths.
  static const double _rowHeight = 72;
  static const double _spacing = 8;

  /// Columns for [width]. Eight across only pays off on a genuinely wide pane:
  /// a tile has to hold a value like "448h 14m" next to a delta chip, which
  /// wants ~160px, and below that the headline number starts ellipsising —
  /// which is the one thing a KPI tile must never do.
  static int columnsFor(double width) {
    if (width >= 1460) return 8;
    if (width >= 760) return 4;
    if (width >= 480) return 3;
    return 2;
  }

  KpiDelta? _delta(num current, num? before, {bool higherIsBetter = true}) {
    if (before == null) return null;
    // A jump from nothing isn't a percentage, so don't invent one.
    if (before == 0) return null;
    return KpiDelta(ratio: (current - before) / before, higherIsBetter: higherIsBetter);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      KpiTile(
        label: 'Total hours',
        value: formatDuration(kpis.totalHours),
        icon: Icons.schedule,
        delta: _delta(kpis.totalHours.inSeconds, previous?.totalHours.inSeconds),
      ),
      KpiTile(
        label: 'Regular',
        value: formatDuration(kpis.regularHours),
        icon: Icons.timelapse,
        delta: _delta(kpis.regularHours.inSeconds, previous?.regularHours.inSeconds),
      ),
      KpiTile(
        label: 'Overtime',
        value: formatDuration(kpis.overtimeHours),
        icon: Icons.running_with_errors,
        // More overtime is not an improvement.
        delta: _delta(
          kpis.overtimeHours.inSeconds,
          previous?.overtimeHours.inSeconds,
          higherIsBetter: false,
        ),
      ),
      KpiTile(
        label: 'Overtime %',
        value: '${(kpis.overtimeRatio * 100).toStringAsFixed(1)}%',
        icon: Icons.percent,
        delta: _delta(kpis.overtimeRatio, previous?.overtimeRatio, higherIsBetter: false),
      ),
      KpiTile(
        label: 'Sessions',
        value: kpis.sessionCount.toString(),
        icon: Icons.event_note,
        delta: _delta(kpis.sessionCount, previous?.sessionCount),
      ),
      KpiTile(
        label: 'Members',
        value: kpis.uniqueMembers.toString(),
        icon: Icons.groups,
        delta: _delta(kpis.uniqueMembers, previous?.uniqueMembers),
      ),
      KpiTile(
        label: 'Check-ins',
        value: kpis.checkInCount.toString(),
        icon: Icons.login,
        delta: _delta(kpis.checkInCount, previous?.checkInCount),
      ),
      KpiTile(
        label: 'Avg / session',
        value: kpis.avgAttendancePerSession.toStringAsFixed(1),
        icon: Icons.person_pin,
        footnote: 'people',
        delta: _delta(kpis.avgAttendancePerSession, previous?.avgAttendancePerSession),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => GridView(
        // A fixed main-axis extent rather than an aspect ratio: the tile's
        // content is a fixed height, so tying it to the column width made the
        // tiles squash or stretch every time the column count changed.
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsFor(constraints.maxWidth),
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          mainAxisExtent: _rowHeight,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: tiles,
      ),
    );
  }
}
