import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/views/team/check_in_out_button.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/views/team/team_member_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/colors.dart';

class TeamView extends HookConsumerWidget {
  const TeamView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required List<String> ids,
  }) {
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No members to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: title,
      message: Text(
        'Are you sure you want to delete $description? '
        '(${ids.length} ${ids.length == 1 ? 'member' : 'members'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final notifier = ref.read(teamMembersProvider.notifier);
        for (final id in ids) {
          await notifier.delete(id);
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} members'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(teamMembersSyncProvider);
    ref.watch(teamMemberSessionsSyncProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final currentLocation = ref.watch(currentLocationProvider) ?? '';
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    final sorted = teamMembers.entries.toList()
      ..sort((a, b) {
        final lastCmp = a.value.lastName.compareTo(b.value.lastName);
        if (lastCmp != 0) return lastCmp;
        return a.value.firstName.compareTo(b.value.firstName);
      });

    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      final m = entry.value;
      final type = m.memberType == TeamMemberType.student
          ? 'student'
          : 'mentor';
      return m.firstName.toLowerCase().contains(filterText) ||
          m.lastName.toLowerCase().contains(filterText) ||
          (m.displayName ?? '').toLowerCase().contains(filterText) ||
          (m.discordId ?? '').toLowerCase().contains(filterText) ||
          (m.quickPin ?? '').contains(filterText) ||
          type.contains(filterText);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Team Members', style: theme.textTheme.headlineMedium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ClearButton(
                    label: 'Clear Students',
                    icon: Icons.school,
                    color: supportWarningColor.shade700,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear Students',
                      description: 'all students',
                      ids: teamMembers.entries
                          .where(
                            (e) =>
                                e.value.memberType == TeamMemberType.student,
                          )
                          .map((e) => e.key)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ClearButton(
                    label: 'Clear Mentors',
                    icon: Icons.person,
                    color: supportWarningColor.shade700,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear Mentors',
                      description: 'all mentors',
                      ids: teamMembers.entries
                          .where(
                            (e) => e.value.memberType == TeamMemberType.mentor,
                          )
                          .map((e) => e.key)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ClearButton(
                    label: 'Clear All',
                    icon: Icons.delete_sweep,
                    color: theme.colorScheme.error,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear All Members',
                      description: 'all team members',
                      ids: teamMembers.keys.toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableFilter(controller: filterController),
          const SizedBox(height: 12),
          Expanded(
            child: EditTable(
              alternatingRows: true,
              headers: [
                BaseTableCell(
                  child: TableHeaderText('First Name'),
                ),
                BaseTableCell(
                  child: TableHeaderText('Last Name'),
                ),
                BaseTableCell(
                  child: TableHeaderText('Type'),
                ),
                BaseTableCell(
                  child: TableHeaderText('Display Name'),
                ),
                BaseTableCell(
                  child: TableHeaderText('RFID Tags'),
                ),
                BaseTableCell(
                  child: TableHeaderText('Discord'),
                ),
                BaseTableCell(
                  child: TableHeaderText('PIN'),
                ),
                BaseTableCell(
                  child: TableHeaderText('Status'),
                ),
              ],
              headerDecoration: tableHeaderDecoration(context),
              editRows: filtered.map((entry) {
                final id = entry.key;
                final member = entry.value;
                final checkedIn = isMemberCheckedIn(
                  id,
                  teamMemberSessions.values,
                );
                final memberTags = ref.watch(rfidTagsByMemberProvider(id));
                final tagDisplay = memberTags.isEmpty
                    ? '—'
                    : memberTags.values.map((t) => t.tag).join(', ');

                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () => showTeamMemberDialog(
                    context,
                    ref,
                    id: id,
                    existingFirstName: member.firstName,
                    existingLastName: member.lastName,
                    existingMemberType: member.memberType,
                    existingDisplayName: member.displayName,
                    existingDiscordId: member.discordId,
                    existingQuickPin: member.quickPin,
                  ),
                  onDelete: () => showDeleteTeamMemberDialog(
                    context,
                    ref,
                    id: id,
                    name: member.displayName ?? '${member.firstName} ${member.lastName}',
                  ),
                  cells: [
                    BaseTableCell(child: Text(member.firstName)),
                    BaseTableCell(child: Text(member.lastName)),
                    BaseTableCell(
                      child: MemberTypeChip(memberType: member.memberType),
                    ),
                    BaseTableCell(
                      child: Text(member.displayName ?? '—'),
                    ),
                    BaseTableCell(child: Text(tagDisplay)),
                    BaseTableCell(
                      child: Text(member.discordId ?? '—'),
                    ),
                    BaseTableCell(
                      child: Text(member.quickPin ?? '—'),
                    ),
                    BaseTableCell(
                      child: CheckInOutButton(
                        checkedIn: checkedIn,
                        onPressed: () async {
                          final result = await ref
                              .read(sessionCheckInOutProvider.notifier)
                              .checkInOut(id, currentLocation);
                          if (context.mounted) {
                            switch (result) {
                              case ApiSuccess():
                                SnackBarDialog.success(message: 'Success').show(context);
                              case ApiFailure(userMessage: final msg):
                                SnackBarDialog.error(message: msg).show(context);
                            }
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

class _ClearButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ClearButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}
