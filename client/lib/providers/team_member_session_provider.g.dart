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
    with
        $FutureModifier<ChangeEvent<TeamMemberSession>>,
        $StreamProvider<ChangeEvent<TeamMemberSession>> {
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
  $StreamProviderElement<ChangeEvent<TeamMemberSession>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<TeamMemberSession>> create(Ref ref) {
    return teamMemberSessionChanges(ref);
  }
}

String _$teamMemberSessionChangesHash() =>
    r'd4c306695fec6a0cac13daa460754eb134de8710';

@ProviderFor(TeamMemberSessions)
final teamMemberSessionsProvider = TeamMemberSessionsProvider._();

final class TeamMemberSessionsProvider
    extends
        $NotifierProvider<TeamMemberSessions, Map<String, TeamMemberSession>> {
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
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TeamMemberSession>>(
        value,
      ),
    );
  }
}

String _$teamMemberSessionsHash() =>
    r'c46867693cad5856ac10717f46607b69e7aaf224';

abstract class _$TeamMemberSessions
    extends $Notifier<Map<String, TeamMemberSession>> {
  Map<String, TeamMemberSession> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, TeamMemberSession>,
              Map<String, TeamMemberSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, TeamMemberSession>,
                Map<String, TeamMemberSession>
              >,
              Map<String, TeamMemberSession>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(teamMemberSessionsSync)
final teamMemberSessionsSyncProvider = TeamMemberSessionsSyncProvider._();

final class TeamMemberSessionsSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  TeamMemberSessionsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberSessionsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberSessionsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return teamMemberSessionsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$teamMemberSessionsSyncHash() =>
    r'8b127802320ed08d20c1097495e61215a1353a9a';
