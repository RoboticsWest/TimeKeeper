import 'package:flutter/material.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/widgets/tone_chip.dart';

class SessionStatusChip extends StatelessWidget {
  final SessionStatus status;

  const SessionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    final label = statusLabel(status);

    // Overtime is the only status that is an alert rather than a category, so
    // it is the only one that spends the hue on its label as well as its dot.
    return status == SessionStatus.overtime
        ? ToneChip.alert(color: color, label: label)
        : ToneChip(color: color, label: label);
  }
}
