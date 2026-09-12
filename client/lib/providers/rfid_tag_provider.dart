import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/rfid_tag.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'rfid_tag_provider.g.dart';

const _rfidTagFields = 'id teamMemberId tag';

const _rfidTagsQuery = '''
  query RfidTags {
    rfidTags { $_rfidTagFields }
  }
''';

const _rfidTagChangesSubscription = '''
  subscription RfidTagChanges {
    rfidTagChanges { operation id data { $_rfidTagFields } }
  }
''';

const _createRfidTagMutation = '''
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
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_rfidTagsQuery), fetchPolicy: FetchPolicy.noCache));
    if (result.hasException || result.data == null) return;

    final items = (result.data!['rfidTags'] as List<dynamic>).map((e) => RfidTag.fromJson(e as Map<String, dynamic>)).toList();
    state = {for (final item in items) item.id: item};
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
  ref.listen(rfidTagChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(rfidTagsProvider.notifier).applyChange(change);
    });
  });
}

@Riverpod(keepAlive: true)
Map<String, RfidTag> rfidTagsByMember(Ref ref, String memberId) {
  final tags = ref.watch(rfidTagsProvider);
  return Map.fromEntries(tags.entries.where((entry) => entry.value.teamMemberId == memberId));
}
