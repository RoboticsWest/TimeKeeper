// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServerIp)
final serverIpProvider = ServerIpProvider._();

final class ServerIpProvider extends $NotifierProvider<ServerIp, String> {
  ServerIpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverIpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverIpHash();

  @$internal
  @override
  ServerIp create() => ServerIp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverIpHash() => r'ffa9aa7115dd723fbe77c41e76b229e441a492d3';

abstract class _$ServerIp extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ServerGraphqlPort)
final serverGraphqlPortProvider = ServerGraphqlPortProvider._();

final class ServerGraphqlPortProvider
    extends $NotifierProvider<ServerGraphqlPort, int> {
  ServerGraphqlPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverGraphqlPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverGraphqlPortHash();

  @$internal
  @override
  ServerGraphqlPort create() => ServerGraphqlPort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$serverGraphqlPortHash() => r'42768c0c0575ff802d06622944630fb25c161510';

abstract class _$ServerGraphqlPort extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Tls)
final tlsProvider = TlsProvider._();

final class TlsProvider extends $NotifierProvider<Tls, bool> {
  TlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tlsHash();

  @$internal
  @override
  Tls create() => Tls();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tlsHash() => r'2e9002931f0ac0fa0c66650f591b2f27a3e4dd14';

abstract class _$Tls extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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

@ProviderFor(ServerBaseUri)
final serverBaseUriProvider = ServerBaseUriProvider._();

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
final class ServerBaseUriProvider
    extends $NotifierProvider<ServerBaseUri, Uri> {
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
  ServerBaseUriProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverBaseUriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverBaseUriHash();

  @$internal
  @override
  ServerBaseUri create() => ServerBaseUri();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri>(value),
    );
  }
}

String _$serverBaseUriHash() => r'e1d17a6de90f6faf4eb3a14b9ef84a76a0d79844';

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

abstract class _$ServerBaseUri extends $Notifier<Uri> {
  Uri build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Uri, Uri>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uri, Uri>,
              Uri,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
