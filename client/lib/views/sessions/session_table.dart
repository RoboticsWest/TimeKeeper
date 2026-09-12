import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_rsvp_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/sessions/session_detail_dialog.dart';
import 'package:time_keeper/views/sessions/session_dialog.dart';
import 'package:time_keeper/widgets/member_count.dart';
import 'package:time_keeper/widgets/status_chip.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/session_rsvp.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/colors.dart';

class SessionTable extends ConsumerWidget {
  final List<MapEntry<String, Session>> sessions;

  const SessionTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final sessionRsvps = ref.watch(sessionRsvpsProvider);
    final theme = Theme.of(context);

    return EditTable(
      alternatingRows: true,
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
          child: TableHeaderText('Members'),
        ),
        BaseTableCell(
          child: TableHeaderText('RSVPs'),
        ),
        BaseTableCell(
          child: TableHeaderText('Status'),
        ),
        BaseTableCell(
          child: TableHeaderText(''),
        ),
      ],
      headerDecoration: tableHeaderDecoration(context),
      editRows: sessions.map((entry) {
        final id = entry.key;
        final session = entry.value;
        final start = session.startTime;
        final end = session.endTime;
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
            BaseTableCell(
              child: _RsvpCount(sessionId: id, sessionRsvps: sessionRsvps),
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
                  sessionRsvps: sessionRsvps,
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

class _RsvpCount extends StatelessWidget {
  final String sessionId;
  final Map<String, SessionRsvp> sessionRsvps;

  const _RsvpCount({required this.sessionId, required this.sessionRsvps});

  @override
  Widget build(BuildContext context) {
    final rsvps = sessionRsvps.values
        .where((r) => r.sessionId == sessionId)
        .toList();
    final going = rsvps.where((r) => r.status == RsvpStatus.going).length;
    final notGoing = rsvps
        .where((r) => r.status == RsvpStatus.notGoing)
        .length;

    if (rsvps.isEmpty) {
      return Text(
        '\u2014',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$going',
          style: TextStyle(
            color: supportSuccessColor.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          ' / ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$notGoing',
          style: TextStyle(color: supportErrorColor.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
