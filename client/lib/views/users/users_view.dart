import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/user_provider.dart';
import 'package:time_keeper/views/users/role_chip.dart';
import 'package:time_keeper/views/users/user_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class UsersView extends HookConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersSyncProvider);
    final users = ref.watch(usersProvider);
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    final sorted = users.entries.toList()
      ..sort((a, b) => a.value.username.compareTo(b.value.username));

    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      final user = entry.value;
      final roleStr = user.roles.map((r) => r.name.toLowerCase()).join(' ');
      return user.username.toLowerCase().contains(filterText) ||
          roleStr.contains(filterText);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          TableFilter(controller: filterController),
          const SizedBox(height: 12),
          Expanded(
            child: EditTable(
              alternatingRows: true,
              headers: [
                const BaseTableCell(
                  child: Text(
                    'Username',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const BaseTableCell(
                  child: Text('Roles', style: TextStyle(color: Colors.white)),
                  flex: 2,
                ),
              ],
              headerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              editRows: filtered.map((entry) {
                final id = entry.key;
                final user = entry.value;
                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () => showUserDialog(
                    context,
                    ref,
                    id: id,
                    existingUsername: user.username,
                    existingRoles: user.roles.toList(),
                  ),
                  onDelete: () => showDeleteUserDialog(
                    context,
                    ref,
                    id: id,
                    username: user.username,
                  ),
                  cells: [
                    BaseTableCell(child: Text(user.username)),
                    BaseTableCell(
                      child: Wrap(
                        spacing: 6,
                        children: user.roles
                            .map((role) => RoleChip(role: role))
                            .toList(),
                      ),
                      flex: 2,
                    ),
                  ],
                );
              }).toList(),
              onAdd: () => showUserDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
