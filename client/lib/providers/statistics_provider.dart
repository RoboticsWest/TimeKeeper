import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/leaderboard.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';

part 'statistics_provider.g.dart';

const _leaderboardQuery = r'''
  query Leaderboard {
    leaderboard {
      teamMemberId
      teamMember { id firstName lastName memberType displayName mobileNumber discordUsername }
      activeSession { regularSecs overtimeSecs }
      thisWeek { regularSecs overtimeSecs }
      allTime { regularSecs overtimeSecs }
      totalSecs
    }
  }
''';

@riverpod
Future<List<LeaderboardEntry>> leaderboard(Ref ref) async {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_leaderboardQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return [];
  return (result.data!['leaderboard'] as List<dynamic>)
      .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}
