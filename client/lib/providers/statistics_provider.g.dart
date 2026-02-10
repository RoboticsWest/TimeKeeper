// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statisticsService)
final statisticsServiceProvider = StatisticsServiceProvider._();

final class StatisticsServiceProvider
    extends
        $FunctionalProvider<
          StatisticsServiceClient,
          StatisticsServiceClient,
          StatisticsServiceClient
        >
    with $Provider<StatisticsServiceClient> {
  StatisticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statisticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statisticsServiceHash();

  @$internal
  @override
  $ProviderElement<StatisticsServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StatisticsServiceClient create(Ref ref) {
    return statisticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatisticsServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatisticsServiceClient>(value),
    );
  }
}

String _$statisticsServiceHash() => r'31e272fb381e3a6504e74ae2ff25b75fccf47364';

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardProvider._();

final class LeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetLeaderboardResponse>,
          GetLeaderboardResponse,
          FutureOr<GetLeaderboardResponse>
        >
    with
        $FutureModifier<GetLeaderboardResponse>,
        $FutureProvider<GetLeaderboardResponse> {
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
  $FutureProviderElement<GetLeaderboardResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetLeaderboardResponse> create(Ref ref) {
    return leaderboard(ref);
  }
}

String _$leaderboardHash() => r'654fe8fdaa27837695c270386b5da11dffa7552d';
