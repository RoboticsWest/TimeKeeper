import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/rfid_tag.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'rfid_tag_provider.g.dart';

const _rfidTagFields = 'id teamMemberId tag';

const _rfidTagsQuery =
    '''
  query RfidTags {
    rfidTags { $_rfidTagFields }
  }
''';

const _rfidTagChangesSubscription =
    '''
  subscription RfidTagChanges {
    rfidTagChanges { operation id data { $_rfidTagFields } }
  }
''';

const _createRfidTagMutation =
    '''
  mutation CreateRfidTag(\$teamMemberId: UUID!, \$tag: String!) {
    createRfidTag(teamMemberId: \$teamMemberId, tag: \$tag) { $_rfidTagFields }
  }
''';

const _deleteRfidTagMutation = r'''
  mutation DeleteRfidTag($id: UUID!) {
    deleteRfidTag(id: $id)
  }
''';

const _deleteRfidTagsByMemberMutation = r'''
  mutation DeleteRfidTagsByMember($teamMemberId: UUID!) {
    deleteRfidTagsByMember(teamMemberId: $teamMemberId)
  }
''';

@riverpod
Stream<ChangeEvent<RfidTag>> rfidTagChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_rfidTagChangesSubscription)))
      .where((result) => result.data != null)
      .map((result) => ChangeEvent.fromJson(result.data!['rfidTagChanges'] as Map<String, dynamic>, RfidTag.fromJson));
}

@Riverpod(keepAlive: true)
class RfidTags extends _$RfidTags {
  @override
  Map<String, RfidTag> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<RfidTag>(
      ref: ref,
      document: _rfidTagsQuery,
      rootField: 'rfidTags',
      fromJson: RfidTag.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<RfidTag> change) {
    state = applyChangeToMap(state, change);
  }

  Future<ApiCallResult> create(String teamMemberId, String tag) =>
      _mutate(_createRfidTagMutation, {'teamMemberId': teamMemberId, 'tag': tag});

  Future<ApiCallResult> delete(String id) => _mutate(_deleteRfidTagMutation, {'id': id});

  Future<ApiCallResult> deleteByMember(String teamMemberId) =>
      _mutate(_deleteRfidTagsByMemberMutation, {'teamMemberId': teamMemberId});

  Future<ApiCallResult> _mutate(String document, Map<String, dynamic> variables) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(document: gql(document), variables: variables, fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiCallResult(success: false, message: message);
    }
    return const ApiCallResult(success: true);
  }
}

@Riverpod(keepAlive: true)
void rfidTagsSync(Ref ref) {
  ref.listen(
    rfidTagChangesProvider,
    changeListener<RfidTag>(
      apply: (change) => ref.read(rfidTagsProvider.notifier).applyChange(change),
      refresh: () => ref.read(rfidTagsProvider.notifier).refresh(),
    ),
  );
}

@Riverpod(keepAlive: true)
Map<String, RfidTag> rfidTagsByMember(Ref ref, String memberId) {
  final tags = ref.watch(rfidTagsProvider);
  return Map.fromEntries(tags.entries.where((entry) => entry.value.teamMemberId == memberId));
}
