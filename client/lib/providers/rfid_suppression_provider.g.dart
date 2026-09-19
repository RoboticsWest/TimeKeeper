// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_suppression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Suppresses the global keyboard-wedge RFID scanner.
///
/// [useRfidScanner] attaches a `HardwareKeyboard` handler and accumulates
/// digits terminated by Enter — which is exactly what typing a PIN looks like.
/// Without this, every PIN entered at the kiosk would also fire a phantom card
/// scan. Any widget that captures digit input (the PIN pad today) holds this
/// flag for as long as it is open.

@ProviderFor(RfidScannerSuppressed)
final rfidScannerSuppressedProvider = RfidScannerSuppressedProvider._();

/// Suppresses the global keyboard-wedge RFID scanner.
///
/// [useRfidScanner] attaches a `HardwareKeyboard` handler and accumulates
/// digits terminated by Enter — which is exactly what typing a PIN looks like.
/// Without this, every PIN entered at the kiosk would also fire a phantom card
/// scan. Any widget that captures digit input (the PIN pad today) holds this
/// flag for as long as it is open.
final class RfidScannerSuppressedProvider extends $NotifierProvider<RfidScannerSuppressed, bool> {
  /// Suppresses the global keyboard-wedge RFID scanner.
  ///
  /// [useRfidScanner] attaches a `HardwareKeyboard` handler and accumulates
  /// digits terminated by Enter — which is exactly what typing a PIN looks like.
  /// Without this, every PIN entered at the kiosk would also fire a phantom card
  /// scan. Any widget that captures digit input (the PIN pad today) holds this
  /// flag for as long as it is open.
  RfidScannerSuppressedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidScannerSuppressedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidScannerSuppressedHash();

  @$internal
  @override
  RfidScannerSuppressed create() => RfidScannerSuppressed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$rfidScannerSuppressedHash() => r'fc5cc0283407a6daa6859d3ef0243ee3688f3d1f';

/// Suppresses the global keyboard-wedge RFID scanner.
///
/// [useRfidScanner] attaches a `HardwareKeyboard` handler and accumulates
/// digits terminated by Enter — which is exactly what typing a PIN looks like.
/// Without this, every PIN entered at the kiosk would also fire a phantom card
/// scan. Any widget that captures digit input (the PIN pad today) holds this
/// flag for as long as it is open.

abstract class _$RfidScannerSuppressed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
