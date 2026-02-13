import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/team_member.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pbenum.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/rfid_scan_button.dart';

void showTeamMemberDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingFirstName,
  String? existingLastName,
  TeamMemberType? existingMemberType,
  String? existingDisplayName,
  String? existingRfidTag,
  String? existingDiscordUsername,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit Team Member' : 'Add Team Member',
    message: _TeamMemberForm(
      isEdit: isEdit,
      memberId: id,
      initialFirstName: existingFirstName,
      initialLastName: existingLastName,
      initialMemberType: existingMemberType,
      initialDisplayName: existingDisplayName,
      initialRfidTag: existingRfidTag,
      initialDiscordUsername: existingDiscordUsername,
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

class _TeamMemberForm extends HookConsumerWidget {
  final bool isEdit;
  final String? memberId;
  final String? initialFirstName;
  final String? initialLastName;
  final TeamMemberType? initialMemberType;
  final String? initialDisplayName;
  final String? initialRfidTag;
  final String? initialDiscordUsername;

  const _TeamMemberForm({
    required this.isEdit,
    this.memberId,
    this.initialFirstName,
    this.initialLastName,
    this.initialMemberType,
    this.initialDisplayName,
    this.initialRfidTag,
    this.initialDiscordUsername,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController(
      text: initialFirstName ?? '',
    );
    final lastNameController = useTextEditingController(
      text: initialLastName ?? '',
    );
    final displayNameController = useTextEditingController(
      text: initialDisplayName ?? '',
    );
    final rfidTagController = useTextEditingController(
      text: initialRfidTag ?? '',
    );
    final discordUsernameController = useTextEditingController(
      text: initialDiscordUsername ?? '',
    );
    final memberType = useState<TeamMemberType>(
      initialMemberType ?? TeamMemberType.STUDENT,
    );
    final isLoading = useState(false);

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
            controller: displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: rfidTagController,
                  decoration: const InputDecoration(
                    labelText: 'RFID Tag (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              RfidScanButton(controller: rfidTagController),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: discordUsernameController,
            decoration: const InputDecoration(
              labelText: 'Discord Username (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        final firstName = firstNameController.text.trim();
                        final lastName = lastNameController.text.trim();
                        final displayName = displayNameController.text.trim();
                        final rfidTag = rfidTagController.text.trim();
                        final discordUsername = discordUsernameController.text
                            .trim();
                        final type = memberType.value;
                        final label = displayName.isNotEmpty
                            ? displayName
                            : '$firstName $lastName'.trim();

                        isLoading.value = true;
                        try {
                          final client = ref.read(teamMemberServiceProvider);
                          final GrpcResult<dynamic> result;
                          if (isEdit) {
                            result = await callGrpcEndpoint(
                              () => client.updateTeamMember(
                                UpdateTeamMemberRequest(
                                  id: memberId,
                                  firstName: firstName,
                                  lastName: lastName,
                                  memberType: type,
                                  displayName: displayName.isNotEmpty
                                      ? displayName
                                      : null,
                                  rfidTag: rfidTag.isNotEmpty ? rfidTag : null,
                                  discordUsername: discordUsername.isNotEmpty
                                      ? discordUsername
                                      : null,
                                ),
                              ),
                            );
                          } else {
                            result = await callGrpcEndpoint(
                              () => client.createTeamMember(
                                CreateTeamMemberRequest(
                                  firstName: firstName,
                                  lastName: lastName,
                                  memberType: type,
                                  displayName: displayName.isNotEmpty
                                      ? displayName
                                      : null,
                                  rfidTag: rfidTag.isNotEmpty ? rfidTag : null,
                                  discordUsername: discordUsername.isNotEmpty
                                      ? discordUsername
                                      : null,
                                ),
                              ),
                            );
                          }

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            switch (result) {
                              case GrpcSuccess():
                                SnackBarDialog.success(
                                  message: isEdit
                                      ? '"$label" updated successfully'
                                      : '"$label" created successfully',
                                ).show(context);
                              case GrpcFailure():
                                SnackBarDialog.fromGrpcStatus(
                                  result: result,
                                ).show(context);
                            }
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
