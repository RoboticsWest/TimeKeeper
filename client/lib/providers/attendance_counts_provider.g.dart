// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_counts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Attendance counters for one page of sessions, counted in SQL.
///
/// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
/// table — which is why the whole table had to be downloaded to render a column of numbers.
/// Keyed by the ids on screen, so paging asks about a page's worth at a time.

@ProviderFor(sessionAttendanceCounts)
final sessionAttendanceCountsProvider = SessionAttendanceCountsFamily._();

/// Attendance counters for one page of sessions, counted in SQL.
///
/// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
/// table — which is why the whole table had to be downloaded to render a column of numbers.
/// Keyed by the ids on screen, so paging asks about a page's worth at a time.

final class SessionAttendanceCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, SessionAttendanceCount>>,
          Map<String, SessionAttendanceCount>,
          FutureOr<Map<String, SessionAttendanceCount>>
        >
    with $FutureModifier<Map<String, SessionAttendanceCount>>, $FutureProvider<Map<String, SessionAttendanceCount>> {
  /// Attendance counters for one page of sessions, counted in SQL.
  ///
  /// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
  /// table — which is why the whole table had to be downloaded to render a column of numbers.
  /// Keyed by the ids on screen, so paging asks about a page's worth at a time.
  SessionAttendanceCountsProvider._({
    required SessionAttendanceCountsFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'sessionAttendanceCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionAttendanceCountsHash();

  @override
  String toString() {
    return r'sessionAttendanceCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, SessionAttendanceCount>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, SessionAttendanceCount>> create(Ref ref) {
    final argument = this.argument as List<String>;
    return sessionAttendanceCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionAttendanceCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionAttendanceCountsHash() => r'1491a20ffe2c2babbb8f5acd5d8f2ffd97d549f2';

/// Attendance counters for one page of sessions, counted in SQL.
///
/// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
/// table — which is why the whole table had to be downloaded to render a column of numbers.
/// Keyed by the ids on screen, so paging asks about a page's worth at a time.

final class SessionAttendanceCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, SessionAttendanceCount>>, List<String>> {
  SessionAttendanceCountsFamily._()
    : super(
        retry: null,
        name: r'sessionAttendanceCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Attendance counters for one page of sessions, counted in SQL.
  ///
  /// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
  /// table — which is why the whole table had to be downloaded to render a column of numbers.
  /// Keyed by the ids on screen, so paging asks about a page's worth at a time.

  SessionAttendanceCountsProvider call(List<String> sessionIds) =>
      SessionAttendanceCountsProvider._(argument: sessionIds, from: this);

  @override
  String toString() => r'sessionAttendanceCountsProvider';
}

/// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
///
/// One aggregate row instead of the whole table: the Sessions page's "Unique Members" tile used to
/// be a `Set` built by walking every attendance record the client had downloaded.

@ProviderFor(attendanceSummary)
final attendanceSummaryProvider = AttendanceSummaryProvider._();

/// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
///
/// One aggregate row instead of the whole table: the Sessions page's "Unique Members" tile used to
/// be a `Set` built by walking every attendance record the client had downloaded.

final class AttendanceSummaryProvider
    extends $FunctionalProvider<AsyncValue<AttendanceSummary>, AttendanceSummary, FutureOr<AttendanceSummary>>
    with $FutureModifier<AttendanceSummary>, $FutureProvider<AttendanceSummary> {
  /// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
  ///
  /// One aggregate row instead of the whole table: the Sessions page's "Unique Members" tile used to
  /// be a `Set` built by walking every attendance record the client had downloaded.
  AttendanceSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceSummaryHash();

  @$internal
  @override
  $FutureProviderElement<AttendanceSummary> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttendanceSummary> create(Ref ref) {
    return attendanceSummary(ref);
  }
}

String _$attendanceSummaryHash() => r'e0beb916073411cd80dc89f1add5b94063a41517';

/// One session's attendance rows, newest activity first.
///
/// Asked for the session actually being looked at, rather than filtered out of a client-side copy
/// of the whole table. A session is attended by at most the size of the team, so a single page
/// covers it.

@ProviderFor(sessionAttendance)
final sessionAttendanceProvider = SessionAttendanceFamily._();

/// One session's attendance rows, newest activity first.
///
/// Asked for the session actually being looked at, rather than filtered out of a client-side copy
/// of the whole table. A session is attended by at most the size of the team, so a single page
/// covers it.

final class SessionAttendanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamMemberSession>>,
          List<TeamMemberSession>,
          FutureOr<List<TeamMemberSession>>
        >
    with $FutureModifier<List<TeamMemberSession>>, $FutureProvider<List<TeamMemberSession>> {
  /// One session's attendance rows, newest activity first.
  ///
  /// Asked for the session actually being looked at, rather than filtered out of a client-side copy
  /// of the whole table. A session is attended by at most the size of the team, so a single page
  /// covers it.
  SessionAttendanceProvider._({required SessionAttendanceFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'sessionAttendanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionAttendanceHash();

  @override
  String toString() {
    return r'sessionAttendanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TeamMemberSession>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TeamMemberSession>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionAttendance(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionAttendanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionAttendanceHash() => r'114d9f5a9cb312c846acbd6993748a6487a63638';

/// One session's attendance rows, newest activity first.
///
/// Asked for the session actually being looked at, rather than filtered out of a client-side copy
/// of the whole table. A session is attended by at most the size of the team, so a single page
/// covers it.

final class SessionAttendanceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TeamMemberSession>>, String> {
  SessionAttendanceFamily._()
    : super(
        retry: null,
        name: r'sessionAttendanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One session's attendance rows, newest activity first.
  ///
  /// Asked for the session actually being looked at, rather than filtered out of a client-side copy
  /// of the whole table. A session is attended by at most the size of the team, so a single page
  /// covers it.

  SessionAttendanceProvider call(String sessionId) => SessionAttendanceProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionAttendanceProvider';
}
