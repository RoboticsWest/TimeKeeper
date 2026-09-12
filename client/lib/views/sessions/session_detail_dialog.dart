import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/session_rsvp.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/colors.dart';

void showSessionDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required Session session,
  required Map<String, Location> locations,
  required Map<String, TeamMember> teamMembers,
  required Map<String, TeamMemberSession> teamMemberSessions,
  required Map<String, SessionRsvp> sessionRsvps,
}) {
  final start = session.startTime;
  final end = session.endTime;
  final duration = end.difference(start);
  final locationName =
      locations[session.locationId]?.location ?? session.locationId;
  final status = getSessionStatus(session);

  final memberSessions =
      teamMemberSessions.values
          .where((ms) => ms.sessionId == sessionId)
          .toList()
        ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));

  final checkedOutCount = memberSessions
      .where((ms) => ms.checkOutTime != null)
      .length;

  PopupDialog.info(
    title: 'Session Details',
    message: SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Date', value: formatDate(start)),
          _InfoRow(
            label: 'Time',
            value: '${formatTime(start)} - ${formatTime(end)}',
          ),
          _InfoRow(label: 'Duration', value: formatDuration(duration)),
          _InfoRow(label: 'Location', value: locationName),
          _InfoRow(label: 'Status', value: statusLabel(status)),
          Builder(
            builder: (context) {
              final rsvps = sessionRsvps.values
                  .where((r) => r.sessionId == sessionId)
                  .toList();
              final going = rsvps
                  .where((r) => r.status == RsvpStatus.going)
                  .length;
              final notGoing = rsvps
                  .where((r) => r.status == RsvpStatus.notGoing)
                  .length;
              if (rsvps.isEmpty) return const SizedBox.shrink();
              return _InfoRow(
                label: 'RSVPs',
                value: 'Going: $going, Not Going: $notGoing',
              );
            },
          ),
          const Divider(height: 24),

          Text(
            'Members (${memberSessions.length} total, $checkedOutCount completed)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (memberSessions.isEmpty)
            const Text('No members checked in')
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: memberSessions.map((ms) {
                    final member = teamMembers[ms.teamMemberId];
                    final name = member?.displayName ?? ms.teamMemberId;

                    final checkIn = formatTime(ms.checkInTime);
                    final checkOut = ms.checkOutTime != null
                        ? formatTime(ms.checkOutTime!)
                        : '\u2014';

                    Duration? memberDuration;
                    if (ms.checkOutTime != null) {
                      memberDuration = ms.checkOutTime!.difference(
                        ms.checkInTime,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            ms.checkOutTime != null
                                ? Icons.check_circle
                                : Icons.radio_button_checked,
                            size: 16,
                            color: ms.checkOutTime != null
                                ? neutralColor.shade400
                                : supportSuccessColor.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(name)),
                          Text(
                            '$checkIn - $checkOut',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          if (memberDuration != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              formatDuration(memberDuration),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    ),
  ).show(context);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
