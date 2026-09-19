import 'package:time_keeper/helpers/deferred_load_heal_stub.dart'
    if (dart.library.js_interop) 'package:time_keeper/helpers/deferred_load_heal_web.dart';

/// Notify the web shell that a deferred library failed to load.
///
/// The load failure is rendered in-widget by [DeferredWidget] and never
/// escapes to an unhandled rejection, so the [unhandledrejection] listener in
/// `web/index.html` alone can never see it. This call hands the failure to
/// that shell so it can clear the service-worker caches and reload.
///
/// No-op on non-web platforms.
void notifyDeferredLoadFailure() => notifyDeferredLoadFailureImpl();
