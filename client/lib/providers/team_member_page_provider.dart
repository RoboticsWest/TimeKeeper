import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';
import 'package:time_keeper/providers/team_member_provider.dart';

part 'team_member_page_provider.g.dart';

const _teamMemberFields = 'id firstName lastName memberType displayName mobileNumber discordId quickPin';

const _teamMemberPageQuery =
    '''
  query TeamMemberPage(\$filter: TeamMemberFilterInput, \$offset: Int, \$limit: Int) {
    teamMemberPage(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_teamMemberFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// Whether a member has a linked Discord account.
enum DiscordLinkFilter { all, linked, unlinked }

/// Team member list filters, mirrored onto `TeamMemberFilterInput` on the server.
class TeamMemberFilterState {
  /// Case-insensitive match over first, last and display name.
  final String search;

  /// Empty means every type; otherwise "student" / "mentor".
  final List<String> memberTypes;

  final DiscordLinkFilter discord;

  const TeamMemberFilterState({this.search = '', this.memberTypes = const [], this.discord = DiscordLinkFilter.all});

  bool get isEmpty => search.trim().isEmpty && memberTypes.isEmpty && discord == DiscordLinkFilter.all;

  Map<String, dynamic>? toServerFilter() {
    final filter = <String, dynamic>{
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (memberTypes.isNotEmpty) 'memberTypes': memberTypes,
      if (discord == DiscordLinkFilter.linked) 'hasDiscord': true,
      if (discord == DiscordLinkFilter.unlinked) 'hasDiscord': false,
    };
    return filter.isEmpty ? null : filter;
  }
}

/// A paged, filtered slice of the roster, ordered by name.
///
/// The roster can run to thousands after CSV imports; filtering and paging happen in SQL so the
/// cost tracks the page rather than the table.
@Riverpod(keepAlive: true)
class TeamMemberPage extends _$TeamMemberPage with PagedAsyncNotifier<TeamMember> {
  TeamMemberFilterState _filter = const TeamMemberFilterState();

  @override
  Future<PagedResult<TeamMember>> build() async {
    ref.watch(timeKeeperGraphQLClientProvider);
    ref.listen(teamMemberChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<TeamMember>> fetch(int offset, int pageSize) {
    return fetchPagedPage<TeamMember>(
      ref: ref,
      document: _teamMemberPageQuery,
      rootField: 'teamMemberPage',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: TeamMember.fromJson,
    ).then(
      (result) =>
          result ?? const PagedResult<TeamMember>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(TeamMemberFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
