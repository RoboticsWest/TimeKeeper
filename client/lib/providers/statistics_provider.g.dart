// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The leaderboard, recomputed server-side.
///
/// Unlike the id-keyed collections this cannot be patched from a delta — it is an aggregate, so
/// any change to its inputs invalidates the whole thing. [aggregateRevisionProvider] re-runs the
/// query when they change; without it the leaderboard silently showed whatever was true when the
/// page first loaded, which is the same "the UI doesn't update" failure as everywhere else.///
/// `keepAlive` so navigating away and back does not recompute it. That is safe here precisely
/// because [aggregateRevisionProvider] advances only when the data behind it actually changes —
/// the result is retained, not cached-and-hoped-for, and a real change still invalidates it within
/// the debounce window.

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardProvider._();

/// The leaderboard, recomputed server-side.
///
/// Unlike the id-keyed collections this cannot be patched from a delta — it is an aggregate, so
/// any change to its inputs invalidates the whole thing. [aggregateRevisionProvider] re-runs the
/// query when they change; without it the leaderboard silently showed whatever was true when the
/// page first loaded, which is the same "the UI doesn't update" failure as everywhere else.///
/// `keepAlive` so navigating away and back does not recompute it. That is safe here precisely
/// because [aggregateRevisionProvider] advances only when the data behind it actually changes —
/// the result is retained, not cached-and-hoped-for, and a real change still invalidates it within
/// the debounce window.

final class LeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LeaderboardEntry>>,
          List<LeaderboardEntry>,
          FutureOr<List<LeaderboardEntry>>
        >
    with $FutureModifier<List<LeaderboardEntry>>, $FutureProvider<List<LeaderboardEntry>> {
  /// The leaderboard, recomputed server-side.
  ///
  /// Unlike the id-keyed collections this cannot be patched from a delta — it is an aggregate, so
  /// any change to its inputs invalidates the whole thing. [aggregateRevisionProvider] re-runs the
  /// query when they change; without it the leaderboard silently showed whatever was true when the
  /// page first loaded, which is the same "the UI doesn't update" failure as everywhere else.///
  /// `keepAlive` so navigating away and back does not recompute it. That is safe here precisely
  /// because [aggregateRevisionProvider] advances only when the data behind it actually changes —
  /// the result is retained, not cached-and-hoped-for, and a real change still invalidates it within
  /// the debounce window.
  LeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardHash();

  @$internal
  @override
  $FutureProviderElement<List<LeaderboardEntry>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<LeaderboardEntry>> create(Ref ref) {
    return leaderboard(ref);
  }
}

String _$leaderboardHash() => r'b6191f7308ebbd030cd7dcb03a988906a4387a30';
