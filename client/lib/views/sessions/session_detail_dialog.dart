import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

void showSessionDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required Session session,
  required Map<String, Location> locations,
  required Map<String, TeamMember> teamMembers,
}) {
  final start = session.startTime.toDateTime();
  final end = session.endTime.toDateTime();
  final duration = end.difference(start);
  final locationName =
      locations[session.locationId]?.location ?? session.locationId;
  final status = getSessionStatus(session);

  final memberSessions = session.memberSessions.toList()
    ..sort((a, b) {
      final aTime = a.hasCheckInTime()
          ? a.checkInTime.toDateTime()
          : DateTime(0);
      final bTime = b.hasCheckInTime()
          ? b.checkInTime.toDateTime()
          : DateTime(0);
      return aTime.compareTo(bTime);
    });

  final checkedOutCount = memberSessions
      .where((ms) => ms.hasCheckInTime() && ms.hasCheckOutTime())
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
                    final name = member != null
                        ? '${member.firstName} ${member.lastName}'
                        : ms.teamMemberId;

                    final checkIn = ms.hasCheckInTime()
                        ? formatTime(ms.checkInTime.toDateTime())
                        : '\u2014';
                    final checkOut = ms.hasCheckOutTime()
                        ? formatTime(ms.checkOutTime.toDateTime())
                        : '\u2014';

                    Duration? memberDuration;
                    if (ms.hasCheckInTime() && ms.hasCheckOutTime()) {
                      memberDuration = ms.checkOutTime.toDateTime().difference(
                        ms.checkInTime.toDateTime(),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            ms.hasCheckOutTime()
                                ? Icons.check_circle
                                : Icons.radio_button_checked,
                            size: 16,
                            color: ms.hasCheckOutTime()
                                ? Colors.grey
                                : Colors.green,
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
