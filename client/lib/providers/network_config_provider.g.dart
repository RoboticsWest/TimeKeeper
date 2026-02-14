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

@ProviderFor(ServerApiPort)
final serverApiPortProvider = ServerApiPortProvider._();

final class ServerApiPortProvider
    extends $NotifierProvider<ServerApiPort, int> {
  ServerApiPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverApiPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverApiPortHash();

  @$internal
  @override
  ServerApiPort create() => ServerApiPort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$serverApiPortHash() => r'a4326dfe367dad316d896915d0dd63d0eee0e811';

abstract class _$ServerApiPort extends $Notifier<int> {
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
