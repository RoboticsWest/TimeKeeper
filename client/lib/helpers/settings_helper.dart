import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/utils/grpc_result.dart';

/// Fetches current settings, lets the caller override specific fields, then
/// sends the full update. This avoids every call site having to manually copy
/// all 18 fields to prevent resetting unrelated settings.
Future<GrpcResult<UpdateSettingsResponse>> updateSettings(
  SettingsServiceClient client,
  void Function(UpdateSettingsRequest req) applyChanges,
) async {
  final current = await callGrpcEndpoint(
    () => client.getSettings(GetSettingsRequest()),
  );

  if (current is! GrpcSuccess<GetSettingsResponse>) {
    return GrpcFailure(
      userMessage: current is GrpcFailure
          ? (current as GrpcFailure).userMessage
          : 'Failed to fetch current settings',
    );
  }

  final s = current.data.settings;
  final req = UpdateSettingsRequest(
    nextSessionThresholdSecs: s.nextSessionThresholdSecs,
    timezone: s.timezone,
    discordEnabled: s.discordEnabled,
    discordBotToken: s.discordBotToken,
    discordGuildId: s.discordGuildId,
    discordChannelId: s.discordChannelId,
    discordSelfLinkEnabled: s.discordSelfLinkEnabled,
    discordNameSyncEnabled: s.discordNameSyncEnabled,
    discordStartReminderMins: s.discordStartReminderMins,
    discordEndReminderMins: s.discordEndReminderMins,
    discordStartReminderMessage: s.discordStartReminderMessage,
    discordEndReminderMessage: s.discordEndReminderMessage,
    discordOvertimeDmEnabled: s.discordOvertimeDmEnabled,
    discordOvertimeDmMins: s.discordOvertimeDmMins,
    discordOvertimeDmMessage: s.discordOvertimeDmMessage,
    discordAutoCheckoutDmEnabled: s.discordAutoCheckoutDmEnabled,
    discordAutoCheckoutDmMessage: s.discordAutoCheckoutDmMessage,
    discordCheckoutEnabled: s.discordCheckoutEnabled,
    primaryColor: s.primaryColor,
    secondaryColor: s.secondaryColor,
  );

  applyChanges(req);

  return await callGrpcEndpoint(() => client.updateSettings(req));
}
