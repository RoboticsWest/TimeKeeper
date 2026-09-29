// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamMemberSessionChanges)
final teamMemberSessionChangesProvider = TeamMemberSessionChangesProvider._();

final class TeamMemberSessionChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<TeamMemberSession>>,
          ChangeEvent<TeamMemberSession>,
          Stream<ChangeEvent<TeamMemberSession>>
        >
    with $FutureModifier<ChangeEvent<TeamMemberSession>>, $StreamProvider<ChangeEvent<TeamMemberSession>> {
  TeamMemberSessionChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberSessionChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberSessionChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<TeamMemberSession>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<TeamMemberSession>> create(Ref ref) {
    return teamMemberSessionChanges(ref);
  }
}

String _$teamMemberSessionChangesHash() => r'd4c306695fec6a0cac13daa460754eb134de8710';

/// The whole attendance table, keyed by id.
///
/// **Built on demand, not at login.** This table grows without bound — a season is tens of
/// thousands of rows, several megabytes of JSON — and downloading it at startup was most of what
/// made the app feel slow on a remote server. Only the things that genuinely need the history read
/// it now: the statistics dashboard and the CSV export. Everything on a hot path
/// ("is this member checked in?", "how many are in this session?") asks a bounded question
/// instead, through [openAttendanceProvider] or the attendance count queries.
///
/// It subscribes to its own change stream rather than relying on a separate sync bridge: with the
/// collection built lazily, a bridge that reached for `.notifier` on the first change event would
/// have quietly re-downloaded the whole table on every client the moment anybody checked in.

@ProviderFor(TeamMemberSessions)
final teamMemberSessionsProvider = TeamMemberSessionsProvider._();

/// The whole attendance table, keyed by id.
///
/// **Built on demand, not at login.** This table grows without bound — a season is tens of
/// thousands of rows, several megabytes of JSON — and downloading it at startup was most of what
/// made the app feel slow on a remote server. Only the things that genuinely need the history read
/// it now: the statistics dashboard and the CSV export. Everything on a hot path
/// ("is this member checked in?", "how many are in this session?") asks a bounded question
/// instead, through [openAttendanceProvider] or the attendance count queries.
///
/// It subscribes to its own change stream rather than relying on a separate sync bridge: with the
/// collection built lazily, a bridge that reached for `.notifier` on the first change event would
/// have quietly re-downloaded the whole table on every client the moment anybody checked in.
final class TeamMemberSessionsProvider extends $NotifierProvider<TeamMemberSessions, Map<String, TeamMemberSession>> {
  /// The whole attendance table, keyed by id.
  ///
  /// **Built on demand, not at login.** This table grows without bound — a season is tens of
  /// thousands of rows, several megabytes of JSON — and downloading it at startup was most of what
  /// made the app feel slow on a remote server. Only the things that genuinely need the history read
  /// it now: the statistics dashboard and the CSV export. Everything on a hot path
  /// ("is this member checked in?", "how many are in this session?") asks a bounded question
  /// instead, through [openAttendanceProvider] or the attendance count queries.
  ///
  /// It subscribes to its own change stream rather than relying on a separate sync bridge: with the
  /// collection built lazily, a bridge that reached for `.notifier` on the first change event would
  /// have quietly re-downloaded the whole table on every client the moment anybody checked in.
  TeamMemberSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberSessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberSessionsHash();

  @$internal
  @override
  TeamMemberSessions create() => TeamMemberSessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TeamMemberSession> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, TeamMemberSession>>(value));
  }
}

String _$teamMemberSessionsHash() => r'ca1f99e9436523c0486636e1518566dec1a53f6e';

/// The whole attendance table, keyed by id.
///
/// **Built on demand, not at login.** This table grows without bound — a season is tens of
/// thousands of rows, several megabytes of JSON — and downloading it at startup was most of what
/// made the app feel slow on a remote server. Only the things that genuinely need the history read
/// it now: the statistics dashboard and the CSV export. Everything on a hot path
/// ("is this member checked in?", "how many are in this session?") asks a bounded question
/// instead, through [openAttendanceProvider] or the attendance count queries.
///
/// It subscribes to its own change stream rather than relying on a separate sync bridge: with the
/// collection built lazily, a bridge that reached for `.notifier` on the first change event would
/// have quietly re-downloaded the whole table on every client the moment anybody checked in.

abstract class _$TeamMemberSessions extends $Notifier<Map<String, TeamMemberSession>> {
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
