import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The committed value of a search box: what the list is actually filtered by.
///
/// [useDebouncedText] returns this rather than the raw controller text so a view can tell the
/// difference between "the admin is still typing" and "this is the term the current page was
/// fetched for" — the search button and the "searching…" affordance both need that distinction.
class DebouncedText {
  /// The debounced (or explicitly submitted) term the query should use.
  final String value;

  /// The live contents of the field.
  final String raw;

  /// True while [raw] differs from [value], i.e. a keystroke is still settling.
  final bool isPending;

  /// Commits [raw] immediately, cancelling the pending debounce. Wired to the field's
  /// `onSubmitted` and to the search button so Enter never waits out the timer.
  final VoidCallback submit;

  const DebouncedText({required this.value, required this.raw, required this.isPending, required this.submit});
}

/// Debounces a [TextEditingController]'s text into a value safe to drive a server query with.
///
/// This exists because the obvious version is wrong in a way that silently kills the filter:
/// `useTextEditingController` does not rebuild its widget when the text changes, so a
/// `useEffect` keyed on `controller.text` never re-runs and the search term never leaves the
/// box. Subscribing with [useValueListenable] is what makes typing observable at all.
DebouncedText useDebouncedText(TextEditingController controller, {Duration delay = const Duration(milliseconds: 350)}) {
  // Subscribing to the controller is the whole point: it is what rebuilds the view on a
  // keystroke so the debounce below has something to key off.
  final raw = useValueListenable(controller).text;
  final committed = useState(controller.text);

  useEffect(() {
    if (raw == committed.value) return null;
    final timer = Timer(delay, () => committed.value = raw);
    return timer.cancel;
  }, [raw]);

  final submit = useCallback(() {
    committed.value = controller.text;
  }, [controller]);

  return DebouncedText(value: committed.value, raw: raw, isPending: raw != committed.value, submit: submit);
}
