import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/status_chip.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class CalendarTable extends ConsumerWidget {
  final List<MapEntry<String, Session>> sessions;

  const CalendarTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);

    return BaseTable(
      alternatingRows: true,
      headerDecoration: tableHeaderDecoration(context),
      headers: [
        BaseTableCell(
          child: TableHeaderText('Date'),
          flex: 2,
        ),
        BaseTableCell(
          child: TableHeaderText('Time'),
          flex: 2,
        ),
        BaseTableCell(
          child: TableHeaderText('Duration'),
        ),
        BaseTableCell(
          child: TableHeaderText('Location'),
        ),
        BaseTableCell(
          child: TableHeaderText('Status'),
        ),
      ],
      rows: sessions.map((entry) {
        final session = entry.value;
        final start = session.startTime;
        final end = session.endTime;
        final duration = end.difference(start);
        final locationName =
            locations[session.locationId]?.location ?? session.locationId;
        final status = getSessionStatus(session);

        return BaseTableRow(
          cells: [
            BaseTableCell(child: Text(formatDate(start)), flex: 2),
            BaseTableCell(
              child: Text('${formatTime(start)} - ${formatTime(end)}'),
              flex: 2,
            ),
            BaseTableCell(child: Text(formatDuration(duration))),
            BaseTableCell(child: Text(locationName)),
            BaseTableCell(child: SessionStatusChip(status: status)),
          ],
        );
      }).toList(),
    );
  }
}
