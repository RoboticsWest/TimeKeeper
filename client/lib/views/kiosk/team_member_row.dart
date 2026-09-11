import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/team_member.dart';

class TeamMemberRow extends StatelessWidget {
  final TeamMember teamMember;
  final Location location;
  final DateTime timeIn;

  const TeamMemberRow({
    super.key,
    required this.teamMember,
    required this.location,
    required this.timeIn,
  });

  @override
  Widget build(BuildContext context) {
    final name = teamMember.displayName ?? '${teamMember.firstName} ${teamMember.lastName}';
    final timeStr = formatTime(timeIn);
    return Row(
      children: [
        Expanded(child: Center(child: Text(name))),
        Expanded(child: Center(child: Text(teamMember.memberType.name))),
        Expanded(child: Center(child: Text(location.location))),
        Expanded(child: Center(child: Text(timeStr))),
      ],
    );
  }
}
