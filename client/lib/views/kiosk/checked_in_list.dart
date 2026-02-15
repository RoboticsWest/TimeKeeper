import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/common/common.pb.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
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
  const CheckedInList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
    final locations = ref.watch(locationsProvider);
    final sessions = ref.watch(sessionsProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);

    final List<CheckedInMember> checkedInList = [];

    for (final ms in teamMemberSessions.values) {
      if (!ms.hasCheckInTime() || ms.hasCheckOutTime()) {
        continue;
      }

      final teamMember = teamMembers[ms.teamMemberId];
      if (teamMember == null) continue;

      final session = sessions[ms.sessionId];
      final location = session != null ? locations[session.locationId] : null;
      if (location == null) continue;

      checkedInList.add(
        CheckedInMember(
          location: location,
          timeIn: ms.checkInTime,
          teamMember: teamMember,
        ),
      );
    }

    checkedInList.sort(
      (a, b) => a.teamMember.displayName.toLowerCase().compareTo(
        b.teamMember.displayName.toLowerCase(),
      ),
    );

    double childHeight = 40;

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 40),
      child: Column(
        children: [
          const TeamMemberHeader(),
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
