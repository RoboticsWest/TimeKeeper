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
/// any change to its inputs invalidates the whole thing. Watching those collections re-runs the
/// query; without it the leaderboard silently showed whatever was true when the page first
/// loaded, which is the same "the UI doesn't update" failure as everywhere else.

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardProvider._();

/// The leaderboard, recomputed server-side.
///
/// Unlike the id-keyed collections this cannot be patched from a delta — it is an aggregate, so
/// any change to its inputs invalidates the whole thing. Watching those collections re-runs the
/// query; without it the leaderboard silently showed whatever was true when the page first
/// loaded, which is the same "the UI doesn't update" failure as everywhere else.

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
  /// any change to its inputs invalidates the whole thing. Watching those collections re-runs the
  /// query; without it the leaderboard silently showed whatever was true when the page first
  /// loaded, which is the same "the UI doesn't update" failure as everywhere else.
  LeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardProvider',
        isAutoDispose: true,
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

String _$leaderboardHash() => r'3b016a8675d47359ebf174632b7caf87e6eb0fe6';
