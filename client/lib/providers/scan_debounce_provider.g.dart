// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_debounce_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScanDebounceMins)
final scanDebounceMinsProvider = ScanDebounceMinsProvider._();

final class ScanDebounceMinsProvider
    extends $NotifierProvider<ScanDebounceMins, int> {
  ScanDebounceMinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scanDebounceMinsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scanDebounceMinsHash();

  @$internal
  @override
  ScanDebounceMins create() => ScanDebounceMins();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$scanDebounceMinsHash() => r'e410143b322f9a1b73c55a4ce90147bc86d45351';

abstract class _$ScanDebounceMins extends $Notifier<int> {
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
