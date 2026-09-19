import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/paged_result.dart';

/// Paging state shared by the server-driven list providers (attendance, team members,
/// sessions).
///
/// Owns the current `offset`/`pageSize` and re-runs [fetch] whenever either changes. A request
/// token discards an outdated response when the user navigates faster than the network returns.
///
/// Realtime changes go through [loadDebounced] so a burst of deltas (a bulk clear burning
/// through thousands of rows) collapses into one refetch instead of one per row.
///
/// This deliberately does not declare an `on` superclass: the generated `_$...Page` classes
/// extend the internal `$AsyncNotifier`, while the public `AsyncNotifier` is a separate
/// subclass, so an `on AsyncNotifier` clause would not typecheck. The abstract [state] pair
/// is satisfied by whatever notifier base the generator produced.
mixin PagedAsyncNotifier<T> {
  AsyncValue<PagedResult<T>> get state;
  set state(AsyncValue<PagedResult<T>> value);

  int _pageSize = 50;
  int _offset = 0;
  int _request = 0;
  Timer? _cooldown;

  /// The page size in use, exposed for the pager's per-page dropdown.
  int get currentPageSize => _pageSize;

  /// The offset of the first row of the current page.
  int get currentOffset => _offset;

  /// Fetches one page. Keep this light — realtime deltas may call it often.
  Future<PagedResult<T>> fetch(int offset, int pageSize);

  /// Re-pulls [fetch] at the current page.
  ///
  /// When [clear] is false the previous page stays on screen (the pager or a realtime delta
  /// refreshed it), so navigation avoids a spinner flash. Filter changes pass `clear: true` to
  /// hide data that no longer matches rather than briefly showing the stale page.
  Future<void> load({bool clear = false}) async {
    final request = ++_request;
    if (clear || !state.hasValue) state = const AsyncLoading();
    final next = await AsyncValue.guard(() => fetch(_offset, _pageSize));
    if (request == _request) state = next;
  }

  /// Re-pulls the current page now. Manual refresh and filter changes use this.
  Future<void> refresh() => load(clear: true);

  /// Re-pulls after a short quiet period, merging a burst of change events into one request.
  void loadDebounced() {
    _cooldown?.cancel();
    _cooldown = Timer(const Duration(milliseconds: 250), () {
      unawaited(load());
    });
  }

  void setPageSize(int size) {
    if (size == _pageSize) return;
    _pageSize = size;
    _offset = 0;
    unawaited(load(clear: true));
  }

  /// Jumps to the first page — used when the filter changes, since pages are keyed to the
  /// filter's total ordering.
  void resetToFirstPage() {
    _offset = 0;
    unawaited(load(clear: true));
  }

  void nextPage() {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    _offset += _pageSize;
    unawaited(load());
  }

  void previousPage() {
    final current = state.value;
    if (current == null || current.offset <= 0) return;
    _offset = _offset >= _pageSize ? _offset - _pageSize : 0;
    unawaited(load());
  }
}
