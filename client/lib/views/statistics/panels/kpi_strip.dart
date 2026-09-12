import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/widgets/dashboard/kpi_tile.dart';

/// Eight headline numbers with period-over-period deltas.
class KpiStrip extends StatelessWidget {
  final StatsKpis kpis;
  final StatsKpis? previous;

  /// Two columns instead of eight, for narrow layouts.
  final bool compact;

  const KpiStrip({super.key, required this.kpis, this.previous, this.compact = false});

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

    return GridView.count(
      crossAxisCount: compact ? 2 : 8,
      childAspectRatio: compact ? 3.4 : 1.9,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}
