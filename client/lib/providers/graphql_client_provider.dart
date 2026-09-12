import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/network_config_provider.dart';
import 'package:time_keeper/utils/logger.dart';

part 'graphql_client_provider.g.dart';

bool _isSubscription(Request request) => request.operation.getOperationType() == OperationType.subscription;

@Riverpod(keepAlive: true)
class TimeKeeperGraphQLClient extends _$TimeKeeperGraphQLClient {
  void reconnect() {
    logger.i('Reconnecting GraphQL client on next access...');
    ref.invalidateSelf();
  }

  @override
  GraphQLClient build() {
    final serverIp = ref.watch(serverIpProvider);
    final graphqlPort = ref.watch(serverGraphqlPortProvider);
    final tls = ref.watch(tlsProvider);
    final token = ref.watch(tokenProvider);

    final httpScheme = tls ? 'https' : 'http';
    final wsScheme = tls ? 'wss' : 'ws';

    final httpLink = HttpLink(
      '$httpScheme://$serverIp:$graphqlPort/graphql',
      defaultHeaders: token != null && token.isNotEmpty ? <String, String>{'Authorization': 'Bearer $token'} : {},
    );

    final wsLink = WebSocketLink(
      '$wsScheme://$serverIp:$graphqlPort/graphql/ws',
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        initialPayload: token != null && token.isNotEmpty
            ? <String, String>{'Authorization': 'Bearer $token'}
            : <String, String>{},
        autoReconnect: true,
        inactivityTimeout: const Duration(seconds: 30),
      ),
    );

    final link = Link.split(_isSubscription, wsLink, httpLink);

    logger.i('GraphQL client created: $serverIp:$graphqlPort (TLS: $tls)');

    return GraphQLClient(link: link, cache: GraphQLCache());
  }
}
