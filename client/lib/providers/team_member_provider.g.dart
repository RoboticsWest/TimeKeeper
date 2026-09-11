// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamMemberChanges)
final teamMemberChangesProvider = TeamMemberChangesProvider._();

final class TeamMemberChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<TeamMember>>,
          ChangeEvent<TeamMember>,
          Stream<ChangeEvent<TeamMember>>
        >
    with
        $FutureModifier<ChangeEvent<TeamMember>>,
        $StreamProvider<ChangeEvent<TeamMember>> {
  TeamMemberChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<TeamMember>> create(Ref ref) {
    return teamMemberChanges(ref);
  }
}

String _$teamMemberChangesHash() => r'5aae68de4ba20618ad8a9eebd81844f72a62297e';

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

String _$teamMembersHash() => r'2fb6d4e0609e8b8c8bb25f8dfdd8c8aa67017a5d';

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

@ProviderFor(teamMembersSync)
final teamMembersSyncProvider = TeamMembersSyncProvider._();

final class TeamMembersSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  TeamMembersSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMembersSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMembersSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return teamMembersSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$teamMembersSyncHash() => r'6359aecf8e33b5b617f75e5a24397a1ecd5bf717';

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
    r'446391af205ad0b6eac2fc93dbb9e1c002179043';

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

String _$mentorTeamMembersHash() => r'8f7b59ce2d225850bd8306e1a9a115a88e417f2d';
