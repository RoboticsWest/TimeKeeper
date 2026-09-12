import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';

/// Debug-only override of the logical size the app lays out against.
///
/// Exists so an automation driver (marionette) can exercise the responsive
/// breakpoints without a compositor-level window tool — this session is
/// Wayland, where `window_manager.setSize` is not honoured. Instead of
/// resizing the real window, [App] letterboxes the whole app into this size,
/// which is what the layout code actually reacts to.
///
/// `null` means "use the real window size". Debug builds only.
final ValueNotifier<Size?> debugSizeOverride = ValueNotifier<Size?>(null);

bool _registered = false;

/// Registers `ext.flutter.tkDebug.setWindowSize`, taking `width`/`height`.
/// Omit both to clear the override and go back to the real window size.
void registerDebugWindowExtension() {
  // Hot restart re-runs main() on the same isolate, where a second
  // registration of the same name throws.
  if (!kDebugMode || _registered) return;
  _registered = true;

  developer.registerExtension('ext.flutter.tkDebug.setWindowSize', (
    method,
    parameters,
  ) async {
    final width = double.tryParse(parameters['width'] ?? '');
    final height = double.tryParse(parameters['height'] ?? '');

    if (width == null && height == null) {
      debugSizeOverride.value = null;
      return developer.ServiceExtensionResponse.result(
        jsonEncode({'override': null}),
      );
    }
    if (width == null || height == null) {
      return developer.ServiceExtensionResponse.error(
        developer.ServiceExtensionResponse.invalidParams,
        jsonEncode({'error': 'pass both width and height, or neither'}),
      );
    }

    debugSizeOverride.value = Size(width, height);
    return developer.ServiceExtensionResponse.result(
      jsonEncode({'width': width, 'height': height}),
    );
  });
}
