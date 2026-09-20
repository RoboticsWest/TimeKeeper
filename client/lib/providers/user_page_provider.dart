import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/models/user.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';
import 'package:time_keeper/providers/user_provider.dart';

part 'user_page_provider.g.dart';

const _userFields = 'id username roles { id name description isSuper }';

const _userPageQuery =
    '''
  query UsersPage(\$filter: UserFilterInput, \$offset: Int, \$limit: Int) {
    usersPage(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_userFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// User list filters, mirrored onto `UserFilterInput` on the server.
class UserFilterState {
  /// Case-insensitive match on the username or on any of the user's role names.
  final String search;

  const UserFilterState({this.search = ''});

  bool get isEmpty => search.trim().isEmpty;

  Map<String, dynamic>? toServerFilter() {
    final filter = <String, dynamic>{if (search.trim().isNotEmpty) 'search': search.trim()};
    return filter.isEmpty ? null : filter;
  }
}

/// A paged, filtered slice of the admin users table, ordered by username.
///
/// The built-in `admin` account is excluded server-side, inside the same query that produces the
/// count, so the pager's total always matches what it can actually render.
@Riverpod(keepAlive: true)
class UserPage extends _$UserPage with PagedAsyncNotifier<User> {
  UserFilterState _filter = const UserFilterState();

  @override
  Future<PagedResult<User>> build() async {
    ref.watch(timeKeeperGraphQLClientProvider);
    ref.listen(userChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<User>> fetch(int offset, int pageSize) {
    return fetchPagedPage<User>(
      ref: ref,
      document: _userPageQuery,
      rootField: 'usersPage',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: User.fromJson,
    ).then(
      (result) => result ?? const PagedResult<User>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(UserFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
