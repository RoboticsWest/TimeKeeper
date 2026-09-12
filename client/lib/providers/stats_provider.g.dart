// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The dashboard's filter state.

@ProviderFor(StatsFilter)
final statsFilterProvider = StatsFilterProvider._();

/// The dashboard's filter state.
final class StatsFilterProvider
    extends $NotifierProvider<StatsFilter, StatsQuery> {
  /// The dashboard's filter state.
  StatsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsFilterHash();

  @$internal
  @override
  StatsFilter create() => StatsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsQuery>(value),
    );
  }
}

String _$statsFilterHash() => r'9e555d1b7ae249f0dc43f545c63f3e0509ea07a1';

/// The dashboard's filter state.

abstract class _$StatsFilter extends $Notifier<StatsQuery> {
  StatsQuery build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StatsQuery, StatsQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StatsQuery, StatsQuery>,
              StatsQuery,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The active query, with `asOf` refreshed from the shared ticker.

@ProviderFor(statsQuery)
final statsQueryProvider = StatsQueryProvider._();

/// The active query, with `asOf` refreshed from the shared ticker.

final class StatsQueryProvider
    extends $FunctionalProvider<StatsQuery, StatsQuery, StatsQuery>
    with $Provider<StatsQuery> {
  /// The active query, with `asOf` refreshed from the shared ticker.
  StatsQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsQueryHash();

  @$internal
  @override
  $ProviderElement<StatsQuery> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsQuery create(Ref ref) {
    return statsQuery(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsQuery>(value),
    );
  }
}

String _$statsQueryHash() => r'c94ca0adb0f56b495c5ea47b9d5963edcbffe363';

/// Filters sessions and member sessions by the query, then indexes them.

@ProviderFor(statsScope)
final statsScopeProvider = StatsScopeFamily._();

/// Filters sessions and member sessions by the query, then indexes them.

final class StatsScopeProvider
    extends $FunctionalProvider<StatsScope, StatsScope, StatsScope>
    with $Provider<StatsScope> {
  /// Filters sessions and member sessions by the query, then indexes them.
  StatsScopeProvider._({
    required StatsScopeFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'statsScopeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statsScopeHash();

  @override
  String toString() {
    return r'statsScopeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StatsScope> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsScope create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return statsScope(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsScope>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StatsScopeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statsScopeHash() => r'aa4bdcc083afdaf268ddce7fd5132162ccbf0ea6';

/// Filters sessions and member sessions by the query, then indexes them.

final class StatsScopeFamily extends $Family
    with $FunctionalFamilyOverride<StatsScope, StatsQuery> {
  StatsScopeFamily._()
    : super(
        retry: null,
        name: r'statsScopeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filters sessions and member sessions by the query, then indexes them.

  StatsScopeProvider call(StatsQuery query) =>
      StatsScopeProvider._(argument: query, from: this);

  @override
  String toString() => r'statsScopeProvider';
}

/// Hours and headcount per bucket.
///
/// Unlike the helper it replaces, this includes unfinished sessions — the KPI
/// overtime figure always counted them, so excluding them here made the chart
/// disagree with the headline number above it.

@ProviderFor(hoursSeries)
final hoursSeriesProvider = HoursSeriesFamily._();

/// Hours and headcount per bucket.
///
/// Unlike the helper it replaces, this includes unfinished sessions — the KPI
/// overtime figure always counted them, so excluding them here made the chart
/// disagree with the headline number above it.

final class HoursSeriesProvider
    extends
        $FunctionalProvider<
          List<HoursBucket>,
          List<HoursBucket>,
          List<HoursBucket>
        >
    with $Provider<List<HoursBucket>> {
  /// Hours and headcount per bucket.
  ///
  /// Unlike the helper it replaces, this includes unfinished sessions — the KPI
  /// overtime figure always counted them, so excluding them here made the chart
  /// disagree with the headline number above it.
  HoursSeriesProvider._({
    required HoursSeriesFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'hoursSeriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hoursSeriesHash();

  @override
  String toString() {
    return r'hoursSeriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<HoursBucket>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<HoursBucket> create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return hoursSeries(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HoursBucket> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HoursBucket>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HoursSeriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hoursSeriesHash() => r'83f0561ea36066a4d7c54bc83136380056e596f3';

/// Hours and headcount per bucket.
///
/// Unlike the helper it replaces, this includes unfinished sessions — the KPI
/// overtime figure always counted them, so excluding them here made the chart
/// disagree with the headline number above it.

final class HoursSeriesFamily extends $Family
    with $FunctionalFamilyOverride<List<HoursBucket>, StatsQuery> {
  HoursSeriesFamily._()
    : super(
        retry: null,
        name: r'hoursSeriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Hours and headcount per bucket.
  ///
  /// Unlike the helper it replaces, this includes unfinished sessions — the KPI
  /// overtime figure always counted them, so excluding them here made the chart
  /// disagree with the headline number above it.

  HoursSeriesProvider call(StatsQuery query) =>
      HoursSeriesProvider._(argument: query, from: this);

  @override
  String toString() => r'hoursSeriesProvider';
}

/// Per-member totals, sorted by total time descending.

@ProviderFor(memberHoursRows)
final memberHoursRowsProvider = MemberHoursRowsFamily._();

/// Per-member totals, sorted by total time descending.

final class MemberHoursRowsProvider
    extends
        $FunctionalProvider<
          List<MemberHoursRow>,
          List<MemberHoursRow>,
          List<MemberHoursRow>
        >
    with $Provider<List<MemberHoursRow>> {
  /// Per-member totals, sorted by total time descending.
  MemberHoursRowsProvider._({
    required MemberHoursRowsFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'memberHoursRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberHoursRowsHash();

  @override
  String toString() {
    return r'memberHoursRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<MemberHoursRow>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MemberHoursRow> create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return memberHoursRows(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MemberHoursRow> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MemberHoursRow>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberHoursRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberHoursRowsHash() => r'fb600b7f14003ec17fa8014c245d024df69d10ef';

/// Per-member totals, sorted by total time descending.

final class MemberHoursRowsFamily extends $Family
    with $FunctionalFamilyOverride<List<MemberHoursRow>, StatsQuery> {
  MemberHoursRowsFamily._()
    : super(
        retry: null,
        name: r'memberHoursRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-member totals, sorted by total time descending.

  MemberHoursRowsProvider call(StatsQuery query) =>
      MemberHoursRowsProvider._(argument: query, from: this);

  @override
  String toString() => r'memberHoursRowsProvider';
}

/// Locations ranked by total time logged.

@ProviderFor(locationRanking)
final locationRankingProvider = LocationRankingFamily._();

/// Locations ranked by total time logged.

final class LocationRankingProvider
    extends
        $FunctionalProvider<
          List<LocationRankRow>,
          List<LocationRankRow>,
          List<LocationRankRow>
        >
    with $Provider<List<LocationRankRow>> {
  /// Locations ranked by total time logged.
  LocationRankingProvider._({
    required LocationRankingFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'locationRankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$locationRankingHash();

  @override
  String toString() {
    return r'locationRankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<LocationRankRow>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<LocationRankRow> create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return locationRanking(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LocationRankRow> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LocationRankRow>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocationRankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$locationRankingHash() => r'd35372e306734b373f492f27b7431dd2e3045e7c';

/// Locations ranked by total time logged.

final class LocationRankingFamily extends $Family
    with $FunctionalFamilyOverride<List<LocationRankRow>, StatsQuery> {
  LocationRankingFamily._()
    : super(
        retry: null,
        name: r'locationRankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Locations ranked by total time logged.

  LocationRankingProvider call(StatsQuery query) =>
      LocationRankingProvider._(argument: query, from: this);

  @override
  String toString() => r'locationRankingProvider';
}

/// Weekday x hour check-in density.

@ProviderFor(checkInHeatmap)
final checkInHeatmapProvider = CheckInHeatmapFamily._();

/// Weekday x hour check-in density.

final class CheckInHeatmapProvider
    extends $FunctionalProvider<CheckInHeatmap, CheckInHeatmap, CheckInHeatmap>
    with $Provider<CheckInHeatmap> {
  /// Weekday x hour check-in density.
  CheckInHeatmapProvider._({
    required CheckInHeatmapFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'checkInHeatmapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$checkInHeatmapHash();

  @override
  String toString() {
    return r'checkInHeatmapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CheckInHeatmap> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckInHeatmap create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return checkInHeatmap(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInHeatmap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInHeatmap>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckInHeatmapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$checkInHeatmapHash() => r'a555466cbd0f9b2be406a480140166b1bb1ea79d';

/// Weekday x hour check-in density.

final class CheckInHeatmapFamily extends $Family
    with $FunctionalFamilyOverride<CheckInHeatmap, StatsQuery> {
  CheckInHeatmapFamily._()
    : super(
        retry: null,
        name: r'checkInHeatmapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Weekday x hour check-in density.

  CheckInHeatmapProvider call(StatsQuery query) =>
      CheckInHeatmapProvider._(argument: query, from: this);

  @override
  String toString() => r'checkInHeatmapProvider';
}

/// Typed attendance insights over the current scope.

@ProviderFor(attendanceInsights)
final attendanceInsightsProvider = AttendanceInsightsFamily._();

/// Typed attendance insights over the current scope.

final class AttendanceInsightsProvider
    extends
        $FunctionalProvider<
          AttendanceInsights,
          AttendanceInsights,
          AttendanceInsights
        >
    with $Provider<AttendanceInsights> {
  /// Typed attendance insights over the current scope.
  AttendanceInsightsProvider._({
    required AttendanceInsightsFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'attendanceInsightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceInsightsHash();

  @override
  String toString() {
    return r'attendanceInsightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AttendanceInsights> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AttendanceInsights create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return attendanceInsights(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceInsights value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceInsights>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceInsightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceInsightsHash() =>
    r'766cc8654a3b3f11bafaa0238313786a3b421915';

/// Typed attendance insights over the current scope.

final class AttendanceInsightsFamily extends $Family
    with $FunctionalFamilyOverride<AttendanceInsights, StatsQuery> {
  AttendanceInsightsFamily._()
    : super(
        retry: null,
        name: r'attendanceInsightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Typed attendance insights over the current scope.

  AttendanceInsightsProvider call(StatsQuery query) =>
      AttendanceInsightsProvider._(argument: query, from: this);

  @override
  String toString() => r'attendanceInsightsProvider';
}

/// Headline numbers for the KPI strip.

@ProviderFor(statsKpis)
final statsKpisProvider = StatsKpisFamily._();

/// Headline numbers for the KPI strip.

final class StatsKpisProvider
    extends $FunctionalProvider<StatsKpis, StatsKpis, StatsKpis>
    with $Provider<StatsKpis> {
  /// Headline numbers for the KPI strip.
  StatsKpisProvider._({
    required StatsKpisFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'statsKpisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statsKpisHash();

  @override
  String toString() {
    return r'statsKpisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StatsKpis> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsKpis create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return statsKpis(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsKpis value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsKpis>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StatsKpisProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statsKpisHash() => r'e194dd6371e90cd067a1a6aa6eb9d8a68d56c78a';

/// Headline numbers for the KPI strip.

final class StatsKpisFamily extends $Family
    with $FunctionalFamilyOverride<StatsKpis, StatsQuery> {
  StatsKpisFamily._()
    : super(
        retry: null,
        name: r'statsKpisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Headline numbers for the KPI strip.

  StatsKpisProvider call(StatsQuery query) =>
      StatsKpisProvider._(argument: query, from: this);

  @override
  String toString() => r'statsKpisProvider';
}

/// KPIs for the period immediately before the query's window, for deltas.
/// Null when the range has no meaningful predecessor (all time).

@ProviderFor(previousKpis)
final previousKpisProvider = PreviousKpisFamily._();

/// KPIs for the period immediately before the query's window, for deltas.
/// Null when the range has no meaningful predecessor (all time).

final class PreviousKpisProvider
    extends $FunctionalProvider<StatsKpis?, StatsKpis?, StatsKpis?>
    with $Provider<StatsKpis?> {
  /// KPIs for the period immediately before the query's window, for deltas.
  /// Null when the range has no meaningful predecessor (all time).
  PreviousKpisProvider._({
    required PreviousKpisFamily super.from,
    required StatsQuery super.argument,
  }) : super(
         retry: null,
         name: r'previousKpisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$previousKpisHash();

  @override
  String toString() {
    return r'previousKpisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StatsKpis?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsKpis? create(Ref ref) {
    final argument = this.argument as StatsQuery;
    return previousKpis(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsKpis? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsKpis?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PreviousKpisProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$previousKpisHash() => r'f5d82598edd9bce633c99988dfc6aacff9af44d0';

/// KPIs for the period immediately before the query's window, for deltas.
/// Null when the range has no meaningful predecessor (all time).

final class PreviousKpisFamily extends $Family
    with $FunctionalFamilyOverride<StatsKpis?, StatsQuery> {
  PreviousKpisFamily._()
    : super(
        retry: null,
        name: r'previousKpisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// KPIs for the period immediately before the query's window, for deltas.
  /// Null when the range has no meaningful predecessor (all time).

  PreviousKpisProvider call(StatsQuery query) =>
      PreviousKpisProvider._(argument: query, from: this);

  @override
  String toString() => r'previousKpisProvider';
}

/// Per-member breakdown for a drilled-into bucket.

@ProviderFor(dayDetail)
final dayDetailProvider = DayDetailFamily._();

/// Per-member breakdown for a drilled-into bucket.

final class DayDetailProvider
    extends
        $FunctionalProvider<
          List<DayMemberRow>,
          List<DayMemberRow>,
          List<DayMemberRow>
        >
    with $Provider<List<DayMemberRow>> {
  /// Per-member breakdown for a drilled-into bucket.
  DayDetailProvider._({
    required DayDetailFamily super.from,
    required (StatsQuery, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'dayDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayDetailHash();

  @override
  String toString() {
    return r'dayDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<DayMemberRow>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DayMemberRow> create(Ref ref) {
    final argument = this.argument as (StatsQuery, DateTime);
    return dayDetail(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DayMemberRow> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DayMemberRow>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DayDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayDetailHash() => r'681aca39c4ca3e471d33210d029ab1772b552672';

/// Per-member breakdown for a drilled-into bucket.

final class DayDetailFamily extends $Family
    with $FunctionalFamilyOverride<List<DayMemberRow>, (StatsQuery, DateTime)> {
  DayDetailFamily._()
    : super(
        retry: null,
        name: r'dayDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-member breakdown for a drilled-into bucket.

  DayDetailProvider call(StatsQuery query, DateTime day) =>
      DayDetailProvider._(argument: (query, day), from: this);

  @override
  String toString() => r'dayDetailProvider';
}
