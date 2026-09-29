import 'package:flutter/material.dart';
import 'package:time_keeper/models/session_status.dart';

/// "still in / seen" for a running session, or just "seen" for one that is over.
///
/// Takes the two counts rather than the rows they came from: they are counted in SQL now, so the
/// caller no longer holds a list of attendance records to hand over.
class MemberCount extends StatelessWidget {
  /// Distinct members the session has seen.
  final int total;

  /// Of those, how many have not checked out.
  final int checkedIn;

  final SessionStatus status;

  const MemberCount({super.key, required this.total, required this.checkedIn, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = status == SessionStatus.current || status == SessionStatus.overtime ? '$checkedIn / $total' : '$total';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
