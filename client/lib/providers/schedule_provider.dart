import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'schedule_provider.g.dart';

const _uploadScheduleCsvMutation = r'''
  mutation UploadScheduleCsv($csvData: String!) {
    uploadScheduleCsv(csvData: $csvData)
  }
''';

const _uploadScheduleIcsMutation = r'''
  mutation UploadScheduleIcs($icsData: String!) {
    uploadScheduleIcs(icsData: $icsData)
  }
''';

@Riverpod(keepAlive: true)
class ScheduleService extends _$ScheduleService {
  @override
  void build() {}

  Future<ApiCallResult> uploadCsv(String csvData) => _mutate(_uploadScheduleCsvMutation, {'csvData': csvData});

  Future<ApiCallResult> uploadIcs(String icsData) => _mutate(_uploadScheduleIcsMutation, {'icsData': icsData});

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
