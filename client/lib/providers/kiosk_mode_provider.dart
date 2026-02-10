import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/utils/logger.dart';

import 'package:time_keeper/helpers/kiosk_mode_stub.dart'
    if (dart.library.io) 'package:time_keeper/helpers/kiosk_mode_native.dart'
    if (dart.library.js_interop) 'package:time_keeper/helpers/kiosk_mode_web.dart';

part 'kiosk_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class KioskMode extends _$KioskMode {
  static const String _key = 'kiosk_mode';

  Future<void> toggle() async {
    final newValue = !state;
    if (newValue) {
      await enableKioskMode();
      logger.i('Kiosk mode enabled');
    } else {
      await disableKioskMode();
      logger.i('Kiosk mode disabled');
    }
    localStorage.setBool(_key, newValue);
    state = newValue;
  }

  @override
  bool build() {
    final stored = localStorage.getBool(_key) ?? false;

    // Restore kiosk mode on app start if it was previously enabled
    if (stored && isKioskModeSupported) {
      enableKioskMode();
    }

    return stored;
  }
}
