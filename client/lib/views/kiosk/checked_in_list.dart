import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/open_attendance_provider.dart';
import 'package:time_keeper/views/kiosk/team_member_header.dart';
import 'package:time_keeper/views/kiosk/team_member_row.dart';
import 'package:time_keeper/widgets/animated/infinite_vertical_list.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/team_member.dart';

class CheckedInMember {
  final Location location;
  final DateTime timeIn;
  final TeamMember teamMember;

  CheckedInMember({required this.location, required this.timeIn, required this.teamMember});
}

class CheckedInList extends ConsumerWidget {
  const CheckedInList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The open visits, and nothing else: each row carries the member and the location it prints, so
    // this board holds no copy of the roster, the sessions or the locations to look ids up in.
    final openVisits = ref.watch(openAttendanceProvider);

    final List<CheckedInMember> checkedInList = [];

    for (final ms in openVisits.values) {
      final teamMember = ms.teamMember;
      final location = ms.session?.location;
      if (teamMember == null || location == null) continue;

      checkedInList.add(CheckedInMember(location: location, timeIn: ms.checkInTime, teamMember: teamMember));
    }

    // Most recent arrival first: on a board people watch, the line that just changed should be
    // the one at the top. Name breaks ties so two simultaneous scans have a stable order.
    checkedInList.sort((a, b) {
      final byTime = b.timeIn.compareTo(a.timeIn);
      return byTime != 0 ? byTime : TeamMember.compareByName(a.teamMember, b.teamMember);
    });

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
                final evenColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02);
                final oddColor = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05);
                return List.generate(checkedInList.length, (i) {
                  final member = checkedInList[i];
                  return Container(
                    height: childHeight,
                    decoration: BoxDecoration(color: i % 2 == 0 ? evenColor : oddColor),
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
