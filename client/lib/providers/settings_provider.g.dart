// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Settings pushed from the server whenever the row changes.
///
/// `settings` is a single-row table with a DB trigger behind it since migration 0006, but
/// nothing was ever subscribed to it — so every client kept whatever settings it happened to
/// fetch at startup until it was restarted. Changing the timezone or a reminder message on one
/// machine left every other one stale.

@ProviderFor(settingsChanges)
final settingsChangesProvider = SettingsChangesProvider._();

/// Settings pushed from the server whenever the row changes.
///
/// `settings` is a single-row table with a DB trigger behind it since migration 0006, but
/// nothing was ever subscribed to it — so every client kept whatever settings it happened to
/// fetch at startup until it was restarted. Changing the timezone or a reminder message on one
/// machine left every other one stale.

final class SettingsChangesProvider extends $FunctionalProvider<AsyncValue<Settings>, Settings, Stream<Settings>>
    with $FutureModifier<Settings>, $StreamProvider<Settings> {
  /// Settings pushed from the server whenever the row changes.
  ///
  /// `settings` is a single-row table with a DB trigger behind it since migration 0006, but
  /// nothing was ever subscribed to it — so every client kept whatever settings it happened to
  /// fetch at startup until it was restarted. Changing the timezone or a reminder message on one
  /// machine left every other one stale.
  SettingsChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsChangesHash();

  @$internal
  @override
  $StreamProviderElement<Settings> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Settings> create(Ref ref) {
    return settingsChanges(ref);
  }
}

String _$settingsChangesHash() => r'71560bc0b4ddac4d437985a562629fc6c5a48855';

/// The current settings: seeded by a query, then kept current by [settingsChanges].
///
/// Watching the subscription means a pushed row rebuilds this provider and every consumer of
/// it, without a re-fetch — the payload is the whole row.

@ProviderFor(settingsQuery)
final settingsQueryProvider = SettingsQueryProvider._();

/// The current settings: seeded by a query, then kept current by [settingsChanges].
///
/// Watching the subscription means a pushed row rebuilds this provider and every consumer of
/// it, without a re-fetch — the payload is the whole row.

final class SettingsQueryProvider extends $FunctionalProvider<AsyncValue<Settings?>, Settings?, FutureOr<Settings?>>
    with $FutureModifier<Settings?>, $FutureProvider<Settings?> {
  /// The current settings: seeded by a query, then kept current by [settingsChanges].
  ///
  /// Watching the subscription means a pushed row rebuilds this provider and every consumer of
  /// it, without a re-fetch — the payload is the whole row.
  SettingsQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsQueryHash();

  @$internal
  @override
  $FutureProviderElement<Settings?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Settings?> create(Ref ref) {
    return settingsQuery(ref);
  }
}

String _$settingsQueryHash() => r'4277f171fe52bebb27b30bf1430ec16b21ad34b4';

@ProviderFor(logoQuery)
final logoQueryProvider = LogoQueryProvider._();

final class LogoQueryProvider extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  LogoQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoQueryHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return logoQuery(ref);
  }
}

String _$logoQueryHash() => r'a77bd173892382892e3ba90b5f68abeb04b730b2';

@ProviderFor(discordRolesQuery)
final discordRolesQueryProvider = DiscordRolesQueryProvider._();

final class DiscordRolesQueryProvider
    extends $FunctionalProvider<AsyncValue<List<DiscordRole>>, List<DiscordRole>, FutureOr<List<DiscordRole>>>
    with $FutureModifier<List<DiscordRole>>, $FutureProvider<List<DiscordRole>> {
  DiscordRolesQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discordRolesQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discordRolesQueryHash();

  @$internal
  @override
  $FutureProviderElement<List<DiscordRole>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DiscordRole>> create(Ref ref) {
    return discordRolesQuery(ref);
  }
}

String _$discordRolesQueryHash() => r'f1d84a6edf704390627e91a279c1c114e0236301';

@ProviderFor(SettingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider extends $NotifierProvider<SettingsService, void> {
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  SettingsService create() => SettingsService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$settingsServiceHash() => r'4d8391e1ab32666479313fccf4e1072befe59908';

abstract class _$SettingsService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
