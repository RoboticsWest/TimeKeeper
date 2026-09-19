import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/rfid_tag.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
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
  String? existingDiscordId,
  String? existingQuickPin,
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
      initialDiscordId: existingDiscordId,
      initialQuickPin: existingQuickPin,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteTeamMemberDialog(BuildContext context, WidgetRef ref, {required String id, required String name}) {
  ConfirmDialog.warn(
    title: 'Delete Team Member',
    message: Text('Are you sure you want to delete "$name"?'),
    confirmText: 'Delete',
    onConfirmAsyncApi: () => ref.read(teamMembersProvider.notifier).delete(id),
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
  final String? initialDiscordId;
  final String? initialQuickPin;

  const _TeamMemberForm({
    required this.isEdit,
    this.memberId,
    this.initialFirstName,
    this.initialLastName,
    this.initialMemberType,
    this.initialDisplayName,
    this.initialDiscordId,
    this.initialQuickPin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController(text: initialFirstName ?? '');
    final lastNameController = useTextEditingController(text: initialLastName ?? '');
    final displayNameController = useTextEditingController(text: initialDisplayName ?? '');
    final newRfidTagController = useTextEditingController();
    final discordIdController = useTextEditingController(text: initialDiscordId ?? '');
    final quickPinController = useTextEditingController(text: initialQuickPin ?? '');
    final memberType = useState<TeamMemberType>(initialMemberType ?? TeamMemberType.student);
    final isLoading = useState(false);

    // Existing RFID tags for this member (only shown in edit mode)
    final existingTags = isEdit ? ref.watch(rfidTagsByMemberProvider(memberId!)) : <String, RfidTag>{};

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
                  decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<TeamMemberType>(
            segments: const [
              ButtonSegment(value: TeamMemberType.student, label: Text('Student')),
              ButtonSegment(value: TeamMemberType.mentor, label: Text('Mentor')),
            ],
            selected: {memberType.value},
            onSelectionChanged: (selected) {
              memberType.value = selected.first;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: displayNameController,
            decoration: const InputDecoration(labelText: 'Display Name (optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('RFID Tags', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          // Show existing tags with delete buttons (edit mode only)
          if (isEdit && existingTags.isNotEmpty)
            ...existingTags.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.value.tag, style: Theme.of(context).textTheme.bodyMedium)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () async {
                        await ref.read(rfidTagsProvider.notifier).delete(entry.key);
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (isEdit && existingTags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'No RFID tags',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newRfidTagController,
                  decoration: const InputDecoration(labelText: 'Add RFID Tag', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              RfidScanButton(controller: newRfidTagController),
              if (isEdit) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () async {
                    final tag = newRfidTagController.text.trim();
                    if (tag.isEmpty) return;
                    final result = await ref.read(rfidTagsProvider.notifier).create(memberId!, tag);
                    if (result.success) {
                      newRfidTagController.clear();
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: discordIdController,
            decoration: const InputDecoration(
              labelText: 'Discord ID (optional)',
              helperText:
                  'Numeric user ID — enable Developer Mode in Discord, '
                  'then right-click the user and "Copy User ID"',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: quickPinController,
            decoration: const InputDecoration(
              labelText: 'Quick PIN (optional)',
              helperText:
                  'Typed at the kiosk to sign in without a card. '
                  'Up to $kMaxQuickPinLength characters, and must be unique across the team.',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            // Matches the server check and the DB constraint; stopping it at the keyboard is
            // friendlier than a round-trip rejection.
            maxLength: kMaxQuickPinLength,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
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
                        final newRfidTag = newRfidTagController.text.trim();
                        final discordId = discordIdController.text.trim();
                        final quickPin = quickPinController.text.trim();
                        final type = memberType.value;
                        final label = displayName.isNotEmpty ? displayName : '$firstName $lastName'.trim();

                        isLoading.value = true;
                        try {
                          final notifier = ref.read(teamMembersProvider.notifier);
                          final result = isEdit
                              ? await notifier.update(
                                  id: memberId!,
                                  firstName: firstName,
                                  lastName: lastName,
                                  memberType: type.toJson(),
                                  displayName: displayName.isNotEmpty ? displayName : null,
                                  discordId: discordId.isNotEmpty ? discordId : null,
                                  quickPin: quickPin.isNotEmpty ? quickPin : null,
                                )
                              : await notifier.create(
                                  firstName: firstName,
                                  lastName: lastName,
                                  memberType: type.toJson(),
                                  displayName: displayName.isNotEmpty ? displayName : null,
                                  discordId: discordId.isNotEmpty ? discordId : null,
                                  quickPin: quickPin.isNotEmpty ? quickPin : null,
                                );

                          // Create RFID tag for new member if provided
                          if (!isEdit && result.success && newRfidTag.isNotEmpty) {
                            // We need the member ID — get it from the latest state
                            // Since team members sync via subscription, we find the newly created member by name
                            final members = ref.read(teamMembersProvider);
                            final newEntry = members.entries.where(
                              (e) => e.value.firstName == firstName && e.value.lastName == lastName,
                            );
                            if (newEntry.isNotEmpty) {
                              await ref.read(rfidTagsProvider.notifier).create(newEntry.first.key, newRfidTag);
                            }
                          }

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (result.success) {
                              SnackBarDialog.success(
                                message: isEdit ? '"$label" updated successfully' : '"$label" created successfully',
                              ).show(context);
                            } else {
                              SnackBarDialog.fromApiResult(result: result).show(context);
                            }
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
