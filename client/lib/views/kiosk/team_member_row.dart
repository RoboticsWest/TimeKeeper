import 'package:flutter/material.dart';
import 'package:time_keeper/generated/common/common.pb.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
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
    final dt = timeIn.toDateTime();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';
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
