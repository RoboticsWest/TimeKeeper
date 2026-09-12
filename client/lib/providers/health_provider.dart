import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/network_config_provider.dart';

part 'health_provider.g.dart';

/// Polls the plain `/health` HTTP endpoint (not part of the GraphQL API) to report connectivity.
@Riverpod(keepAlive: true)
Stream<bool> isConnected(Ref ref) async* {
  final baseUri = ref.watch(serverBaseUriProvider);
  final scheme = baseUri.scheme;
  final host = baseUri.hasPort ? '${baseUri.host}:${baseUri.port}' : baseUri.host;
  final uri = Uri.parse('$scheme://$host/health');

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
