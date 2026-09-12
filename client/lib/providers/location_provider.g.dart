// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationChanges)
final locationChangesProvider = LocationChangesProvider._();

final class LocationChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<Location>>,
          ChangeEvent<Location>,
          Stream<ChangeEvent<Location>>
        >
    with
        $FutureModifier<ChangeEvent<Location>>,
        $StreamProvider<ChangeEvent<Location>> {
  LocationChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<Location>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<Location>> create(Ref ref) {
    return locationChanges(ref);
  }
}

String _$locationChangesHash() => r'0088a00f2b2b46759654948bab508a46685af7b2';

@ProviderFor(Locations)
final locationsProvider = LocationsProvider._();

final class LocationsProvider
    extends $NotifierProvider<Locations, Map<String, Location>> {
  LocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsHash();

  @$internal
  @override
  Locations create() => Locations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Location> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Location>>(value),
    );
  }
}

String _$locationsHash() => r'731d184b6192831b1d06f5049e5905607c61a627';

abstract class _$Locations extends $Notifier<Map<String, Location>> {
  Map<String, Location> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Location>, Map<String, Location>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Location>, Map<String, Location>>,
              Map<String, Location>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Bridges [locationChangesProvider] to [locationsProvider]. Views watch this to activate the
/// live-update subscription.

@ProviderFor(locationsSync)
final locationsSyncProvider = LocationsSyncProvider._();

/// Bridges [locationChangesProvider] to [locationsProvider]. Views watch this to activate the
/// live-update subscription.

final class LocationsSyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Bridges [locationChangesProvider] to [locationsProvider]. Views watch this to activate the
  /// live-update subscription.
  LocationsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return locationsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$locationsSyncHash() => r'a5a8da9846eab6c3010f9c34fbd8446af00400be';

@ProviderFor(CurrentLocation)
final currentLocationProvider = CurrentLocationProvider._();

final class CurrentLocationProvider
    extends $NotifierProvider<CurrentLocation, String?> {
  CurrentLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocationHash();

  @$internal
  @override
  CurrentLocation create() => CurrentLocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentLocationHash() => r'02510d0cdd634763bd5baf0930da004a5906b4f3';

abstract class _$CurrentLocation extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
