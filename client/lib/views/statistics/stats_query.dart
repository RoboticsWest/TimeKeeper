import 'package:flutter/foundation.dart';
import 'package:time_keeper/models/team_member.dart';

/// Preset ranges for the statistics dashboard.
enum StatsRange {
  today('Today'),
  last7('Last 7 days'),
  last30('Last 30 days'),
  last90('Last 90 days'),
  thisWeek('This week'),
  thisMonth('This month'),
  ytd('Year to date'),
  all('All time'),
  custom('Custom range');

  const StatsRange(this.label);

  final String label;
}

/// Bucket width for time series. [auto] picks a width that keeps the bucket
/// count readable for the resolved range.
enum StatsBucket {
  auto('Auto'),
  day('D'),
  week('W'),
  month('M');

  const StatsBucket(this.label);

  final String label;
}

/// A resolved half-open date window, `[start, end)`.
@immutable
class DateWindow {
  final DateTime start;
  final DateTime end;

  const DateWindow(this.start, this.end);

  bool contains(DateTime value) => !value.isBefore(start) && value.isBefore(end);

  Duration get span => end.difference(start);
}

DateTime _startOfDay(DateTime value) => DateTime(value.year, value.month, value.day);

/// The full filter state of the statistics dashboard.
///
/// Hand-written [operator ==]/[hashCode] rather than freezed: this is the key
/// of every aggregate provider family, so its equality is what decides whether
/// a rebuild recomputes, and it is worth being able to read directly.
@immutable
class StatsQuery {
  final StatsRange range;
  final DateTime? customStart;
  final DateTime? customEnd;

  /// Empty means "all locations".
  final Set<String> locationIds;

  /// Empty means "all member types".
  final Set<TeamMemberType> memberTypes;
  final StatsBucket bucket;

  /// Quantised "now", so open sessions still tick without invalidating every
  /// aggregate on each frame.
  final DateTime asOf;

  const StatsQuery({
    this.range = StatsRange.last30,
    this.customStart,
    this.customEnd,
    this.locationIds = const {},
    this.memberTypes = const {},
    this.bucket = StatsBucket.auto,
    required this.asOf,
  });

  StatsQuery copyWith({
    StatsRange? range,
    DateTime? customStart,
    DateTime? customEnd,
    Set<String>? locationIds,
    Set<TeamMemberType>? memberTypes,
    StatsBucket? bucket,
    DateTime? asOf,
  }) {
    return StatsQuery(
      range: range ?? this.range,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      locationIds: locationIds ?? this.locationIds,
      memberTypes: memberTypes ?? this.memberTypes,
      bucket: bucket ?? this.bucket,
      asOf: asOf ?? this.asOf,
    );
  }

  /// The concrete window this query selects.
  ///
  /// [StatsRange.all] resolves to a very wide window rather than a null one, so
  /// every consumer can treat the result uniformly.
  DateWindow resolve() {
    final today = _startOfDay(asOf);
    final tomorrow = today.add(const Duration(days: 1));

    switch (range) {
      case StatsRange.today:
        return DateWindow(today, tomorrow);
      case StatsRange.last7:
        return DateWindow(today.subtract(const Duration(days: 6)), tomorrow);
      case StatsRange.last30:
        return DateWindow(today.subtract(const Duration(days: 29)), tomorrow);
      case StatsRange.last90:
        return DateWindow(today.subtract(const Duration(days: 89)), tomorrow);
      case StatsRange.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return DateWindow(monday, monday.add(const Duration(days: 7)));
      case StatsRange.thisMonth:
        return DateWindow(DateTime(today.year, today.month), DateTime(today.year, today.month + 1));
      case StatsRange.ytd:
        return DateWindow(DateTime(today.year), tomorrow);
      case StatsRange.all:
        return DateWindow(DateTime(1970), DateTime(today.year + 100));
      case StatsRange.custom:
        final start = customStart == null ? today : _startOfDay(customStart!);
        final end = customEnd == null ? tomorrow : _startOfDay(customEnd!).add(const Duration(days: 1));
        return DateWindow(start, end.isAfter(start) ? end : start.add(const Duration(days: 1)));
    }
  }

  /// The bucket actually used, resolving [StatsBucket.auto] against the window.
  ///
  /// Auto aims for 7–31 buckets: fewer than that and the series is too coarse
  /// to read a trend from, more and the columns collapse into noise.
  StatsBucket effectiveBucket() {
    if (bucket != StatsBucket.auto) return bucket;

    final days = resolve().span.inDays;
    if (days <= 31) return StatsBucket.day;
    if (days <= 31 * 7) return StatsBucket.week;
    return StatsBucket.month;
  }

  /// The immediately preceding window of the same length, for period-over-period
  /// comparison. Null for [StatsRange.all], which has nothing to compare against.
  DateWindow? previousPeriod() {
    if (range == StatsRange.all) return null;

    final window = resolve();
    switch (range) {
      // Calendar months vary in length, so step by month rather than by span.
      case StatsRange.thisMonth:
        return DateWindow(
          DateTime(window.start.year, window.start.month - 1),
          window.start,
        );
      case StatsRange.ytd:
        return DateWindow(
          DateTime(window.start.year - 1),
          DateTime(window.start.year - 1, window.end.month, window.end.day),
        );
      default:
        final span = window.span;
        return DateWindow(window.start.subtract(span), window.start);
    }
  }

  /// Human-readable resolved range, shown beside the range selector.
  String describe() {
    if (range == StatsRange.all) return 'All time';
    final window = resolve();
    final lastDay = window.end.subtract(const Duration(days: 1));
    final start = '${window.start.year}-${_two(window.start.month)}-${_two(window.start.day)}';
    final end = '${lastDay.year}-${_two(lastDay.month)}-${_two(lastDay.day)}';
    return start == end ? start : '$start → $end';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) {
    return other is StatsQuery &&
        other.range == range &&
        other.customStart == customStart &&
        other.customEnd == customEnd &&
        setEquals(other.locationIds, locationIds) &&
        setEquals(other.memberTypes, memberTypes) &&
        other.bucket == bucket &&
        other.asOf == asOf;
  }

  @override
  int get hashCode => Object.hash(
    range,
    customStart,
    customEnd,
    Object.hashAllUnordered(locationIds),
    Object.hashAllUnordered(memberTypes),
    bucket,
    asOf,
  );
}
