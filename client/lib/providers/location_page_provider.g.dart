// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A paged, filtered slice of the locations table, ordered by name.
///
/// Locations arrive in bulk from CSV imports, so the management view pages them rather than
/// pulling the table and filtering in Dart. The kiosk and calendar still use the unpaged
/// `locations` query — they need the whole set to resolve a session's location name.

@ProviderFor(LocationPage)
final locationPageProvider = LocationPageProvider._();

/// A paged, filtered slice of the locations table, ordered by name.
///
/// Locations arrive in bulk from CSV imports, so the management view pages them rather than
/// pulling the table and filtering in Dart. The kiosk and calendar still use the unpaged
/// `locations` query — they need the whole set to resolve a session's location name.
final class LocationPageProvider extends $AsyncNotifierProvider<LocationPage, PagedResult<Location>> {
  /// A paged, filtered slice of the locations table, ordered by name.
  ///
  /// Locations arrive in bulk from CSV imports, so the management view pages them rather than
  /// pulling the table and filtering in Dart. The kiosk and calendar still use the unpaged
  /// `locations` query — they need the whole set to resolve a session's location name.
  LocationPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPageHash();

  @$internal
  @override
  LocationPage create() => LocationPage();
}

String _$locationPageHash() => r'84c581baddd9a4a69ddbb35d202cc84677f309a0';

/// A paged, filtered slice of the locations table, ordered by name.
///
/// Locations arrive in bulk from CSV imports, so the management view pages them rather than
/// pulling the table and filtering in Dart. The kiosk and calendar still use the unpaged
/// `locations` query — they need the whole set to resolve a session's location name.

abstract class _$LocationPage extends $AsyncNotifier<PagedResult<Location>> {
  FutureOr<PagedResult<Location>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedResult<Location>>, PagedResult<Location>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedResult<Location>>, PagedResult<Location>>,
              AsyncValue<PagedResult<Location>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
