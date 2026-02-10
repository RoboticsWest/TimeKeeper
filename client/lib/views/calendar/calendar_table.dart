import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/widgets/status_chip.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';

class CalendarTable extends ConsumerWidget {
  final List<MapEntry<String, Session>> sessions;

  const CalendarTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    return BaseTable(
      alternatingRows: true,
      headerDecoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      headers: [
        BaseTableCell(
          child: Text('Date', style: TextStyle(color: Colors.white)),
          flex: 2,
        ),
        BaseTableCell(
          child: Text('Time', style: TextStyle(color: Colors.white)),
          flex: 2,
        ),
        BaseTableCell(
          child: Text('Duration', style: TextStyle(color: Colors.white)),
        ),
        BaseTableCell(
          child: Text('Location', style: TextStyle(color: Colors.white)),
        ),
        BaseTableCell(
          child: Text('Status', style: TextStyle(color: Colors.white)),
        ),
      ],
      rows: sessions.map((entry) {
        final session = entry.value;
        final start = session.startTime.toDateTime();
        final end = session.endTime.toDateTime();
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
