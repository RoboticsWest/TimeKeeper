import 'dart:async';

import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/network_config_provider.dart';
import 'package:time_keeper/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'graphql_client_provider.g.dart';

bool _isSubscription(Request request) => request.operation.getOperationType() == OperationType.subscription;

@Riverpod(keepAlive: true)
class TimeKeeperGraphQLClient extends _$TimeKeeperGraphQLClient {
  // WebSocketLink owns a SocketClient that only stops reconnecting when the
  // link is disposed; nothing else closes it. Every rebuild here (server
  // switch, TLS toggle, login/logout, reconnect()) creates a new link, so the
  // previous one would keep a socket alive against the OLD endpoint - printing
  // "connection lost / Disconnected from websocket." forever. Track and close
  // it explicitly, and never leave more than one web socket per client.
  WebSocketLink? _wsLink;

  void reconnect() {
    logger.i('Reconnecting GraphQL client on next access...');
    ref.invalidateSelf();
  }

  @override
  GraphQLClient build() {
    if (_wsLink != null) {
      unawaited(_wsLink!.dispose());
      _wsLink = null;
    }

    final baseUri = ref.watch(serverBaseUriProvider);
    final tls = ref.watch(tlsProvider);
    final token = ref.watch(tokenProvider);

    final httpScheme = baseUri.scheme;
    final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final baseHost = baseUri.hasPort ? '${baseUri.host}:${baseUri.port}' : baseUri.host;

    final httpLink = HttpLink(
      '$httpScheme://$baseHost/graphql',
      defaultHeaders: token != null && token.isNotEmpty ? <String, String>{'Authorization': 'Bearer $token'} : {},
    );

    final wsLink = WebSocketLink(
      '$wsScheme://$baseHost/graphql/ws',
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        initialPayload: token != null && token.isNotEmpty
            ? <String, String>{'Authorization': 'Bearer $token'}
            : <String, String>{},
        autoReconnect: true,
        // Without this graphql retries on a zero timer and spams the console
        // with a "connection lost" error on every failed attempt while the
        // server is unreachable.
        delayBetweenReconnectionAttempts: const Duration(seconds: 2),
        inactivityTimeout: const Duration(seconds: 30),
        // The package never observes the channel's `ready` future, so a failed
        // first connect (server still booting) leaves that error unhandled in
        // the zone - the big "RethrownDartError / WebSocketException: Failed to
        // connect WebSocket" trace in the web console whenever the socket opens
        // before the server is accepting. Observing `ready` swallows it; the
        // reconnect loop above still drives the actual retry.
        connectFn: (uri, protocols) {
          final channel = WebSocketChannel.connect(uri, protocols: protocols);
          unawaited(channel.ready.then((_) {}, onError: (_) {}));
          return channel;
        },
      ),
    );
    _wsLink = wsLink;

    final link = Link.split(_isSubscription, wsLink, httpLink);

    logger.i('GraphQL client created: $httpScheme://$baseHost (TLS: $tls)');

    return GraphQLClient(link: link, cache: GraphQLCache());
  }
}
