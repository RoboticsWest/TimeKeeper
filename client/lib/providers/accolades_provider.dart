import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/accolades.dart';
import 'package:time_keeper/providers/aggregate_revision_provider.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';

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
      achievements { key emoji name how hidden earned holders totalMembers rarityPct }
    }
  }
''';

/// Every member's title and achievement collection, most decorated first.
///
/// Like the leaderboard this is an aggregate rather than an id-keyed collection, so it cannot be
/// patched from a change delta — any attendance or roster change invalidates the whole thing.
/// [aggregateRevisionProvider] is what makes a badge appear the moment somebody earns it rather
/// than whenever the page next happens to be rebuilt; see the note there for why watching the
/// collections directly instead cost four recomputations per visit.///
/// `keepAlive` so navigating away and back does not recompute it. That is safe here precisely
/// because [aggregateRevisionProvider] advances only when the data behind it actually changes —
/// the result is retained, not cached-and-hoped-for, and a real change still invalidates it within
/// the debounce window.
@Riverpod(keepAlive: true)
Future<List<MemberAccolades>> memberAccolades(Ref ref) async {
  ref.watch(aggregateRevisionProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_accoladesQuery), fetchPolicy: FetchPolicy.noCache));
  // Thrown rather than returned as an empty list: the view renders "no team members yet" for an
  // empty roster, and a failed query is a different thing that deserves to say so.
  if (result.hasException) throw result.exception!;
  if (result.data == null) throw Exception('The server returned no achievements data');
  return (result.data!['memberAccolades'] as List<dynamic>)
      .map((e) => MemberAccolades.fromJson(e as Map<String, dynamic>))
      .toList();
}
