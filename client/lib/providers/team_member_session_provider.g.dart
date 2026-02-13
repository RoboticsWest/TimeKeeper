// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamMemberSessionService)
final teamMemberSessionServiceProvider = TeamMemberSessionServiceProvider._();

final class TeamMemberSessionServiceProvider
    extends
        $FunctionalProvider<
          TeamMemberSessionServiceClient,
          TeamMemberSessionServiceClient,
          TeamMemberSessionServiceClient
        >
    with $Provider<TeamMemberSessionServiceClient> {
  TeamMemberSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberSessionServiceHash();

  @$internal
  @override
  $ProviderElement<TeamMemberSessionServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TeamMemberSessionServiceClient create(Ref ref) {
    return teamMemberSessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamMemberSessionServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamMemberSessionServiceClient>(
        value,
      ),
    );
  }
}

String _$teamMemberSessionServiceHash() =>
    r'68f85afad038bd1ffd2b6a773c675ab958746c0b';

@ProviderFor(teamMemberSessionsStream)
final teamMemberSessionsStreamProvider = TeamMemberSessionsStreamProvider._();

final class TeamMemberSessionsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamTeamMemberSessionsResponse>,
          StreamTeamMemberSessionsResponse,
          Stream<StreamTeamMemberSessionsResponse>
        >
    with
        $FutureModifier<StreamTeamMemberSessionsResponse>,
        $StreamProvider<StreamTeamMemberSessionsResponse> {
  TeamMemberSessionsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberSessionsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberSessionsStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamTeamMemberSessionsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamTeamMemberSessionsResponse> create(Ref ref) {
    return teamMemberSessionsStream(ref);
  }
}

String _$teamMemberSessionsStreamHash() =>
    r'07e73983f07c956fc248416f2b037e46fb2e8bfe';

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
    r'42d6262fc87ca339197350edb75cc14d7cd313d8';

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
