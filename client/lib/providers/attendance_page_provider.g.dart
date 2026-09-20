// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The administrator's attendance history, rendered one page at a time.
///
/// Backed by the server-side `attendance` query so the UI never holds the whole (unbounded)
/// table in memory at once. Realtime deltas re-pull the current page so the list stays honest
/// without being fetched wholesale.

@ProviderFor(AttendancePage)
final attendancePageProvider = AttendancePageProvider._();

/// The administrator's attendance history, rendered one page at a time.
///
/// Backed by the server-side `attendance` query so the UI never holds the whole (unbounded)
/// table in memory at once. Realtime deltas re-pull the current page so the list stays honest
/// without being fetched wholesale.
final class AttendancePageProvider extends $AsyncNotifierProvider<AttendancePage, PagedResult<TeamMemberSession>> {
  /// The administrator's attendance history, rendered one page at a time.
  ///
  /// Backed by the server-side `attendance` query so the UI never holds the whole (unbounded)
  /// table in memory at once. Realtime deltas re-pull the current page so the list stays honest
  /// without being fetched wholesale.
  AttendancePageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendancePageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendancePageHash();

  @$internal
  @override
  AttendancePage create() => AttendancePage();
}

String _$attendancePageHash() => r'a179fca0335a773ece8008794174f5d8aafe9f90';

/// The administrator's attendance history, rendered one page at a time.
///
/// Backed by the server-side `attendance` query so the UI never holds the whole (unbounded)
/// table in memory at once. Realtime deltas re-pull the current page so the list stays honest
/// without being fetched wholesale.

abstract class _$AttendancePage extends $AsyncNotifier<PagedResult<TeamMemberSession>> {
  FutureOr<PagedResult<TeamMemberSession>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedResult<TeamMemberSession>>, PagedResult<TeamMemberSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedResult<TeamMemberSession>>, PagedResult<TeamMemberSession>>,
              AsyncValue<PagedResult<TeamMemberSession>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
