import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/network_config_provider.dart';

part 'health_provider.g.dart';

/// Polls the plain `/health` HTTP endpoint (not part of the GraphQL API) to report connectivity.
@Riverpod(keepAlive: true)
Stream<bool> isConnected(Ref ref) async* {
  final serverIp = ref.watch(serverIpProvider);
  final graphqlPort = ref.watch(serverGraphqlPortProvider);
  final tls = ref.watch(tlsProvider);
  final scheme = tls ? 'https' : 'http';
  final uri = Uri.parse('$scheme://$serverIp:$graphqlPort/health');

  while (true) {
    bool connected;
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      connected = response.statusCode == 200;
    } catch (_) {
      connected = false;
    }
    yield connected;
    await Future<void>.delayed(const Duration(seconds: 10));
  }
}
