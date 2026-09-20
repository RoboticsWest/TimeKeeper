// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A paged, filtered slice of the roster, ordered by name.
///
/// The roster can run to thousands after CSV imports; filtering and paging happen in SQL so the
/// cost tracks the page rather than the table.

@ProviderFor(TeamMemberPage)
final teamMemberPageProvider = TeamMemberPageProvider._();

/// A paged, filtered slice of the roster, ordered by name.
///
/// The roster can run to thousands after CSV imports; filtering and paging happen in SQL so the
/// cost tracks the page rather than the table.
final class TeamMemberPageProvider extends $AsyncNotifierProvider<TeamMemberPage, PagedResult<TeamMember>> {
  /// A paged, filtered slice of the roster, ordered by name.
  ///
  /// The roster can run to thousands after CSV imports; filtering and paging happen in SQL so the
  /// cost tracks the page rather than the table.
  TeamMemberPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMemberPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMemberPageHash();

  @$internal
  @override
  TeamMemberPage create() => TeamMemberPage();
}

String _$teamMemberPageHash() => r'8f241fd1c8959ca3c5ab163bdd8425f809ed419b';

/// A paged, filtered slice of the roster, ordered by name.
///
/// The roster can run to thousands after CSV imports; filtering and paging happen in SQL so the
/// cost tracks the page rather than the table.

abstract class _$TeamMemberPage extends $AsyncNotifier<PagedResult<TeamMember>> {
  FutureOr<PagedResult<TeamMember>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedResult<TeamMember>>, PagedResult<TeamMember>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedResult<TeamMember>>, PagedResult<TeamMember>>,
              AsyncValue<PagedResult<TeamMember>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
