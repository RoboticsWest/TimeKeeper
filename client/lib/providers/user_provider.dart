import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/user.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'user_provider.g.dart';

const _userFields = 'id username';

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
  mutation CreateUser(\$username: String!, \$password: String!) {
    createUser(username: \$username, password: \$password) { $_userFields }
  }
''';

const _updateUserMutation = '''
  mutation UpdateUser(\$id: UUID!, \$username: String, \$password: String) {
    updateUser(id: \$id, username: \$username, password: \$password) { $_userFields }
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
  late final CollectionStorage<User> _storage;

  @override
  Map<String, User> build() {
    _storage = CollectionStorage(tableName: 'users', fromJson: User.fromJson, toJson: (u) => u.toJson());
    _fetchInitial();
    return _storage.getAll();
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_usersQuery), fetchPolicy: FetchPolicy.noCache));
    if (result.hasException || result.data == null) return;

    final items = (result.data!['users'] as List<dynamic>).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    state = _storage.seedFromList(items, (u) => u.id);
  }

  void applyChange(ChangeEvent<User> change) {
    state = _storage.applyChange(change, state);
  }

  Future<ApiCallResult> create(String username, String password) =>
      _mutate(_createUserMutation, {'username': username, 'password': password});

  Future<ApiCallResult> update(String id, {String? username, String? password}) =>
      _mutate(_updateUserMutation, {'id': id, 'username': username, 'password': password});

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

@riverpod
void usersSync(Ref ref) {
  ref.listen(userChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(usersProvider.notifier).applyChange(change);
    });
  });
}
