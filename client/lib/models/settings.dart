class Settings {
  final int nextSessionThresholdSecs;
  final String discordBotToken;
  final String discordGuildId;
  final String discordAnnouncementChannelId;
  final String discordNotificationChannelId;
  final bool discordSelfLinkEnabled;
  final bool discordNameSyncEnabled;
  final int discordStartReminderMins;
  final int discordEndReminderMins;
  final String discordStartReminderMessage;
  final String discordEndReminderMessage;
  final bool discordOvertimeDmEnabled;
  final int discordOvertimeDmMins;
  final String discordOvertimeDmMessage;
  final bool discordAutoCheckoutDmEnabled;
  final String discordAutoCheckoutDmMessage;
  final bool discordCheckoutEnabled;
  final bool discordEnabled;
  final String timezone;
  final bool leaderboardShowOvertime;
  final List<String> leaderboardMemberTypes;
  final bool discordRsvpReactionsEnabled;
  final bool discordAutoDeleteStartReminder;
  final bool discordAutoDeleteEndReminder;
  final bool quickPinEnabled;

  Settings({
    required this.nextSessionThresholdSecs,
    required this.discordBotToken,
    required this.discordGuildId,
    required this.discordAnnouncementChannelId,
    required this.discordNotificationChannelId,
    required this.discordSelfLinkEnabled,
    required this.discordNameSyncEnabled,
    required this.discordStartReminderMins,
    required this.discordEndReminderMins,
    required this.discordStartReminderMessage,
    required this.discordEndReminderMessage,
    required this.discordOvertimeDmEnabled,
    required this.discordOvertimeDmMins,
    required this.discordOvertimeDmMessage,
    required this.discordAutoCheckoutDmEnabled,
    required this.discordAutoCheckoutDmMessage,
    required this.discordCheckoutEnabled,
    required this.discordEnabled,
    required this.timezone,
    required this.leaderboardShowOvertime,
    required this.leaderboardMemberTypes,
    required this.discordRsvpReactionsEnabled,
    required this.discordAutoDeleteStartReminder,
    required this.discordAutoDeleteEndReminder,
    required this.quickPinEnabled,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      nextSessionThresholdSecs: json['nextSessionThresholdSecs'] as int,
      discordBotToken: json['discordBotToken'] as String,
      discordGuildId: json['discordGuildId'] as String,
      discordAnnouncementChannelId: json['discordAnnouncementChannelId'] as String,
      discordNotificationChannelId: json['discordNotificationChannelId'] as String,
      discordSelfLinkEnabled: json['discordSelfLinkEnabled'] as bool,
      discordNameSyncEnabled: json['discordNameSyncEnabled'] as bool,
      discordStartReminderMins: json['discordStartReminderMins'] as int,
      discordEndReminderMins: json['discordEndReminderMins'] as int,
      discordStartReminderMessage: json['discordStartReminderMessage'] as String,
      discordEndReminderMessage: json['discordEndReminderMessage'] as String,
      discordOvertimeDmEnabled: json['discordOvertimeDmEnabled'] as bool,
      discordOvertimeDmMins: json['discordOvertimeDmMins'] as int,
      discordOvertimeDmMessage: json['discordOvertimeDmMessage'] as String,
      discordAutoCheckoutDmEnabled: json['discordAutoCheckoutDmEnabled'] as bool,
      discordAutoCheckoutDmMessage: json['discordAutoCheckoutDmMessage'] as String,
      discordCheckoutEnabled: json['discordCheckoutEnabled'] as bool,
      discordEnabled: json['discordEnabled'] as bool,
      timezone: json['timezone'] as String,
      leaderboardShowOvertime: json['leaderboardShowOvertime'] as bool,
      leaderboardMemberTypes: (json['leaderboardMemberTypes'] as List<dynamic>).cast<String>(),
      discordRsvpReactionsEnabled: json['discordRsvpReactionsEnabled'] as bool,
      discordAutoDeleteStartReminder: json['discordAutoDeleteStartReminder'] as bool,
      discordAutoDeleteEndReminder: json['discordAutoDeleteEndReminder'] as bool,
      quickPinEnabled: json['quickPinEnabled'] as bool,
    );
  }
}

class DiscordRole {
  final String id;
  final String name;

  DiscordRole({required this.id, required this.name});

  factory DiscordRole.fromJson(Map<String, dynamic> json) {
    return DiscordRole(id: json['id'] as String, name: json['name'] as String);
  }
}

class ImportDiscordMembersResult {
  final int imported;
  final int linked;
  final int alreadyLinked;

  ImportDiscordMembersResult({required this.imported, required this.linked, required this.alreadyLinked});

  factory ImportDiscordMembersResult.fromJson(Map<String, dynamic> json) {
    return ImportDiscordMembersResult(
      imported: json['imported'] as int,
      linked: json['linked'] as int,
      alreadyLinked: json['alreadyLinked'] as int,
    );
  }
}
