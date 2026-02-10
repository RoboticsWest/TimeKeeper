// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

final class LocationServiceProvider
    extends
        $FunctionalProvider<
          LocationServiceClient,
          LocationServiceClient,
          LocationServiceClient
        >
    with $Provider<LocationServiceClient> {
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationServiceClient create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationServiceClient>(value),
    );
  }
}

String _$locationServiceHash() => r'7c87fbb460cafb839977ed7c0e3206a9fc2bebab';

@ProviderFor(locationsStream)
final locationsStreamProvider = LocationsStreamProvider._();

final class LocationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamLocationsResponse>,
          StreamLocationsResponse,
          Stream<StreamLocationsResponse>
        >
    with
        $FutureModifier<StreamLocationsResponse>,
        $StreamProvider<StreamLocationsResponse> {
  LocationsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamLocationsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamLocationsResponse> create(Ref ref) {
    return locationsStream(ref);
  }
}

String _$locationsStreamHash() => r'ed80c38db4fdb74855e7316cd049504fcd2beedf';

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

String _$locationsHash() => r'f5dfe50908a959d5ac8ca292276fb7407ac0ce70';

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
