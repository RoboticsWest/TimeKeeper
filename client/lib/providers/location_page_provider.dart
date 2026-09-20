import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';

part 'location_page_provider.g.dart';

const _locationFields = 'id location';

const _locationPageQuery =
    '''
  query LocationsPage(\$filter: LocationFilterInput, \$offset: Int, \$limit: Int) {
    locationsPage(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_locationFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// Location list filters, mirrored onto `LocationFilterInput` on the server.
class LocationFilterState {
  /// Case-insensitive match on the location name.
  final String search;

  const LocationFilterState({this.search = ''});

  bool get isEmpty => search.trim().isEmpty;

  Map<String, dynamic>? toServerFilter() {
    final filter = <String, dynamic>{if (search.trim().isNotEmpty) 'search': search.trim()};
    return filter.isEmpty ? null : filter;
  }
}

/// A paged, filtered slice of the locations table, ordered by name.
///
/// Locations arrive in bulk from CSV imports, so the management view pages them rather than
/// pulling the table and filtering in Dart. The kiosk and calendar still use the unpaged
/// `locations` query — they need the whole set to resolve a session's location name.
@Riverpod(keepAlive: true)
class LocationPage extends _$LocationPage with PagedAsyncNotifier<Location> {
  LocationFilterState _filter = const LocationFilterState();

  @override
  Future<PagedResult<Location>> build() async {
    ref.watch(timeKeeperGraphQLClientProvider);
    ref.listen(locationChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<Location>> fetch(int offset, int pageSize) {
    return fetchPagedPage<Location>(
      ref: ref,
      document: _locationPageQuery,
      rootField: 'locationsPage',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: Location.fromJson,
    ).then(
      (result) => result ?? const PagedResult<Location>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(LocationFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
