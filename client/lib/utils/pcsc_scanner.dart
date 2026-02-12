export 'pcsc_scanner_stub.dart'
    if (dart.library.io) 'pcsc_scanner_native.dart'
    if (dart.library.js_interop) 'pcsc_scanner_web.dart';
