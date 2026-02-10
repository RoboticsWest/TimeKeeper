import 'package:window_manager/window_manager.dart';

bool get isKioskModeSupported => true;

Future<void> enableKioskMode() async {
  await windowManager.ensureInitialized();
  await windowManager.setFullScreen(true);
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setPreventClose(true);
}

Future<void> disableKioskMode() async {
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(false);
  await windowManager.setAlwaysOnTop(false);
  await windowManager.setFullScreen(false);
}
