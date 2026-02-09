import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/views/home/team_member_header.dart';
import 'package:time_keeper/views/home/team_member_row.dart';
import 'package:time_keeper/widgets/animated/infinite_vertical_list.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
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
                int index = 0;
                return teamMembers.entries.map((entry) {
                  final i = index++;
                  Color? rowColor = i % 2 == 0
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surfaceContainerHighest;
                  return Container(
                    height: childHeight,
                    decoration: BoxDecoration(color: rowColor),
                    child: TeamMemberRow(teamMember: entry.value),
                  );
                }).toList();
              }(),
            ),
          ),
        ],
      ),
    );
  }
}
