// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The server-configured logo, cached in memory and refreshed whenever the
/// connection comes back up.
///
/// This is all that remains of the old "branding" concept — the
/// server-configurable primary/secondary colors were removed in favour of the
/// hand-authored theme, which needs no round-trip to render.

@ProviderFor(LogoNotifier)
final logoProvider = LogoNotifierProvider._();

/// The server-configured logo, cached in memory and refreshed whenever the
/// connection comes back up.
///
/// This is all that remains of the old "branding" concept — the
/// server-configurable primary/secondary colors were removed in favour of the
/// hand-authored theme, which needs no round-trip to render.
final class LogoNotifierProvider extends $NotifierProvider<LogoNotifier, Uint8List?> {
  /// The server-configured logo, cached in memory and refreshed whenever the
  /// connection comes back up.
  ///
  /// This is all that remains of the old "branding" concept — the
  /// server-configurable primary/secondary colors were removed in favour of the
  /// hand-authored theme, which needs no round-trip to render.
  LogoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoNotifierHash();

  @$internal
  @override
  LogoNotifier create() => LogoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uint8List? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Uint8List?>(value));
  }
}

String _$logoNotifierHash() => r'ce01d127cc777972b7f8d1e08e273787b9e347fc';

/// The server-configured logo, cached in memory and refreshed whenever the
/// connection comes back up.
///
/// This is all that remains of the old "branding" concept — the
/// server-configurable primary/secondary colors were removed in favour of the
/// hand-authored theme, which needs no round-trip to render.

abstract class _$LogoNotifier extends $Notifier<Uint8List?> {
  Uint8List? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Uint8List?, Uint8List?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<Uint8List?, Uint8List?>, Uint8List?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
