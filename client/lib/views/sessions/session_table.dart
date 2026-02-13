import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/sessions/session_detail_dialog.dart';
import 'package:time_keeper/views/sessions/session_dialog.dart';
import 'package:time_keeper/widgets/member_count.dart';
import 'package:time_keeper/widgets/status_chip.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';

class SessionTable extends ConsumerWidget {
  final List<MapEntry<String, Session>> sessions;

  const SessionTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final theme = Theme.of(context);

    return EditTable(
      alternatingRows: true,
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
          child: Text('Members', style: TextStyle(color: Colors.white)),
        ),
        BaseTableCell(
          child: Text('Status', style: TextStyle(color: Colors.white)),
        ),
        BaseTableCell(
          child: Text('', style: TextStyle(color: Colors.white)),
        ),
      ],
      headerDecoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      editRows: sessions.map((entry) {
        final id = entry.key;
        final session = entry.value;
        final start = session.startTime.toDateTime();
        final end = session.endTime.toDateTime();
        final duration = end.difference(start);
        final locationName =
            locations[session.locationId]?.location ?? session.locationId;
        final sessionMemberSessions = teamMemberSessions.values
            .where((ms) => ms.sessionId == id)
            .toList();
        final memberCount = sessionMemberSessions.length;
        final status = getSessionStatus(session);

        return EditTableRow(
          key: ValueKey(id),
          onEdit: () =>
              showSessionDialog(context, ref, id: id, existingSession: session),
          onDelete: () =>
              showDeleteSessionDialog(context, ref, id: id, session: session),
          cells: [
            BaseTableCell(child: Text(formatDate(start)), flex: 2),
            BaseTableCell(
              child: Text('${formatTime(start)} - ${formatTime(end)}'),
              flex: 2,
            ),
            BaseTableCell(child: Text(formatDuration(duration))),
            BaseTableCell(child: Text(locationName)),
            BaseTableCell(
              child: MemberCount(
                total: memberCount,
                status: status,
                sessionMemberSessions: sessionMemberSessions,
              ),
            ),
            BaseTableCell(child: SessionStatusChip(status: status)),
            BaseTableCell(
              child: IconButton(
                icon: Icon(
                  Icons.visibility,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'View details',
                onPressed: () => showSessionDetailDialog(
                  context,
                  ref,
                  sessionId: id,
                  session: session,
                  locations: locations,
                  teamMembers: teamMembers,
                  teamMemberSessions: teamMemberSessions,
                ),
              ),
            ),
          ],
        );
      }).toList(),
      onAdd: () => showSessionDialog(context, ref),
    );
  }
}
