import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/user.pbgrpc.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

void showUserDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingUsername,
  List<Role>? existingRoles,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit User' : 'Add User',
    message: _UserForm(
      ref: ref,
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
    onConfirmAsyncGrpc: () async {
      final client = ref.read(userServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteUser(DeleteUserRequest(id: id)),
      );
    },
    showResultDialog: true,
    successMessage: Text('"$username" has been deleted'),
  ).show(context);
}

class _UserForm extends HookWidget {
  final WidgetRef ref;
  final bool isEdit;
  final String? userId;
  final String? initialUsername;
  final List<Role>? initialRoles;

  const _UserForm({
    required this.ref,
    required this.isEdit,
    this.userId,
    this.initialUsername,
    this.initialRoles,
  });

  @override
  Widget build(BuildContext context) {
    final usernameController = useTextEditingController(
      text: initialUsername ?? '',
    );
    final passwordController = useTextEditingController();
    final selectedRoles = useState<Set<Role>>((initialRoles ?? []).toSet());

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
          const SizedBox(height: 16),
          Text('Roles', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Role.values.map((role) {
              final isSelected = selectedRoles.value.contains(role);
              return FilterChip(
                label: Text(role.name),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<Role>.from(selectedRoles.value);
                  if (selected) {
                    updated.add(role);
                  } else {
                    updated.remove(role);
                  }
                  selectedRoles.value = updated;
                },
              );
            }).toList(),
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
                  final username = usernameController.text.trim();
                  final password = passwordController.text;
                  final roles = selectedRoles.value.toList();

                  if (username.isEmpty) return;
                  if (!isEdit && password.isEmpty) return;

                  Navigator.of(context).pop();

                  ConfirmDialog.info(
                    title: isEdit ? 'Update User' : 'Create User',
                    message: isEdit
                        ? Text('Save changes to "$username"?')
                        : Text('Create user "$username"?'),
                    confirmText: isEdit ? 'Save' : 'Create',
                    onConfirmAsyncGrpc: () async {
                      final client = ref.read(userServiceProvider);
                      if (isEdit) {
                        return await callGrpcEndpoint(
                          () => client.updateUser(
                            UpdateUserRequest(
                              id: userId,
                              username: username,
                              password: password,
                              roles: roles,
                            ),
                          ),
                        );
                      } else {
                        return await callGrpcEndpoint(
                          () => client.createUser(
                            CreateUserRequest(
                              username: username,
                              password: password,
                              roles: roles,
                            ),
                          ),
                        );
                      }
                    },
                    showResultDialog: true,
                    successMessage: Text(
                      isEdit
                          ? '"$username" updated successfully'
                          : '"$username" created successfully',
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
