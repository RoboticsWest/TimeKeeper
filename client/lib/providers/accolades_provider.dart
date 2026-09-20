import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/accolades.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';

part 'accolades_provider.g.dart';

const _accoladesQuery = r'''
  query MemberAccolades {
    memberAccolades {
      teamMemberId
      name
      memberType
      title
      titleReason
      earnedCount
      totalCount
      achievements { key emoji name how hidden earned }
    }
  }
''';

/// Every member's title and achievement collection, most decorated first.
///
/// Like the leaderboard this is an aggregate rather than an id-keyed collection, so it cannot be
/// patched from a change delta — any attendance or roster change invalidates the whole thing.
/// Watching those collections is what makes a badge appear the moment somebody earns it rather
/// than whenever the page next happens to be rebuilt.
@riverpod
Future<List<MemberAccolades>> memberAccolades(Ref ref) async {
  ref.watch(sessionsSyncProvider);
  ref.watch(teamMemberSessionsSyncProvider);
  ref.watch(teamMembersSyncProvider);
  ref.watch(sessionsProvider);
  ref.watch(teamMemberSessionsProvider);
  ref.watch(teamMembersProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_accoladesQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return [];
  return (result.data!['memberAccolades'] as List<dynamic>)
      .map((e) => MemberAccolades.fromJson(e as Map<String, dynamic>))
      .toList();
}
