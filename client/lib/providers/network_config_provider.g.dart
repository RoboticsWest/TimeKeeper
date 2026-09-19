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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String>(value));
  }
}

String _$serverIpHash() => r'ffa9aa7115dd723fbe77c41e76b229e441a492d3';

abstract class _$ServerIp extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ServerGraphqlPort)
final serverGraphqlPortProvider = ServerGraphqlPortProvider._();

final class ServerGraphqlPortProvider extends $NotifierProvider<ServerGraphqlPort, int> {
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<int>(value));
  }
}

String _$serverGraphqlPortHash() => r'42768c0c0575ff802d06622944630fb25c161510';

abstract class _$ServerGraphqlPort extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$tlsHash() => r'2e9002931f0ac0fa0c66650f591b2f27a3e4dd14';

abstract class _$Tls extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Base URI used for API connections (GraphQL over HTTP/WS plus the `/health`
/// probe).
///
/// On the web this is *always* the origin the page was served from, with no
/// configuration involved: a web app should never have to be told where its own
/// backend is. Both deployments serve the API on that origin - behind a reverse
/// proxy Caddy routes `/graphql`, `/graphql/ws` and `/health` to the API
/// container, and the all-in-one binary's built-in web server exposes the same
/// three routes on its own port.
///
/// Deriving it rather than storing it also means the scheme always matches the
/// page, so an `https://` page can never end up issuing blocked `http://`
/// requests, and stale settings from an earlier version can't strand the app.
///
/// Native builds (desktop, Android) genuinely do have to be pointed at a
/// server, so there the configured host, port and TLS toggle apply.

@ProviderFor(ServerBaseUri)
final serverBaseUriProvider = ServerBaseUriProvider._();

/// Base URI used for API connections (GraphQL over HTTP/WS plus the `/health`
/// probe).
///
/// On the web this is *always* the origin the page was served from, with no
/// configuration involved: a web app should never have to be told where its own
/// backend is. Both deployments serve the API on that origin - behind a reverse
/// proxy Caddy routes `/graphql`, `/graphql/ws` and `/health` to the API
/// container, and the all-in-one binary's built-in web server exposes the same
/// three routes on its own port.
///
/// Deriving it rather than storing it also means the scheme always matches the
/// page, so an `https://` page can never end up issuing blocked `http://`
/// requests, and stale settings from an earlier version can't strand the app.
///
/// Native builds (desktop, Android) genuinely do have to be pointed at a
/// server, so there the configured host, port and TLS toggle apply.
final class ServerBaseUriProvider extends $NotifierProvider<ServerBaseUri, Uri> {
  /// Base URI used for API connections (GraphQL over HTTP/WS plus the `/health`
  /// probe).
  ///
  /// On the web this is *always* the origin the page was served from, with no
  /// configuration involved: a web app should never have to be told where its own
  /// backend is. Both deployments serve the API on that origin - behind a reverse
  /// proxy Caddy routes `/graphql`, `/graphql/ws` and `/health` to the API
  /// container, and the all-in-one binary's built-in web server exposes the same
  /// three routes on its own port.
  ///
  /// Deriving it rather than storing it also means the scheme always matches the
  /// page, so an `https://` page can never end up issuing blocked `http://`
  /// requests, and stale settings from an earlier version can't strand the app.
  ///
  /// Native builds (desktop, Android) genuinely do have to be pointed at a
  /// server, so there the configured host, port and TLS toggle apply.
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Uri>(value));
  }
}

String _$serverBaseUriHash() => r'635dfeb72dc9e65a783ee09acc49e7771901ffa9';

/// Base URI used for API connections (GraphQL over HTTP/WS plus the `/health`
/// probe).
///
/// On the web this is *always* the origin the page was served from, with no
/// configuration involved: a web app should never have to be told where its own
/// backend is. Both deployments serve the API on that origin - behind a reverse
/// proxy Caddy routes `/graphql`, `/graphql/ws` and `/health` to the API
/// container, and the all-in-one binary's built-in web server exposes the same
/// three routes on its own port.
///
/// Deriving it rather than storing it also means the scheme always matches the
/// page, so an `https://` page can never end up issuing blocked `http://`
/// requests, and stale settings from an earlier version can't strand the app.
///
/// Native builds (desktop, Android) genuinely do have to be pointed at a
/// server, so there the configured host, port and TLS toggle apply.

abstract class _$ServerBaseUri extends $Notifier<Uri> {
  Uri build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Uri, Uri>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<Uri, Uri>, Uri, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
