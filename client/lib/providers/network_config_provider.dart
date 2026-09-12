import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/local_storage.dart';

part 'network_config_provider.g.dart';

@Riverpod(keepAlive: true)
class ServerIp extends _$ServerIp {
  static const String _key = 'server_address';
  static const String _defaultIp = '127.0.0.1';

  void setIp(String ip) {
    localStorage.setString(_key, ip);
    state = ip;
  }

  String getIp() {
    return state;
  }

  String _getStoredIp() {
    String ip = _defaultIp;
    if (localStorage.containsKey(_key)) {
      ip = localStorage.getString(_key) ?? _defaultIp;
    } else {
      if (kIsWasm || kIsWeb) {
        // use base
        ip = Uri.base.host;
      }
    }

    return ip;
  }

  @override
  String build() {
    return _getStoredIp();
  }
}

// GraphQL API Port
@Riverpod(keepAlive: true)
class ServerGraphqlPort extends _$ServerGraphqlPort {
  static const String _key = 'server_graphql_port';
  static const int _defaultPort = 4000;
  void setPort(int port) {
    localStorage.setInt(_key, port);
    state = port;
  }

  int getPort() {
    return state;
  }

  int _getStoredPort() {
    int port = _defaultPort;
    if (localStorage.containsKey(_key)) {
      port = localStorage.getInt(_key) ?? _defaultPort;
    }
    return port;
  }

  @override
  int build() {
    return _getStoredPort();
  }
}

// TLS
@Riverpod(keepAlive: true)
class Tls extends _$Tls {
  static const String _key = 'tls';
  static const bool _defaultTls = false;
  void setTls(bool tls) {
    localStorage.setBool(_key, tls);
    state = tls;
  }

  bool getTls() {
    return state;
  }

  bool _getStoredTls() {
    bool tls = _defaultTls;
    if (localStorage.containsKey(_key)) {
      tls = localStorage.getBool(_key) ?? _defaultTls;
    }
    return tls;
  }

  @override
  bool build() {
    return _getStoredTls();
  }
}

/// Base URI used for API connections (GraphQL over HTTP/WS plus the `/health`
/// probe).
///
/// On the web, when the app is served from the same host as the API (a reverse
/// proxy like Caddy/nginx routes `/graphql`, `/graphql/ws` and `/health` to the
/// backend), the API is reached through the *same origin the page was served
/// from* instead of a separately configured `host:port`. Overriding the host or
/// the port in settings switches back to explicit `scheme://host:port` mode.
/// The TLS toggle applies to native builds and to explicit host/port mode only;
/// on the web behind a proxy the scheme always follows the page origin.
@Riverpod(keepAlive: true)
class ServerBaseUri extends _$ServerBaseUri {
  @override
  Uri build() {
    final serverIp = ref.watch(serverIpProvider);
    final graphqlPort = ref.watch(serverGraphqlPortProvider);
    final tls = ref.watch(tlsProvider);

    final hasStoredPort = localStorage.containsKey(ServerGraphqlPort._key);
    final isServedOverHttp = Uri.base.scheme == 'http' || Uri.base.scheme == 'https';

    if (kIsWeb && !hasStoredPort && serverIp == Uri.base.host && isServedOverHttp) {
      return Uri.parse(Uri.base.origin);
    }
    return Uri(scheme: tls ? 'https' : 'http', host: serverIp, port: graphqlPort);
  }
}
