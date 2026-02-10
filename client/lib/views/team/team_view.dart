import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/api.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/views/team/check_in_out_button.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/views/team/team_member_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';

class TeamView extends ConsumerWidget {
  const TeamView({super.key});

  bool _isCheckedIn(String memberId, Map<String, Session> sessions) {
    for (final session in sessions.values) {
      for (final ms in session.memberSessions) {
        if (ms.teamMemberId == memberId &&
            ms.hasCheckInTime() &&
            !ms.hasCheckOutTime()) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
    final sessions = ref.watch(sessionsProvider);
    final currentLocation = ref.watch(currentLocationProvider) ?? '';
    final theme = Theme.of(context);

    final sorted = teamMembers.entries.toList()
      ..sort((a, b) {
        final lastCmp = a.value.lastName.compareTo(b.value.lastName);
        if (lastCmp != 0) return lastCmp;
        return a.value.firstName.compareTo(b.value.firstName);
      });

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team Members', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: EditTable(
              alternatingRows: true,
              headers: [
                BaseTableCell(
                  child: Text(
                    'First Name',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BaseTableCell(
                  child: Text(
                    'Last Name',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BaseTableCell(
                  child: Text('Type', style: TextStyle(color: Colors.white)),
                ),
                BaseTableCell(
                  child: Text('Alias', style: TextStyle(color: Colors.white)),
                ),
                BaseTableCell(
                  child: Text(
                    'Secondary Alias',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BaseTableCell(
                  child: Text('Status', style: TextStyle(color: Colors.white)),
                ),
              ],
              headerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              editRows: sorted.map((entry) {
                final id = entry.key;
                final member = entry.value;
                final checkedIn = _isCheckedIn(id, sessions);

                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () => showTeamMemberDialog(
                    context,
                    ref,
                    id: id,
                    existingFirstName: member.firstName,
                    existingLastName: member.lastName,
                    existingMemberType: member.memberType,
                    existingAlias: member.alias.isNotEmpty
                        ? member.alias
                        : null,
                    existingSecondaryAlias: member.secondaryAlias.isNotEmpty
                        ? member.secondaryAlias
                        : null,
                  ),
                  onDelete: () => showDeleteTeamMemberDialog(
                    context,
                    ref,
                    id: id,
                    name: '${member.firstName} ${member.lastName}',
                  ),
                  cells: [
                    BaseTableCell(child: Text(member.firstName)),
                    BaseTableCell(child: Text(member.lastName)),
                    BaseTableCell(
                      child: MemberTypeChip(memberType: member.memberType),
                    ),
                    BaseTableCell(
                      child: Text(member.alias.isNotEmpty ? member.alias : '—'),
                    ),
                    BaseTableCell(
                      child: Text(
                        member.secondaryAlias.isNotEmpty
                            ? member.secondaryAlias
                            : '—',
                      ),
                    ),
                    BaseTableCell(
                      child: CheckInOutButton(
                        checkedIn: checkedIn,
                        onPressed: () async {
                          final req = CheckInOutRequest(
                            teamMemberId: id,
                            location: Location(location: currentLocation),
                          );
                          final result = await callGrpcEndpoint(
                            () => ref
                                .read(sessionServiceProvider)
                                .checkInOut(req),
                          );
                          if (context.mounted) {
                            SnackBarDialog.fromGrpcStatus(
                              result: result,
                            ).show(context);
                          }
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
              onAdd: () => showTeamMemberDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
