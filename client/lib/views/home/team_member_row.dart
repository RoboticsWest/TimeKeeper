import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';

class TeamMemberRow extends StatelessWidget {
  final TeamMember teamMember;

  const TeamMemberRow({super.key, required this.teamMember});

  @override
  Widget build(BuildContext context) {
    final alias = teamMember.alias.isNotEmpty ? '(${teamMember.alias})' : '';
    return Row(
      children: [
        Expanded(child: Center(child: Text('${teamMember.firstName} $alias'))),
        Expanded(child: Center(child: Text('${teamMember.memberType}'))),
        Expanded(child: Center(child: Text('Workshop'))),
        Expanded(child: Center(child: Text('12pm'))),
      ],
    );
  }
}
