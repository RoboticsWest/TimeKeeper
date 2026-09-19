import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/statistics/stats_models.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/widgets/tables/data_grid.dart';

/// Per-member breakdown for the bucket drilled into from the activity chart.
class DayInspector extends StatelessWidget {
  final List<DayMemberRow> rows;

  const DayInspector({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return DataGrid<DayMemberRow>(
      rows: rows,
      initialSortColumn: 4,
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
          label: 'In',
          flex: 2,
          cell: (row) => Text(formatTime(row.firstCheckIn)),
          compare: (a, b) => a.firstCheckIn.compareTo(b.firstCheckIn),
        ),
        GridColumn(
          label: 'Out',
          flex: 2,
          // Still checked in reads as "—" rather than a fabricated time.
          cell: (row) => Text(row.lastCheckOut == null ? '—' : formatTime(row.lastCheckOut!)),
        ),
        GridColumn(
          label: 'Total',
          flex: 2,
          alignment: Alignment.centerRight,
          cell: (row) => Text(formatDuration(row.total), style: const TextStyle(fontWeight: FontWeight.w600)),
          compare: (a, b) => a.total.compareTo(b.total),
        ),
        GridColumn(
          label: 'Overtime',
          flex: 2,
          alignment: Alignment.centerRight,
          cell: (row) => Text(row.overtime > Duration.zero ? formatDuration(row.overtime) : '—'),
          compare: (a, b) => a.overtime.compareTo(b.overtime),
        ),
      ],
      emptyMessage: 'Nobody checked in',
    );
  }
}
