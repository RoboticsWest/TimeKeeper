import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/user_provider.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

void showUserDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingUsername,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit User' : 'Add User',
    message: _UserForm(isEdit: isEdit, userId: id, initialUsername: existingUsername),
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

  const _UserForm({required this.isEdit, this.userId, this.initialUsername});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: initialUsername ?? '');
    final passwordController = useTextEditingController();
    final isLoading = useState(false);

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
                                )
                              : await notifier.create(username, password);

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
