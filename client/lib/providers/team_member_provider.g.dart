// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamMemberService)
final teamMemberServiceProvider = TeamMemberServiceProvider._();

final class TeamMemberServiceProvider
    extends
        $FunctionalProvider<
          TeamMemberServiceClient,
          TeamMemberServiceClient,
          TeamMemberServiceClient
        >
    with $Provider<TeamMemberServiceClient> {
  TeamMemberServiceProvider._()
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
final teamMembersStreamProvider = TeamMembersStreamProvider._();

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
  TeamMembersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMembersStreamProvider',
        isAutoDispose: false,
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

String _$teamMembersStreamHash() => r'849d90bf38645aae20189918c8f2280e2f0b7759';

@ProviderFor(TeamMembers)
final teamMembersProvider = TeamMembersProvider._();

final class TeamMembersProvider
    extends $NotifierProvider<TeamMembers, Map<String, TeamMember>> {
  TeamMembersProvider._()
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

String _$teamMembersHash() => r'70ad01e4e81dce9053f8fb2480eace8dceddaed1';

abstract class _$TeamMembers extends $Notifier<Map<String, TeamMember>> {
  Map<String, TeamMember> build();
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, build);
  }
}

@ProviderFor(studentTeamMembers)
final studentTeamMembersProvider = StudentTeamMembersProvider._();

final class StudentTeamMembersProvider
    extends
        $FunctionalProvider<
          Map<String, TeamMember>,
          Map<String, TeamMember>,
          Map<String, TeamMember>
        >
    with $Provider<Map<String, TeamMember>> {
  StudentTeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentTeamMembersProvider',
        isAutoDispose: false,
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
    r'b5f4bad9fcc8b430290ea1ba212df2de77d94f17';

@ProviderFor(mentorTeamMembers)
final mentorTeamMembersProvider = MentorTeamMembersProvider._();

final class MentorTeamMembersProvider
    extends
        $FunctionalProvider<
          Map<String, TeamMember>,
          Map<String, TeamMember>,
          Map<String, TeamMember>
        >
    with $Provider<Map<String, TeamMember>> {
  MentorTeamMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mentorTeamMembersProvider',
        isAutoDispose: false,
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

String _$mentorTeamMembersHash() => r'8d22e36a1b928df7955493ff033b95b0986340fe';
