// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aggregate_revision_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A counter that advances when the data behind the *server-computed* aggregates changes.
///
/// The leaderboard and the achievements board are recomputed server-side from the whole
/// attendance history, so they cannot be patched from a change delta the way an id-keyed
/// collection can — any change invalidates the whole answer. They used to express that by
/// watching the collection providers themselves, which was wrong twice over:
///
///   * A collection's state changes when its *initial fetch lands*, not only when the data
///     changes. Watching three of them meant the aggregate query fired once immediately and then
///     again as each collection arrived — four full recomputations of the same answer on every
///     visit to the page, each one a multi-table pass on the server. Under that load the last of
///     them could exceed the pool's connection timeout, and the error surfaced as an empty list:
///     "No team members yet" on a page that had just spent thirty seconds loading.
///   * Every realtime delta also changes that state, so a burst of them meant one full
///     recomputation per row touched.
///
/// Watching the change *streams* instead fixes the first (a query landing is not a change event)
/// and debouncing fixes the second.

@ProviderFor(AggregateRevision)
final aggregateRevisionProvider = AggregateRevisionProvider._();

/// A counter that advances when the data behind the *server-computed* aggregates changes.
///
/// The leaderboard and the achievements board are recomputed server-side from the whole
/// attendance history, so they cannot be patched from a change delta the way an id-keyed
/// collection can — any change invalidates the whole answer. They used to express that by
/// watching the collection providers themselves, which was wrong twice over:
///
///   * A collection's state changes when its *initial fetch lands*, not only when the data
///     changes. Watching three of them meant the aggregate query fired once immediately and then
///     again as each collection arrived — four full recomputations of the same answer on every
///     visit to the page, each one a multi-table pass on the server. Under that load the last of
///     them could exceed the pool's connection timeout, and the error surfaced as an empty list:
///     "No team members yet" on a page that had just spent thirty seconds loading.
///   * Every realtime delta also changes that state, so a burst of them meant one full
///     recomputation per row touched.
///
/// Watching the change *streams* instead fixes the first (a query landing is not a change event)
/// and debouncing fixes the second.
final class AggregateRevisionProvider extends $NotifierProvider<AggregateRevision, int> {
  /// A counter that advances when the data behind the *server-computed* aggregates changes.
  ///
  /// The leaderboard and the achievements board are recomputed server-side from the whole
  /// attendance history, so they cannot be patched from a change delta the way an id-keyed
  /// collection can — any change invalidates the whole answer. They used to express that by
  /// watching the collection providers themselves, which was wrong twice over:
  ///
  ///   * A collection's state changes when its *initial fetch lands*, not only when the data
  ///     changes. Watching three of them meant the aggregate query fired once immediately and then
  ///     again as each collection arrived — four full recomputations of the same answer on every
  ///     visit to the page, each one a multi-table pass on the server. Under that load the last of
  ///     them could exceed the pool's connection timeout, and the error surfaced as an empty list:
  ///     "No team members yet" on a page that had just spent thirty seconds loading.
  ///   * Every realtime delta also changes that state, so a burst of them meant one full
  ///     recomputation per row touched.
  ///
  /// Watching the change *streams* instead fixes the first (a query landing is not a change event)
  /// and debouncing fixes the second.
  AggregateRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aggregateRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aggregateRevisionHash();

  @$internal
  @override
  AggregateRevision create() => AggregateRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<int>(value));
  }
}

String _$aggregateRevisionHash() => r'5c231a196b10be621c075a75e82ea555e222640b';

/// A counter that advances when the data behind the *server-computed* aggregates changes.
///
/// The leaderboard and the achievements board are recomputed server-side from the whole
/// attendance history, so they cannot be patched from a change delta the way an id-keyed
/// collection can — any change invalidates the whole answer. They used to express that by
/// watching the collection providers themselves, which was wrong twice over:
///
///   * A collection's state changes when its *initial fetch lands*, not only when the data
///     changes. Watching three of them meant the aggregate query fired once immediately and then
///     again as each collection arrived — four full recomputations of the same answer on every
///     visit to the page, each one a multi-table pass on the server. Under that load the last of
///     them could exceed the pool's connection timeout, and the error surfaced as an empty list:
///     "No team members yet" on a page that had just spent thirty seconds loading.
///   * Every realtime delta also changes that state, so a burst of them meant one full
///     recomputation per row touched.
///
/// Watching the change *streams* instead fixes the first (a query landing is not a change event)
/// and debouncing fixes the second.

abstract class _$AggregateRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
