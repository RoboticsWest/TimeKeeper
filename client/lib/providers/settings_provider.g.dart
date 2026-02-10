// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends
        $FunctionalProvider<
          SettingsServiceClient,
          SettingsServiceClient,
          SettingsServiceClient
        >
    with $Provider<SettingsServiceClient> {
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
  $ProviderElement<SettingsServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsServiceClient create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsServiceClient>(value),
    );
  }
}

String _$settingsServiceHash() => r'fd24134d8762cec2bfee2605018fd515e3cd45f9';
