import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/leaderboard.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';

part 'statistics_provider.g.dart';

const _leaderboardQuery = r'''
  query Leaderboard {
    leaderboard {
      teamMemberId
      teamMember { id firstName lastName memberType displayName mobileNumber discordId }
      activeSession { regularSecs overtimeSecs }
      thisWeek { regularSecs overtimeSecs }
      allTime { regularSecs overtimeSecs }
      totalSecs
    }
  }
''';

/// The leaderboard, recomputed server-side.
///
/// Unlike the id-keyed collections this cannot be patched from a delta — it is an aggregate, so
/// any change to its inputs invalidates the whole thing. Watching those collections re-runs the
/// query; without it the leaderboard silently showed whatever was true when the page first
/// loaded, which is the same "the UI doesn't update" failure as everywhere else.
@riverpod
Future<List<LeaderboardEntry>> leaderboard(Ref ref) async {
  ref.watch(sessionsSyncProvider);
  ref.watch(teamMemberSessionsSyncProvider);
  ref.watch(teamMembersSyncProvider);
  ref.watch(sessionsProvider);
  ref.watch(teamMemberSessionsProvider);
  ref.watch(teamMembersProvider);
  // The leaderboard's shape (overtime shown, which member types count) is a setting.
  ref.watch(settingsQueryProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_leaderboardQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return [];
  return (result.data!['leaderboard'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}
