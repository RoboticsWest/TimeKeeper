// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Polls the plain `/health` HTTP endpoint (not part of the GraphQL API) to report connectivity.

@ProviderFor(isConnected)
final isConnectedProvider = IsConnectedProvider._();

/// Polls the plain `/health` HTTP endpoint (not part of the GraphQL API) to report connectivity.

final class IsConnectedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Polls the plain `/health` HTTP endpoint (not part of the GraphQL API) to report connectivity.
  IsConnectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isConnectedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isConnectedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isConnected(ref);
  }
}

String _$isConnectedHash() => r'870392c1a376a7f7e045bdbce1ff749c6bdecfe8';
