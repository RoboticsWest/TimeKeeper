import 'package:flutter/material.dart';
import 'package:time_keeper/models/session_status.dart';

class SessionStatusChip extends StatelessWidget {
  final SessionStatus status;

  const SessionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        statusLabel(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: statusColor(status),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
