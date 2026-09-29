// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Who is checked in right now, keyed by attendance id.
///
/// This is the answer to every question the app asks of attendance on a hot path — the kiosk's
/// board, the roster's Check In/Check Out button, the RFID scan's "are they already in?" — and it
/// is bounded by the size of the team rather than by how long the club has existed.
///
/// It exists because those callers used to read [teamMemberSessionsProvider], the *whole*
/// attendance table, which the app downloaded at every login. At a couple of seasons' history that
/// is several megabytes of JSON parsed on the UI isolate before the first screen settles, and on a
/// link with real latency it is most of what "the app feels sluggish" meant. The full collection
/// still exists for the things that genuinely need history (statistics, session totals, CSV
/// export) and is now fetched only when one of those is opened.
///
/// Re-read rather than patched from deltas: a change event can *remove* a row from this set (the
/// checkout that closed it), and an event for a row that was never in it still has to be
/// considered. Asking the server is both simpler and cheap, because the answer is small.

@ProviderFor(OpenAttendance)
final openAttendanceProvider = OpenAttendanceProvider._();

/// Who is checked in right now, keyed by attendance id.
///
/// This is the answer to every question the app asks of attendance on a hot path — the kiosk's
/// board, the roster's Check In/Check Out button, the RFID scan's "are they already in?" — and it
/// is bounded by the size of the team rather than by how long the club has existed.
///
/// It exists because those callers used to read [teamMemberSessionsProvider], the *whole*
/// attendance table, which the app downloaded at every login. At a couple of seasons' history that
/// is several megabytes of JSON parsed on the UI isolate before the first screen settles, and on a
/// link with real latency it is most of what "the app feels sluggish" meant. The full collection
/// still exists for the things that genuinely need history (statistics, session totals, CSV
/// export) and is now fetched only when one of those is opened.
///
/// Re-read rather than patched from deltas: a change event can *remove* a row from this set (the
/// checkout that closed it), and an event for a row that was never in it still has to be
/// considered. Asking the server is both simpler and cheap, because the answer is small.
final class OpenAttendanceProvider extends $NotifierProvider<OpenAttendance, Map<String, TeamMemberSession>> {
  /// Who is checked in right now, keyed by attendance id.
  ///
  /// This is the answer to every question the app asks of attendance on a hot path — the kiosk's
  /// board, the roster's Check In/Check Out button, the RFID scan's "are they already in?" — and it
  /// is bounded by the size of the team rather than by how long the club has existed.
  ///
  /// It exists because those callers used to read [teamMemberSessionsProvider], the *whole*
  /// attendance table, which the app downloaded at every login. At a couple of seasons' history that
  /// is several megabytes of JSON parsed on the UI isolate before the first screen settles, and on a
  /// link with real latency it is most of what "the app feels sluggish" meant. The full collection
  /// still exists for the things that genuinely need history (statistics, session totals, CSV
  /// export) and is now fetched only when one of those is opened.
  ///
  /// Re-read rather than patched from deltas: a change event can *remove* a row from this set (the
  /// checkout that closed it), and an event for a row that was never in it still has to be
  /// considered. Asking the server is both simpler and cheap, because the answer is small.
  OpenAttendanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openAttendanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openAttendanceHash();

  @$internal
  @override
  OpenAttendance create() => OpenAttendance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TeamMemberSession> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, TeamMemberSession>>(value));
  }
}

String _$openAttendanceHash() => r'0d7d3df8edf7c6e01dfd9c70e9d127578d59b5c4';

/// Who is checked in right now, keyed by attendance id.
///
/// This is the answer to every question the app asks of attendance on a hot path — the kiosk's
/// board, the roster's Check In/Check Out button, the RFID scan's "are they already in?" — and it
/// is bounded by the size of the team rather than by how long the club has existed.
///
/// It exists because those callers used to read [teamMemberSessionsProvider], the *whole*
/// attendance table, which the app downloaded at every login. At a couple of seasons' history that
/// is several megabytes of JSON parsed on the UI isolate before the first screen settles, and on a
/// link with real latency it is most of what "the app feels sluggish" meant. The full collection
/// still exists for the things that genuinely need history (statistics, session totals, CSV
/// export) and is now fetched only when one of those is opened.
///
/// Re-read rather than patched from deltas: a change event can *remove* a row from this set (the
/// checkout that closed it), and an event for a row that was never in it still has to be
/// considered. Asking the server is both simpler and cheap, because the answer is small.

abstract class _$OpenAttendance extends $Notifier<Map<String, TeamMemberSession>> {
  Map<String, TeamMemberSession> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, TeamMemberSession>, Map<String, TeamMemberSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TeamMemberSession>, Map<String, TeamMemberSession>>,
              Map<String, TeamMemberSession>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
