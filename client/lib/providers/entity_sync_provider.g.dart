// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends
        $FunctionalProvider<
          SyncServiceClient,
          SyncServiceClient,
          SyncServiceClient
        >
    with $Provider<SyncServiceClient> {
  SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncServiceClient create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncServiceClient>(value),
    );
  }
}

String _$syncServiceHash() => r'e5880642621caef9687698fb4c330fe846cf887d';

@ProviderFor(entityStream)
final entityStreamProvider = EntityStreamProvider._();

final class EntityStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamEntitiesResponse>,
          StreamEntitiesResponse,
          Stream<StreamEntitiesResponse>
        >
    with
        $FutureModifier<StreamEntitiesResponse>,
        $StreamProvider<StreamEntitiesResponse> {
  EntityStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamEntitiesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamEntitiesResponse> create(Ref ref) {
    return entityStream(ref);
  }
}

String _$entityStreamHash() => r'af5a2bc9ca4d877eb99ee85518af1eebab58f02a';

/// Auto-dispose provider that bridges [entityStreamProvider] to entity notifiers.
/// Views watch this to activate the combined entity stream.

@ProviderFor(entitySync)
final entitySyncProvider = EntitySyncProvider._();

/// Auto-dispose provider that bridges [entityStreamProvider] to entity notifiers.
/// Views watch this to activate the combined entity stream.

final class EntitySyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Auto-dispose provider that bridges [entityStreamProvider] to entity notifiers.
  /// Views watch this to activate the combined entity stream.
  EntitySyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitySyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitySyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return entitySync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$entitySyncHash() => r'3569581c274b3bad1d997f7ab76e089e8fab3442';
