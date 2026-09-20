import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/user_page_provider.dart';
import 'package:time_keeper/views/users/role_chip.dart';
import 'package:time_keeper/views/users/user_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

class UsersView extends HookConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Paged server-side. The search matches username or role name, both resolved in SQL, so it
    // covers the same ground the old in-memory filter did.
    final page = ref.watch(userPageProvider);
    final notifier = ref.read(userPageProvider.notifier);
    final currentPage = page.value;

    final filterController = useTextEditingController();
    final searchText = useState('');

    // Debounce the search term before it hits the server query.
    useEffect(() {
      final timer = Timer(const Duration(milliseconds: 350), () {
        searchText.value = filterController.text;
      });
      return timer.cancel;
    }, [filterController.text]);

    // Push the filter to the paged provider, restarting at page one.
    useEffect(() {
      notifier.setFilter(UserFilterState(search: searchText.value));
      return null;
    }, [searchText.value]);

    final refreshing = useState(false);
    Future<void> refreshUsers() async {
      refreshing.value = true;
      await notifier.refresh();
      refreshing.value = false;
    }

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
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : EditTable(
                    alternatingRows: true,
                    headers: [
                      const BaseTableCell(child: TableHeaderText('Username')),
                      const BaseTableCell(flex: 2, child: TableHeaderText('Roles')),
                    ],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((user) {
                      final id = user.id;
                      return EditTableRow(
                        key: ValueKey(id),
                        onEdit: () => showUserDialog(
                          context,
                          ref,
                          id: id,
                          existingUsername: user.username,
                          existingRoles: user.roles,
                        ),
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
          if (currentPage != null)
            PaginationBar(
              totalCount: currentPage.totalCount,
              offset: currentPage.offset,
              pageSize: notifier.currentPageSize,
              hasMore: currentPage.hasMore,
              onPageSizeChanged: notifier.setPageSize,
              onPrevious: notifier.previousPage,
              onNext: notifier.nextPage,
            ),
        ],
      ),
    );
  }
}

/// Replaces the table area while a fresh page is loading or has failed.
class _LoadingOrError<T> extends StatelessWidget {
  final AsyncValue<T> page;
  final Future<void> Function() onRetry;

  const _LoadingOrError({required this.page, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (page.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load users', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
