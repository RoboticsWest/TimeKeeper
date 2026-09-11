import 'package:flutter/material.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/models/team_member_session.dart';

class MemberCount extends StatelessWidget {
  final int total;
  final SessionStatus status;
  final List<TeamMemberSession> sessionMemberSessions;

  const MemberCount({
    super.key,
    required this.total,
    required this.status,
    required this.sessionMemberSessions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = sessionMemberSessions
        .where((ms) => ms.checkOutTime == null)
        .length;
    final text =
        status == SessionStatus.current || status == SessionStatus.overtime
        ? '$activeCount / $total'
        : '$total';

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
