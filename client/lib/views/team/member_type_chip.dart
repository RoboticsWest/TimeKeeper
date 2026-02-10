import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';

class MemberTypeChip extends StatelessWidget {
  final TeamMemberType memberType;

  const MemberTypeChip({super.key, required this.memberType});

  @override
  Widget build(BuildContext context) {
    final isStudent = memberType == TeamMemberType.STUDENT;
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(
        isStudent ? 'Student' : 'Mentor',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: isStudent ? colorScheme.primary : colorScheme.secondary,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
