// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamMemberService)
const teamMemberServiceProvider = TeamMemberServiceProvider._();

final class TeamMemberServiceProvider
    extends
        $FunctionalProvider<
          TeamMemberServiceClient,
          TeamMemberServiceClient,
          TeamMemberServiceClient
        >
    with $Provider<TeamMemberServiceClient> {
  const TeamMemberServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberServiceHash();

  @$internal
  @override
  $ProviderElement<TeamMemberServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TeamMemberServiceClient create(Ref ref) {
    return teamMemberService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamMemberServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamMemberServiceClient>(value),
    );
  }
}

String _$teamMemberServiceHash() => r'48972679a448b0913d9af3390c07705fdd11bc77';

@ProviderFor(teamMembersStream)
const teamMembersStreamProvider = TeamMembersStreamProvider._();

final class TeamMembersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamTeamMembersResponse>,
          StreamTeamMembersResponse,
          Stream<StreamTeamMembersResponse>
        >
    with
        $FutureModifier<StreamTeamMembersResponse>,
        $StreamProvider<StreamTeamMembersResponse> {
  const TeamMembersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMembersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMembersStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamTeamMembersResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamTeamMembersResponse> create(Ref ref) {
    return teamMembersStream(ref);
  }
}

String _$teamMembersStreamHash() => r'e39aee18a610b3bc588fae24dfc7b50de8e75228';

@ProviderFor(TeamMembers)
const teamMembersProvider = TeamMembersProvider._();

final class TeamMembersProvider
    extends $NotifierProvider<TeamMembers, Map<String, TeamMember>> {
  const TeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMembersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMembersHash();

  @$internal
  @override
  TeamMembers create() => TeamMembers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TeamMember> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TeamMember>>(value),
    );
  }
}

String _$teamMembersHash() => r'2567ddff27648f414e133678e4e6b8622ca5b830';

abstract class _$TeamMembers extends $Notifier<Map<String, TeamMember>> {
  Map<String, TeamMember> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, TeamMember>, Map<String, TeamMember>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TeamMember>, Map<String, TeamMember>>,
              Map<String, TeamMember>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(studentTeamMembers)
const studentTeamMembersProvider = StudentTeamMembersProvider._();

final class StudentTeamMembersProvider
    extends
        $FunctionalProvider<
          Map<String, TeamMember>,
          Map<String, TeamMember>,
          Map<String, TeamMember>
        >
    with $Provider<Map<String, TeamMember>> {
  const StudentTeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentTeamMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentTeamMembersHash();

  @$internal
  @override
  $ProviderElement<Map<String, TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, TeamMember> create(Ref ref) {
    return studentTeamMembers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TeamMember> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TeamMember>>(value),
    );
  }
}

String _$studentTeamMembersHash() =>
    r'195cd4e0554541f1ec5efe93bf8e05339364b91e';

@ProviderFor(mentorTeamMembers)
const mentorTeamMembersProvider = MentorTeamMembersProvider._();

final class MentorTeamMembersProvider
    extends
        $FunctionalProvider<
          Map<String, TeamMember>,
          Map<String, TeamMember>,
          Map<String, TeamMember>
        >
    with $Provider<Map<String, TeamMember>> {
  const MentorTeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentorTeamMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mentorTeamMembersHash();

  @$internal
  @override
  $ProviderElement<Map<String, TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, TeamMember> create(Ref ref) {
    return mentorTeamMembers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TeamMember> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TeamMember>>(value),
    );
  }
}

String _$mentorTeamMembersHash() => r'60a9fa6af945f71d9e3d53043ded6353b1eae4e8';
