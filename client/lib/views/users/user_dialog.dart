import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/role.dart';
import 'package:time_keeper/providers/user_provider.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

void showUserDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingUsername,
  List<Role> existingRoles = const [],
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit User' : 'Add User',
    message: _UserForm(
      isEdit: isEdit,
      userId: id,
      initialUsername: existingUsername,
      initialRoles: existingRoles,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteUserDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String username,
}) {
  ConfirmDialog.warn(
    title: 'Delete User',
    message: Text('Are you sure you want to delete "$username"?'),
    confirmText: 'Delete',
    onConfirmAsyncApi: () => ref.read(usersProvider.notifier).delete(id),
    showResultDialog: true,
    successMessage: Text('"$username" has been deleted'),
  ).show(context);
}

class _UserForm extends HookConsumerWidget {
  final bool isEdit;
  final String? userId;
  final String? initialUsername;
  final List<Role> initialRoles;

  const _UserForm({
    required this.isEdit,
    this.userId,
    this.initialUsername,
    this.initialRoles = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: initialUsername ?? '');
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final selectedRoleIds = useState<Set<int>>(initialRoles.map((r) => r.id).toSet());
    final rolesAsync = ref.watch(rolesProvider);

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: isEdit ? 'Password (leave blank to keep)' : 'Password',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Roles', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'What this account can do in TimeKeeper. This is not team membership - '
            'students and mentors live under Team and have no login. '
            'Without a role a user can sign in but do nothing else.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          rolesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const Text('Could not load roles'),
            data: (roles) => Column(
              mainAxisSize: MainAxisSize.min,
              children: roles.map((role) {
                return CheckboxListTile(
                  value: selectedRoleIds.value.contains(role.id),
                  onChanged: isLoading.value
                      ? null
                      : (checked) {
                          final next = Set<int>.from(selectedRoleIds.value);
                          if (checked ?? false) {
                            next.add(role.id);
                          } else {
                            next.remove(role.id);
                          }
                          selectedRoleIds.value = next;
                        },
                  title: Text(role.label),
                  subtitle: role.description == null ? null : Text(role.description!),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
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
                        final username = usernameController.text.trim();
                        final password = passwordController.text;

                        if (username.isEmpty) return;
                        if (!isEdit && password.isEmpty) return;

                        isLoading.value = true;
                        try {
                          final notifier = ref.read(usersProvider.notifier);
                          final result = isEdit
                              ? await notifier.update(
                                  userId!,
                                  username: username,
                                  password: password.isNotEmpty ? password : null,
                                  roleIds: selectedRoleIds.value.toList(),
                                )
                              : await notifier.create(
                                  username,
                                  password,
                                  roleIds: selectedRoleIds.value.toList(),
                                );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (result.success) {
                              SnackBarDialog.success(
                                message: isEdit
                                    ? '"$username" updated successfully'
                                    : '"$username" created successfully',
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
