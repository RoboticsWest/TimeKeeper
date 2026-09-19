import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/user_provider.dart';
import 'package:time_keeper/views/users/role_chip.dart';
import 'package:time_keeper/views/users/user_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class UsersView extends HookConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersSyncProvider);
    final users = ref.watch(usersProvider);
    final theme = Theme.of(context);

    final filterController = useTextEditingController();
    final filterText = useValueListenable(filterController).text.toLowerCase();

    final refreshing = useState(false);
    Future<void> refreshUsers() async {
      refreshing.value = true;
      await ref.read(usersProvider.notifier).refresh();
      refreshing.value = false;
    }

    final sorted = users.entries.toList()..sort((a, b) => a.value.username.compareTo(b.value.username));

    final filtered = sorted.where((entry) {
      if (filterText.isEmpty) return true;
      final user = entry.value;
      final roleText = user.roles.map((r) => r.name.toLowerCase()).join(' ');
      return user.username.toLowerCase().contains(filterText) || roleText.contains(filterText);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            '(The default admin user is hidden from this list)',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TableFilter(controller: filterController)),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh users',
                onPressed: refreshing.value ? null : refreshUsers,
                icon: refreshing.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: EditTable(
              alternatingRows: true,
              headers: [
                const BaseTableCell(child: TableHeaderText('Username')),
                const BaseTableCell(flex: 2, child: TableHeaderText('Roles')),
              ],
              headerDecoration: tableHeaderDecoration(context),
              editRows: filtered.map((entry) {
                final id = entry.key;
                final user = entry.value;
                return EditTableRow(
                  key: ValueKey(id),
                  onEdit: () =>
                      showUserDialog(context, ref, id: id, existingUsername: user.username, existingRoles: user.roles),
                  onDelete: () => showDeleteUserDialog(context, ref, id: id, username: user.username),
                  cells: [
                    BaseTableCell(child: Text(user.username)),
                    BaseTableCell(flex: 2, child: RoleChips(roles: user.roles)),
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
