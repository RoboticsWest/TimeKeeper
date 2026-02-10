import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/team_member.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pbenum.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

void showTeamMemberDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingFirstName,
  String? existingLastName,
  TeamMemberType? existingMemberType,
  String? existingAlias,
  String? existingSecondaryAlias,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit Team Member' : 'Add Team Member',
    message: _TeamMemberForm(
      ref: ref,
      isEdit: isEdit,
      memberId: id,
      initialFirstName: existingFirstName,
      initialLastName: existingLastName,
      initialMemberType: existingMemberType,
      initialAlias: existingAlias,
      initialSecondaryAlias: existingSecondaryAlias,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteTeamMemberDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String name,
}) {
  ConfirmDialog.warn(
    title: 'Delete Team Member',
    message: Text('Are you sure you want to delete "$name"?'),
    confirmText: 'Delete',
    onConfirmAsyncGrpc: () async {
      final client = ref.read(teamMemberServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteTeamMember(DeleteTeamMemberRequest(id: id)),
      );
    },
    showResultDialog: true,
    successMessage: Text('"$name" has been deleted'),
  ).show(context);
}

class _TeamMemberForm extends HookWidget {
  final WidgetRef ref;
  final bool isEdit;
  final String? memberId;
  final String? initialFirstName;
  final String? initialLastName;
  final TeamMemberType? initialMemberType;
  final String? initialAlias;
  final String? initialSecondaryAlias;

  const _TeamMemberForm({
    required this.ref,
    required this.isEdit,
    this.memberId,
    this.initialFirstName,
    this.initialLastName,
    this.initialMemberType,
    this.initialAlias,
    this.initialSecondaryAlias,
  });

  @override
  Widget build(BuildContext context) {
    final firstNameController = useTextEditingController(
      text: initialFirstName ?? '',
    );
    final lastNameController = useTextEditingController(
      text: initialLastName ?? '',
    );
    final aliasController = useTextEditingController(text: initialAlias ?? '');
    final secondaryAliasController = useTextEditingController(
      text: initialSecondaryAlias ?? '',
    );
    final memberType = useState<TeamMemberType>(
      initialMemberType ?? TeamMemberType.STUDENT,
    );

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<TeamMemberType>(
            segments: const [
              ButtonSegment(
                value: TeamMemberType.STUDENT,
                label: Text('Student'),
              ),
              ButtonSegment(
                value: TeamMemberType.MENTOR,
                label: Text('Mentor'),
              ),
            ],
            selected: {memberType.value},
            onSelectionChanged: (selected) {
              memberType.value = selected.first;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: aliasController,
            decoration: const InputDecoration(
              labelText: 'Alias (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: secondaryAliasController,
            decoration: const InputDecoration(
              labelText: 'Secondary Alias (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final firstName = firstNameController.text.trim();
                  final lastName = lastNameController.text.trim();

                  if (firstName.isEmpty || lastName.isEmpty) return;

                  final alias = aliasController.text.trim();
                  final secondaryAlias = secondaryAliasController.text.trim();
                  final type = memberType.value;
                  final displayName = '$firstName $lastName';

                  Navigator.of(context).pop();

                  ConfirmDialog.info(
                    title: isEdit ? 'Update Team Member' : 'Create Team Member',
                    message: isEdit
                        ? Text('Save changes to "$displayName"?')
                        : Text('Create team member "$displayName"?'),
                    confirmText: isEdit ? 'Save' : 'Create',
                    onConfirmAsyncGrpc: () async {
                      final client = ref.read(teamMemberServiceProvider);
                      if (isEdit) {
                        return await callGrpcEndpoint(
                          () => client.updateTeamMember(
                            UpdateTeamMemberRequest(
                              id: memberId,
                              firstName: firstName,
                              lastName: lastName,
                              memberType: type,
                              alias: alias.isNotEmpty ? alias : null,
                              secondaryAlias: secondaryAlias.isNotEmpty
                                  ? secondaryAlias
                                  : null,
                            ),
                          ),
                        );
                      } else {
                        return await callGrpcEndpoint(
                          () => client.createTeamMember(
                            CreateTeamMemberRequest(
                              firstName: firstName,
                              lastName: lastName,
                              memberType: type,
                              alias: alias.isNotEmpty ? alias : null,
                              secondaryAlias: secondaryAlias.isNotEmpty
                                  ? secondaryAlias
                                  : null,
                            ),
                          ),
                        );
                      }
                    },
                    showResultDialog: true,
                    successMessage: Text(
                      isEdit
                          ? '"$displayName" updated successfully'
                          : '"$displayName" created successfully',
                    ),
                  ).show(context);
                },
                child: Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
