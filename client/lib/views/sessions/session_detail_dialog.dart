import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/session_rsvp.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/providers/attendance_counts_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/colors.dart';

void showSessionDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required Session session,
  required Map<String, SessionRsvp> sessionRsvps,
}) {
  final start = session.startTime;
  final end = session.endTime;
  final duration = end.difference(start);
  final locationName = session.location?.location ?? session.locationId;
  final status = getSessionStatus(session);

  // This session's attendance is read for this session, not filtered out of a copy of the whole
  // table; `_Attendance` below watches it so the dialog fills in as it arrives.

  PopupDialog.info(
    title: 'Session Details',
    message: SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Date', value: formatDate(start)),
          _InfoRow(label: 'Time', value: '${formatTime(start)} - ${formatTime(end)}'),
          _InfoRow(label: 'Duration', value: formatDuration(duration)),
          _InfoRow(label: 'Location', value: locationName),
          _InfoRow(label: 'Status', value: statusLabel(status)),
          Builder(
            builder: (context) {
              final rsvps = sessionRsvps.values.where((r) => r.sessionId == sessionId).toList();
              final going = rsvps.where((r) => r.status == RsvpStatus.going).length;
              final notGoing = rsvps.where((r) => r.status == RsvpStatus.notGoing).length;
              if (rsvps.isEmpty) return const SizedBox.shrink();
              return _InfoRow(label: 'RSVPs', value: 'Going: $going, Not Going: $notGoing');
            },
          ),
          const Divider(height: 24),

          _Attendance(sessionId: sessionId),
        ],
      ),
    ),
  ).show(context);
}

/// This session's attendance, read for this session.
///
/// Its own widget because it is the one part of the dialog that waits on the server: the rest is
/// already in hand when the dialog opens, and should not be held back by a query.
class _Attendance extends ConsumerWidget {
  final String sessionId;

  const _Attendance({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(sessionAttendanceProvider(sessionId));

    return attendance.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (error, _) => const Text('Could not load this session\u2019s attendance'),
      data: (rows) {
        // Newest activity first, the same order the Attendance list uses: a checkout is the latest
        // thing to have happened to a visit, so it sorts by that when there is one.
        final memberSessions = [...rows]..sort((a, b) => lastActivityOf(b).compareTo(lastActivityOf(a)));
        final checkedOutCount = memberSessions.where((ms) => ms.checkOutTime != null).length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      // The query asked for the member, so the row already knows their name.
                      final name = ms.teamMember?.displayLabel ?? ms.teamMemberId;

                      final checkIn = formatTime(ms.checkInTime);
                      final checkOut = ms.checkOutTime != null ? formatTime(ms.checkOutTime!) : '\u2014';

                      Duration? memberDuration;
                      if (ms.checkOutTime != null) {
                        memberDuration = ms.checkOutTime!.difference(ms.checkInTime);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              ms.checkOutTime != null ? Icons.check_circle : Icons.radio_button_checked,
                              size: 16,
                              color: ms.checkOutTime != null ? neutralColor.shade400 : supportSuccessColor.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(name)),
                            Text(
                              '$checkIn - $checkOut',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
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
        );
      },
    );
  }
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
