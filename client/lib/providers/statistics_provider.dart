import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/leaderboard.dart';
import 'package:time_keeper/providers/aggregate_revision_provider.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';

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
/// any change to its inputs invalidates the whole thing. [aggregateRevisionProvider] re-runs the
/// query when they change; without it the leaderboard silently showed whatever was true when the
/// page first loaded, which is the same "the UI doesn't update" failure as everywhere else.///
/// `keepAlive` so navigating away and back does not recompute it. That is safe here precisely
/// because [aggregateRevisionProvider] advances only when the data behind it actually changes —
/// the result is retained, not cached-and-hoped-for, and a real change still invalidates it within
/// the debounce window.
@Riverpod(keepAlive: true)
Future<List<LeaderboardEntry>> leaderboard(Ref ref) async {
  ref.watch(aggregateRevisionProvider);
  // The leaderboard's shape (overtime shown, which member types count) is a setting.
  ref.watch(settingsQueryProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_leaderboardQuery), fetchPolicy: FetchPolicy.noCache));
  // Thrown rather than returned as an empty list: "nobody has any hours yet" and "the leaderboard
  // could not be loaded" are different answers and the view says different things about them.
  if (result.hasException) throw result.exception!;
  if (result.data == null) throw Exception('The server returned no leaderboard data');
  return (result.data!['leaderboard'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}
