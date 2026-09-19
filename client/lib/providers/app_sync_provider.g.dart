// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-lifetime data bootstrap, wired once from [App].
///
/// The providers it touches are all `keepAlive`, so building them here keeps every dataset and
/// every change subscription alive for the whole session - regardless of which view is open. That
/// is what makes data stay current: a row changed on the server shows up without navigating away
/// and back, let alone restarting the app.
///
/// Datasets built before login would come back empty, so a fresh login re-pulls everything.

@ProviderFor(AppDataSync)
final appDataSyncProvider = AppDataSyncProvider._();

/// App-lifetime data bootstrap, wired once from [App].
///
/// The providers it touches are all `keepAlive`, so building them here keeps every dataset and
/// every change subscription alive for the whole session - regardless of which view is open. That
/// is what makes data stay current: a row changed on the server shows up without navigating away
/// and back, let alone restarting the app.
///
/// Datasets built before login would come back empty, so a fresh login re-pulls everything.
final class AppDataSyncProvider extends $NotifierProvider<AppDataSync, void> {
  /// App-lifetime data bootstrap, wired once from [App].
  ///
  /// The providers it touches are all `keepAlive`, so building them here keeps every dataset and
  /// every change subscription alive for the whole session - regardless of which view is open. That
  /// is what makes data stay current: a row changed on the server shows up without navigating away
  /// and back, let alone restarting the app.
  ///
  /// Datasets built before login would come back empty, so a fresh login re-pulls everything.
  AppDataSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDataSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDataSyncHash();

  @$internal
  @override
  AppDataSync create() => AppDataSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$appDataSyncHash() => r'da2e8e51ffdf29c37c9e782bbb0b02e995f37e44';

/// App-lifetime data bootstrap, wired once from [App].
///
/// The providers it touches are all `keepAlive`, so building them here keeps every dataset and
/// every change subscription alive for the whole session - regardless of which view is open. That
/// is what makes data stay current: a row changed on the server shows up without navigating away
/// and back, let alone restarting the app.
///
/// Datasets built before login would come back empty, so a fresh login re-pulls everything.

abstract class _$AppDataSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
