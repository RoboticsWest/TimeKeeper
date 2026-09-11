import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/jwt.dart';
import 'package:time_keeper/utils/logger.dart';
import 'package:time_keeper/utils/permissions.dart';

part 'auth_provider.g.dart';

const _loginMutation = r'''
  mutation Login($username: String!, $password: String!) {
    login(username: $username, password: $password) { token }
  }
''';

const _meQuery = r'''
  query Me {
    me { id username }
  }
''';

@Riverpod(keepAlive: true)
class Token extends _$Token {
  final _tokenKey = 'jwt_token';

  Future<void> set(String token) async {
    await localStorage.setString(_tokenKey, token);
    state = token;
  }

  void clear() async {
    await localStorage.remove(_tokenKey);
    state = null;
  }

  @override
  String? build() {
    final token = localStorage.getString(_tokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }
}

@Riverpod(keepAlive: true)
class Username extends _$Username {
  final _usernameKey = 'username';

  Future<void> set(String username) async {
    await localStorage.setString(_usernameKey, username);
    state = username;
  }

  Future<void> clear() async {
    await localStorage.remove(_usernameKey);
    state = null;
  }

  @override
  String? build() {
    final username = localStorage.getString(_usernameKey);
    return (username == null || username.isEmpty) ? null : username;
  }
}

/// Decoded straight from the current JWT's `permissions` claim - not independently stored, so it
/// always reflects whatever token is currently active.
@Riverpod(keepAlive: true)
List<String> permissions(Ref ref) {
  final token = ref.watch(tokenProvider);
  return decodeJwtPermissions(token);
}

@Riverpod(keepAlive: true)
class UserService extends _$UserService {
  Future<ApiResult<String>> login(String username, String password) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(_loginMutation),
        variables: {'username': username, 'password': password},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiFailure(userMessage: message);
    }

    final token = result.data!['login']['token'] as String;
    await ref.read(usernameProvider.notifier).set(username);
    await ref.read(tokenProvider.notifier).set(token);

    return ApiSuccess(token);
  }

  /// Queries `me` to check whether the current token is still valid. Returns `true` on a network
  /// error too (assume the token is still valid rather than logging the user out over a blip) -
  /// only an explicit `null` result (bad/missing token) counts as invalid.
  Future<bool> validateToken() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_meQuery), fetchPolicy: FetchPolicy.noCache));

    if (result.hasException) {
      logger.w('Failed to validate token (assuming still valid): ${result.exception}');
      return true;
    }

    final isValid = result.data?['me'] != null;
    logger.i(isValid ? 'Validated Auth Token' : 'Invalid Auth Token');
    return isValid;
  }

  void logout() {
    ref.read(usernameProvider.notifier).clear();
    ref.read(tokenProvider.notifier).clear();
  }

  Future<ApiCallResult> updateAdminPassword(String password) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateAdminPassword($password: String!) {
            updateAdminPassword(password: $password)
          }
        '''),
        variables: {'password': password},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiCallResult(success: false, message: message);
    }
    return const ApiCallResult(success: true);
  }

  @override
  void build() {}
}

@Riverpod(keepAlive: true)
bool isLoggedIn(Ref ref) {
  final token = ref.watch(tokenProvider);
  return token?.isNotEmpty ?? false;
}

/// UI-gating helper mirroring the server's `require_permission` checks - not a security boundary,
/// just controls what the client shows/hides. The server independently enforces every request.
@Riverpod(keepAlive: true)
bool isAdmin(Ref ref) {
  final perms = ref.watch(permissionsProvider);
  return hasPermission(perms, 'settings', PermissionLevel.write);
}

/// Whether the current token grants any permission at all (vs. being unauthenticated) - used to
/// gate the main navigation rail and RFID scanning.
@Riverpod(keepAlive: true)
bool hasAnyPermission(Ref ref) {
  return ref.watch(permissionsProvider).isNotEmpty;
}
