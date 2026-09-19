import 'package:flutter/material.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/widgets/tables/data_grid.dart';

/// Per-member hours.
///
/// A grid rather than a chart: with a full team there are far too many
/// categories for a bar chart to stay readable, and the in-cell proportional
/// bar already carries the comparison.
class MembersGrid extends StatelessWidget {
  final List<MemberHoursRow> rows;

  const MembersGrid({super.key, required this.rows});

  /// Overtime share at which a member is worth flagging.
  static const double _overtimeWarn = 0.25;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSecs = rows.isEmpty ? 1 : rows.map((r) => r.total.inSeconds).reduce((a, b) => a > b ? a : b);

    return DataGrid<MemberHoursRow>(
      rows: rows,
      initialSortColumn: 2,
      columns: [
        GridColumn(
          label: 'Member',
          flex: 3,
          cell: (row) => Text(row.name),
          compare: (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        ),
        GridColumn(
          label: 'Type',
          flex: 2,
          cell: (row) => MemberTypeChip(memberType: row.memberType),
          compare: (a, b) => a.memberType.index.compareTo(b.memberType.index),
        ),
        GridColumn(
          label: 'Total',
          flex: 4,
          cell: (row) => Row(
            children: [
              SizedBox(
                width: 58,
                child: Text(formatDuration(row.total), style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: maxSecs > 0 ? (row.total.inSeconds / maxSecs).clamp(0.0, 1.0) : 0.0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: seriesColor(0, theme.brightness),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          compare: (a, b) => a.total.compareTo(b.total),
        ),
        GridColumn(
          label: 'Sessions',
          alignment: Alignment.centerRight,
          cell: (row) => Text(row.sessionCount.toString()),
          compare: (a, b) => a.sessionCount.compareTo(b.sessionCount),
        ),
        GridColumn(
          label: 'OT %',
          flex: 2,
          cell: (row) => _OvertimeCell(row: row, warnAt: _overtimeWarn),
          compare: (a, b) => a.overtimeRatio.compareTo(b.overtimeRatio),
        ),
      ],
      emptyMessage: 'No members in this range',
    );
  }
}

/// Overtime share as a meter plus, past the threshold, a warning chip.
///
/// The row itself is never tinted: a colored row background makes the text on
/// it harder to read and says nothing a chip doesn't say more precisely.
class _OvertimeCell extends StatelessWidget {
  final MemberHoursRow row;
  final double warnAt;

  const _OvertimeCell({required this.row, required this.warnAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarn = row.overtimeRatio >= warnAt;
    final color = isWarn ? supportWarningColor.shade700 : theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            '${(row.overtimeRatio * 100).round()}%',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: row.overtimeRatio.clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ],
          ),
        ),
        if (isWarn) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: 'Overtime is ${(row.overtimeRatio * 100).round()}% of this member\'s time',
            child: Icon(Icons.warning_amber_rounded, size: 14, color: supportWarningColor.shade700),
          ),
        ],
      ],
    );
  }
}
