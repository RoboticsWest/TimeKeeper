import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/role.dart';
import 'package:time_keeper/models/user.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'user_provider.g.dart';

const _userFields = 'id username roles { id name description isSuper }';

const _rolesQuery = '''
  query Roles {
    roles { id name description isSuper }
  }
''';

const _usersQuery = '''
  query Users {
    users { $_userFields }
  }
''';

const _userChangesSubscription = '''
  subscription UserChanges {
    userChanges { operation id data { $_userFields } }
  }
''';

const _createUserMutation = '''
  mutation CreateUser(\$username: String!, \$password: String!, \$roleIds: [Int!]) {
    createUser(username: \$username, password: \$password, roleIds: \$roleIds) { $_userFields }
  }
''';

const _updateUserMutation = '''
  mutation UpdateUser(\$id: UUID!, \$username: String, \$password: String, \$roleIds: [Int!]) {
    updateUser(id: \$id, username: \$username, password: \$password, roleIds: \$roleIds) { $_userFields }
  }
''';

const _deleteUserMutation = r'''
  mutation DeleteUser($id: UUID!) {
    deleteUser(id: $id)
  }
''';

@riverpod
Stream<ChangeEvent<User>> userChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_userChangesSubscription)))
      .where((result) => result.data != null)
      .map((result) => ChangeEvent.fromJson(result.data!['userChanges'] as Map<String, dynamic>, User.fromJson));
}

@Riverpod(keepAlive: true)
class Users extends _$Users {
  @override
  Map<String, User> build() {
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_usersQuery), fetchPolicy: FetchPolicy.noCache));
    if (result.hasException || result.data == null) return;

    final items = (result.data!['users'] as List<dynamic>).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    state = {for (final item in items) item.id: item};
  }

  void applyChange(ChangeEvent<User> change) {
    state = applyChangeToMap(state, change);
  }

  /// Re-fetch the full user list. The subscription only applies *changes*, so
  /// if one is missed (e.g. edited while the connection was down) the table
  /// stays stale until a manual refresh.
  Future<void> refresh() => _fetchInitial();

  Future<ApiCallResult> create(String username, String password, {List<int>? roleIds}) =>
      _mutate(_createUserMutation, {'username': username, 'password': password, 'roleIds': roleIds});

  Future<ApiCallResult> update(String id, {String? username, String? password, List<int>? roleIds}) =>
      _mutate(_updateUserMutation, {'id': id, 'username': username, 'password': password, 'roleIds': roleIds});

  Future<ApiCallResult> delete(String id) => _mutate(_deleteUserMutation, {'id': id});

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

/// The assignable roles, fetched once - they only change with a migration.
@Riverpod(keepAlive: true)
Future<List<Role>> roles(Ref ref) async {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_rolesQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return const [];
  return (result.data!['roles'] as List<dynamic>).map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
}

@Riverpod(keepAlive: true)
void usersSync(Ref ref) {
  ref.listen(userChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(usersProvider.notifier).applyChange(change);
    });
  });
}
