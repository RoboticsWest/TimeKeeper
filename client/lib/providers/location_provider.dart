import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'location_provider.g.dart';

const _locationsQuery = r'''
  query Locations {
    locations { id location }
  }
''';

const _locationChangesSubscription = r'''
  subscription LocationChanges {
    locationChanges { operation id data { id location } }
  }
''';

const _createLocationMutation = r'''
  mutation CreateLocation($location: String!) {
    createLocation(location: $location) { id location }
  }
''';

const _updateLocationMutation = r'''
  mutation UpdateLocation($id: UUID!, $location: String!) {
    updateLocation(id: $id, location: $location) { id location }
  }
''';

const _deleteLocationMutation = r'''
  mutation DeleteLocation($id: UUID!) {
    deleteLocation(id: $id)
  }
''';

@riverpod
Stream<ChangeEvent<Location>> locationChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_locationChangesSubscription)))
      .where((result) => result.data != null)
      .map(
        (result) => ChangeEvent.fromJson(result.data!['locationChanges'] as Map<String, dynamic>, Location.fromJson),
      );
}

@Riverpod(keepAlive: true)
class Locations extends _$Locations {
  @override
  Map<String, Location> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<Location>(
      ref: ref,
      document: _locationsQuery,
      rootField: 'locations',
      fromJson: Location.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<Location> change) {
    state = applyChangeToMap(state, change);
  }

  Future<ApiCallResult> create(String location) => _mutate(_createLocationMutation, {'location': location});

  Future<ApiCallResult> update(String id, String location) =>
      _mutate(_updateLocationMutation, {'id': id, 'location': location});

  Future<ApiCallResult> delete(String id) => _mutate(_deleteLocationMutation, {'id': id});

  Future<ApiCallResult> _mutate(String document, Map<String, dynamic> variables) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(document: gql(document), variables: variables, fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiCallResult(success: false, message: message);
    }
    return const ApiCallResult(success: true);
  }
}

/// Bridges [locationChangesProvider] to [locationsProvider]. Views watch this to activate the
/// live-update subscription.
@Riverpod(keepAlive: true)
void locationsSync(Ref ref) {
  ref.listen(
    locationChangesProvider,
    changeListener<Location>(
      apply: (change) => ref.read(locationsProvider.notifier).applyChange(change),
      refresh: () => ref.read(locationsProvider.notifier).refresh(),
    ),
  );
}

@Riverpod(keepAlive: true)
class CurrentLocation extends _$CurrentLocation {
  static const String _key = 'current_location_id';

  void setLocation(String? locationId) {
    if (locationId == null) {
      localStorage.remove(_key);
    } else {
      localStorage.setString(_key, locationId);
    }
    state = locationId;
  }

  @override
  String? build() {
    if (localStorage.containsKey(_key)) {
      return localStorage.getString(_key);
    }
    return null;
  }
}
