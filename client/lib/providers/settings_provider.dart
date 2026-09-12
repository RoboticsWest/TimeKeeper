import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/settings.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'settings_provider.g.dart';

const _settingsFields =
    'nextSessionThresholdSecs discordBotToken discordGuildId discordAnnouncementChannelId '
    'discordNotificationChannelId discordSelfLinkEnabled discordNameSyncEnabled discordStartReminderMins '
    'discordEndReminderMins discordStartReminderMessage discordEndReminderMessage discordOvertimeDmEnabled '
    'discordOvertimeDmMins discordOvertimeDmMessage discordAutoCheckoutDmEnabled discordAutoCheckoutDmMessage '
    'discordCheckoutEnabled discordEnabled timezone leaderboardShowOvertime '
    'leaderboardMemberTypes discordRsvpReactionsEnabled discordAutoDeleteStartReminder discordAutoDeleteEndReminder';

const _settingsQuery = '''
  query GetSettings {
    settings { $_settingsFields }
  }
''';

const _logoQuery = r'''
  query GetLogo {
    logo
  }
''';

const _discordRolesQuery = r'''
  query DiscordRoles {
    discordRoles { id name }
  }
''';

@riverpod
Future<Settings?> settingsQuery(Ref ref) async {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_settingsQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return null;
  return Settings.fromJson(result.data!['settings'] as Map<String, dynamic>);
}

@riverpod
Future<String?> logoQuery(Ref ref) async {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_logoQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return null;
  return result.data!['logo'] as String?;
}

@riverpod
Future<List<DiscordRole>> discordRolesQuery(Ref ref) async {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_discordRolesQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return [];
  return (result.data!['discordRoles'] as List<dynamic>)
      .map((e) => DiscordRole.fromJson(e as Map<String, dynamic>))
      .toList();
}

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  @override
  void build() {}

  Future<ApiCallResult> updateGeneral({int? nextSessionThresholdSecs, String? timezone}) => _mutate(
    r'''
      mutation UpdateGeneralSettings($nextSessionThresholdSecs: Int, $timezone: String) {
        updateGeneralSettings(nextSessionThresholdSecs: $nextSessionThresholdSecs, timezone: $timezone)
      }
    ''',
    {'nextSessionThresholdSecs': nextSessionThresholdSecs, 'timezone': timezone},
  );

  Future<ApiCallResult> updateLeaderboard({bool? showOvertime, required List<String> memberTypes}) => _mutate(
    r'''
      mutation UpdateLeaderboardSettings($leaderboardShowOvertime: Boolean, $leaderboardMemberTypes: [String!]!) {
        updateLeaderboardSettings(leaderboardShowOvertime: $leaderboardShowOvertime, leaderboardMemberTypes: $leaderboardMemberTypes)
      }
    ''',
    {'leaderboardShowOvertime': showOvertime, 'leaderboardMemberTypes': memberTypes},
  );

  Future<ApiCallResult> updateDiscordCore({
    bool? discordEnabled,
    String? discordBotToken,
    String? discordGuildId,
    String? discordAnnouncementChannelId,
    String? discordNotificationChannelId,
  }) => _mutate(
    r'''
      mutation UpdateDiscordCoreSettings($discordEnabled: Boolean, $discordBotToken: String, $discordGuildId: String, $discordAnnouncementChannelId: String, $discordNotificationChannelId: String) {
        updateDiscordCoreSettings(discordEnabled: $discordEnabled, discordBotToken: $discordBotToken, discordGuildId: $discordGuildId, discordAnnouncementChannelId: $discordAnnouncementChannelId, discordNotificationChannelId: $discordNotificationChannelId)
      }
    ''',
    {
      'discordEnabled': discordEnabled,
      'discordBotToken': discordBotToken,
      'discordGuildId': discordGuildId,
      'discordAnnouncementChannelId': discordAnnouncementChannelId,
      'discordNotificationChannelId': discordNotificationChannelId,
    },
  );

  Future<ApiCallResult> updateDiscordReminder({
    int? discordStartReminderMins,
    int? discordEndReminderMins,
    String? discordStartReminderMessage,
    String? discordEndReminderMessage,
    bool? discordAutoDeleteStartReminder,
    bool? discordAutoDeleteEndReminder,
  }) => _mutate(
    r'''
      mutation UpdateDiscordReminderSettings($discordStartReminderMins: Int, $discordEndReminderMins: Int, $discordStartReminderMessage: String, $discordEndReminderMessage: String, $discordAutoDeleteStartReminder: Boolean, $discordAutoDeleteEndReminder: Boolean) {
        updateDiscordReminderSettings(discordStartReminderMins: $discordStartReminderMins, discordEndReminderMins: $discordEndReminderMins, discordStartReminderMessage: $discordStartReminderMessage, discordEndReminderMessage: $discordEndReminderMessage, discordAutoDeleteStartReminder: $discordAutoDeleteStartReminder, discordAutoDeleteEndReminder: $discordAutoDeleteEndReminder)
      }
    ''',
    {
      'discordStartReminderMins': discordStartReminderMins,
      'discordEndReminderMins': discordEndReminderMins,
      'discordStartReminderMessage': discordStartReminderMessage,
      'discordEndReminderMessage': discordEndReminderMessage,
      'discordAutoDeleteStartReminder': discordAutoDeleteStartReminder,
      'discordAutoDeleteEndReminder': discordAutoDeleteEndReminder,
    },
  );

  Future<ApiCallResult> updateDiscordBehavior({
    bool? discordSelfLinkEnabled,
    bool? discordNameSyncEnabled,
    bool? discordOvertimeDmEnabled,
    int? discordOvertimeDmMins,
    String? discordOvertimeDmMessage,
    bool? discordAutoCheckoutDmEnabled,
    String? discordAutoCheckoutDmMessage,
    bool? discordCheckoutEnabled,
    bool? discordRsvpReactionsEnabled,
  }) => _mutate(
    r'''
      mutation UpdateDiscordBehaviorSettings($discordSelfLinkEnabled: Boolean, $discordNameSyncEnabled: Boolean, $discordOvertimeDmEnabled: Boolean, $discordOvertimeDmMins: Int, $discordOvertimeDmMessage: String, $discordAutoCheckoutDmEnabled: Boolean, $discordAutoCheckoutDmMessage: String, $discordCheckoutEnabled: Boolean, $discordRsvpReactionsEnabled: Boolean) {
        updateDiscordBehaviorSettings(discordSelfLinkEnabled: $discordSelfLinkEnabled, discordNameSyncEnabled: $discordNameSyncEnabled, discordOvertimeDmEnabled: $discordOvertimeDmEnabled, discordOvertimeDmMins: $discordOvertimeDmMins, discordOvertimeDmMessage: $discordOvertimeDmMessage, discordAutoCheckoutDmEnabled: $discordAutoCheckoutDmEnabled, discordAutoCheckoutDmMessage: $discordAutoCheckoutDmMessage, discordCheckoutEnabled: $discordCheckoutEnabled, discordRsvpReactionsEnabled: $discordRsvpReactionsEnabled)
      }
    ''',
    {
      'discordSelfLinkEnabled': discordSelfLinkEnabled,
      'discordNameSyncEnabled': discordNameSyncEnabled,
      'discordOvertimeDmEnabled': discordOvertimeDmEnabled,
      'discordOvertimeDmMins': discordOvertimeDmMins,
      'discordOvertimeDmMessage': discordOvertimeDmMessage,
      'discordAutoCheckoutDmEnabled': discordAutoCheckoutDmEnabled,
      'discordAutoCheckoutDmMessage': discordAutoCheckoutDmMessage,
      'discordCheckoutEnabled': discordCheckoutEnabled,
      'discordRsvpReactionsEnabled': discordRsvpReactionsEnabled,
    },
  );

  /// [logoBase64] is base64-encoded image bytes.
  Future<ApiCallResult> uploadLogo(String logoBase64) => _mutate(
    r'''
      mutation UploadLogo($logo: String!) {
        uploadLogo(logo: $logo)
      }
    ''',
    {'logo': logoBase64},
  );

  Future<ApiCallResult> purgeDatabase() => _mutate(r'''
      mutation PurgeDatabase {
        purgeDatabase
      }
    ''', {});

  Future<ApiResult<ImportDiscordMembersResult>> importDiscordMembers(String roleId, String memberType) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation ImportDiscordMembers($roleId: String!, $memberType: String!) {
            importDiscordMembers(roleId: $roleId, memberType: $memberType) { imported linked alreadyLinked }
          }
        '''),
        variables: {'roleId': roleId, 'memberType': memberType},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiFailure(userMessage: message);
    }
    return ApiSuccess(
      ImportDiscordMembersResult.fromJson(result.data!['importDiscordMembers'] as Map<String, dynamic>),
    );
  }

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
