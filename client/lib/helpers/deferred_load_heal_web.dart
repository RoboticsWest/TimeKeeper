import 'package:web/web.dart';

void notifyDeferredLoadFailureImpl() {
  window.dispatchEvent(Event('tk-deferred-load-error'));
}
