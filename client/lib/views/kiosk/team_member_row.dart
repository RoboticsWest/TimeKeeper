import 'package:flutter/material.dart';
import 'package:time_keeper/generated/common/common.pb.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';

class TeamMemberRow extends StatelessWidget {
  final TeamMember teamMember;
  final Location location;
  final Timestamp timeIn;

  const TeamMemberRow({
    super.key,
    required this.teamMember,
    required this.location,
    required this.timeIn,
  });

  @override
  Widget build(BuildContext context) {
    final alias = teamMember.alias.isNotEmpty ? '(${teamMember.alias})' : '';
    final timeStr = formatTime(timeIn.toDateTime());
    return Row(
      children: [
        Expanded(child: Center(child: Text('${teamMember.firstName} $alias'))),
        Expanded(child: Center(child: Text('${teamMember.memberType}'))),
        Expanded(child: Center(child: Text(location.location))),
        Expanded(child: Center(child: Text(timeStr))),
      ],
    );
  }
}
