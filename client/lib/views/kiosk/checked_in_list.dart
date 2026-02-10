import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/common/common.pb.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/views/kiosk/team_member_header.dart';
import 'package:time_keeper/views/kiosk/team_member_row.dart';
import 'package:time_keeper/widgets/animated/infinite_vertical_list.dart';

class CheckedInMember {
  final Location location;
  final Timestamp timeIn;
  final TeamMember teamMember;

  CheckedInMember({
    required this.location,
    required this.timeIn,
    required this.teamMember,
  });
}

class CheckedInList extends ConsumerWidget {
  final List<Session> sessions;
  const CheckedInList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
    final locations = ref.watch(locationsProvider);

    final List<CheckedInMember> checkedInList = [];

    for (final session in sessions) {
      final location = locations[session.locationId];
      if (location == null) continue;

      for (final memberSession in session.memberSessions) {
        if (!memberSession.hasCheckInTime() ||
            memberSession.hasCheckOutTime()) {
          continue;
        }

        final teamMember = teamMembers[memberSession.teamMemberId];
        if (teamMember == null) continue;

        checkedInList.add(
          CheckedInMember(
            location: location,
            timeIn: memberSession.checkInTime,
            teamMember: teamMember,
          ),
        );
      }
    }

    double childHeight = 40;

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 40),
      child: Column(
        children: [
          SizedBox(height: childHeight, child: TeamMemberHeader()),
          Expanded(
            child: AnimatedInfiniteVerticalList(
              childHeight: childHeight,
              children: () {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final evenColor = isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02);
                final oddColor = isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05);
                return List.generate(checkedInList.length, (i) {
                  final member = checkedInList[i];
                  return Container(
                    height: childHeight,
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? evenColor : oddColor,
                    ),
                    child: TeamMemberRow(
                      teamMember: member.teamMember,
                      location: member.location,
                      timeIn: member.timeIn,
                    ),
                  );
                });
              }(),
            ),
          ),
        ],
      ),
    );
  }
}
