// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrandingNotifier)
final brandingProvider = BrandingNotifierProvider._();

final class BrandingNotifierProvider
    extends $NotifierProvider<BrandingNotifier, Branding> {
  BrandingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandingNotifierHash();

  @$internal
  @override
  BrandingNotifier create() => BrandingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Branding value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Branding>(value),
    );
  }
}

String _$brandingNotifierHash() => r'129f2c1b1ec469e848413f87090a4eaa303a96f7';

abstract class _$BrandingNotifier extends $Notifier<Branding> {
  Branding build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Branding, Branding>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Branding, Branding>,
              Branding,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
