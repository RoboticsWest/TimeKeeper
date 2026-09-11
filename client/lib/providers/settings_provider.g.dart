// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsQuery)
final settingsQueryProvider = SettingsQueryProvider._();

final class SettingsQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Settings?>,
          Settings?,
          FutureOr<Settings?>
        >
    with $FutureModifier<Settings?>, $FutureProvider<Settings?> {
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
  $FutureProviderElement<Settings?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Settings?> create(Ref ref) {
    return settingsQuery(ref);
  }
}

String _$settingsQueryHash() => r'ab23d82d651d5b3d4dac404ee74363037a61de29';

@ProviderFor(logoQuery)
final logoQueryProvider = LogoQueryProvider._();

final class LogoQueryProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
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
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return logoQuery(ref);
  }
}

String _$logoQueryHash() => r'a77bd173892382892e3ba90b5f68abeb04b730b2';

@ProviderFor(discordRolesQuery)
final discordRolesQueryProvider = DiscordRolesQueryProvider._();

final class DiscordRolesQueryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DiscordRole>>,
          List<DiscordRole>,
          FutureOr<List<DiscordRole>>
        >
    with
        $FutureModifier<List<DiscordRole>>,
        $FutureProvider<List<DiscordRole>> {
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
  $FutureProviderElement<List<DiscordRole>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DiscordRole>> create(Ref ref) {
    return discordRolesQuery(ref);
  }
}

String _$discordRolesQueryHash() => r'f1d84a6edf704390627e91a279c1c114e0236301';

@ProviderFor(SettingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends $NotifierProvider<SettingsService, void> {
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
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsServiceHash() => r'a69ae82cd6084c165ee9c2c148ac68d386526075';

abstract class _$SettingsService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
