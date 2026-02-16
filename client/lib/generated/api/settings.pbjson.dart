// This is a generated file - do not edit.
//
// Generated from api/settings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getSettingsRequestDescriptor instead')
const GetSettingsRequest$json = {
  '1': 'GetSettingsRequest',
};

/// Descriptor for `GetSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingsRequestDescriptor =
    $convert.base64Decode('ChJHZXRTZXR0aW5nc1JlcXVlc3Q=');

@$core.Deprecated('Use getSettingsResponseDescriptor instead')
const GetSettingsResponse$json = {
  '1': 'GetSettingsResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tk.db.Settings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSettingsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTZXR0aW5nc1Jlc3BvbnNlEisKCHNldHRpbmdzGAEgASgLMg8udGsuZGIuU2V0dGluZ3'
    'NSCHNldHRpbmdz');

@$core.Deprecated('Use updateGeneralSettingsRequestDescriptor instead')
const UpdateGeneralSettingsRequest$json = {
  '1': 'UpdateGeneralSettingsRequest',
  '2': [
    {
      '1': 'next_session_threshold_secs',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'nextSessionThresholdSecs',
      '17': true
    },
    {
      '1': 'timezone',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'timezone',
      '17': true
    },
  ],
  '8': [
    {'1': '_next_session_threshold_secs'},
    {'1': '_timezone'},
  ],
};

/// Descriptor for `UpdateGeneralSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGeneralSettingsRequestDescriptor = $convert.base64Decode(
    'ChxVcGRhdGVHZW5lcmFsU2V0dGluZ3NSZXF1ZXN0EkIKG25leHRfc2Vzc2lvbl90aHJlc2hvbG'
    'Rfc2VjcxgBIAEoA0gAUhhuZXh0U2Vzc2lvblRocmVzaG9sZFNlY3OIAQESHwoIdGltZXpvbmUY'
    'AiABKAlIAVIIdGltZXpvbmWIAQFCHgocX25leHRfc2Vzc2lvbl90aHJlc2hvbGRfc2Vjc0ILCg'
    'lfdGltZXpvbmU=');

@$core.Deprecated('Use updateGeneralSettingsResponseDescriptor instead')
const UpdateGeneralSettingsResponse$json = {
  '1': 'UpdateGeneralSettingsResponse',
};

/// Descriptor for `UpdateGeneralSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGeneralSettingsResponseDescriptor =
    $convert.base64Decode('Ch1VcGRhdGVHZW5lcmFsU2V0dGluZ3NSZXNwb25zZQ==');

@$core.Deprecated('Use updateBrandingSettingsRequestDescriptor instead')
const UpdateBrandingSettingsRequest$json = {
  '1': 'UpdateBrandingSettingsRequest',
  '2': [
    {
      '1': 'primary_color',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'primaryColor',
      '17': true
    },
    {
      '1': 'secondary_color',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'secondaryColor',
      '17': true
    },
  ],
  '8': [
    {'1': '_primary_color'},
    {'1': '_secondary_color'},
  ],
};

/// Descriptor for `UpdateBrandingSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateBrandingSettingsRequestDescriptor =
    $convert.base64Decode(
        'Ch1VcGRhdGVCcmFuZGluZ1NldHRpbmdzUmVxdWVzdBIoCg1wcmltYXJ5X2NvbG9yGAEgASgJSA'
        'BSDHByaW1hcnlDb2xvcogBARIsCg9zZWNvbmRhcnlfY29sb3IYAiABKAlIAVIOc2Vjb25kYXJ5'
        'Q29sb3KIAQFCEAoOX3ByaW1hcnlfY29sb3JCEgoQX3NlY29uZGFyeV9jb2xvcg==');

@$core.Deprecated('Use updateBrandingSettingsResponseDescriptor instead')
const UpdateBrandingSettingsResponse$json = {
  '1': 'UpdateBrandingSettingsResponse',
};

/// Descriptor for `UpdateBrandingSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateBrandingSettingsResponseDescriptor =
    $convert.base64Decode('Ch5VcGRhdGVCcmFuZGluZ1NldHRpbmdzUmVzcG9uc2U=');

@$core.Deprecated('Use uploadLogoRequestDescriptor instead')
const UploadLogoRequest$json = {
  '1': 'UploadLogoRequest',
  '2': [
    {'1': 'logo', '3': 1, '4': 1, '5': 12, '10': 'logo'},
  ],
};

/// Descriptor for `UploadLogoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadLogoRequestDescriptor = $convert
    .base64Decode('ChFVcGxvYWRMb2dvUmVxdWVzdBISCgRsb2dvGAEgASgMUgRsb2dv');

@$core.Deprecated('Use uploadLogoResponseDescriptor instead')
const UploadLogoResponse$json = {
  '1': 'UploadLogoResponse',
};

/// Descriptor for `UploadLogoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadLogoResponseDescriptor =
    $convert.base64Decode('ChJVcGxvYWRMb2dvUmVzcG9uc2U=');

@$core.Deprecated('Use getLogoRequestDescriptor instead')
const GetLogoRequest$json = {
  '1': 'GetLogoRequest',
};

/// Descriptor for `GetLogoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLogoRequestDescriptor =
    $convert.base64Decode('Cg5HZXRMb2dvUmVxdWVzdA==');

@$core.Deprecated('Use getLogoResponseDescriptor instead')
const GetLogoResponse$json = {
  '1': 'GetLogoResponse',
  '2': [
    {'1': 'logo', '3': 1, '4': 1, '5': 12, '10': 'logo'},
  ],
};

/// Descriptor for `GetLogoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLogoResponseDescriptor = $convert
    .base64Decode('Cg9HZXRMb2dvUmVzcG9uc2USEgoEbG9nbxgBIAEoDFIEbG9nbw==');

@$core.Deprecated('Use updateLeaderboardSettingsRequestDescriptor instead')
const UpdateLeaderboardSettingsRequest$json = {
  '1': 'UpdateLeaderboardSettingsRequest',
  '2': [
    {
      '1': 'leaderboard_show_overtime',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'leaderboardShowOvertime',
      '17': true
    },
    {
      '1': 'leaderboard_member_types',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.tk.db.TeamMemberType',
      '10': 'leaderboardMemberTypes'
    },
  ],
  '8': [
    {'1': '_leaderboard_show_overtime'},
  ],
};

/// Descriptor for `UpdateLeaderboardSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLeaderboardSettingsRequestDescriptor =
    $convert.base64Decode(
        'CiBVcGRhdGVMZWFkZXJib2FyZFNldHRpbmdzUmVxdWVzdBI/ChlsZWFkZXJib2FyZF9zaG93X2'
        '92ZXJ0aW1lGAEgASgISABSF2xlYWRlcmJvYXJkU2hvd092ZXJ0aW1liAEBEk8KGGxlYWRlcmJv'
        'YXJkX21lbWJlcl90eXBlcxgCIAMoDjIVLnRrLmRiLlRlYW1NZW1iZXJUeXBlUhZsZWFkZXJib2'
        'FyZE1lbWJlclR5cGVzQhwKGl9sZWFkZXJib2FyZF9zaG93X292ZXJ0aW1l');

@$core.Deprecated('Use updateLeaderboardSettingsResponseDescriptor instead')
const UpdateLeaderboardSettingsResponse$json = {
  '1': 'UpdateLeaderboardSettingsResponse',
};

/// Descriptor for `UpdateLeaderboardSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLeaderboardSettingsResponseDescriptor =
    $convert.base64Decode('CiFVcGRhdGVMZWFkZXJib2FyZFNldHRpbmdzUmVzcG9uc2U=');

@$core.Deprecated('Use updateDiscordCoreSettingsRequestDescriptor instead')
const UpdateDiscordCoreSettingsRequest$json = {
  '1': 'UpdateDiscordCoreSettingsRequest',
  '2': [
    {
      '1': 'discord_enabled',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'discordEnabled',
      '17': true
    },
    {
      '1': 'discord_bot_token',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'discordBotToken',
      '17': true
    },
    {
      '1': 'discord_guild_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'discordGuildId',
      '17': true
    },
    {
      '1': 'discord_announcement_channel_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'discordAnnouncementChannelId',
      '17': true
    },
    {
      '1': 'discord_notification_channel_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'discordNotificationChannelId',
      '17': true
    },
  ],
  '8': [
    {'1': '_discord_enabled'},
    {'1': '_discord_bot_token'},
    {'1': '_discord_guild_id'},
    {'1': '_discord_announcement_channel_id'},
    {'1': '_discord_notification_channel_id'},
  ],
};

/// Descriptor for `UpdateDiscordCoreSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordCoreSettingsRequestDescriptor = $convert.base64Decode(
    'CiBVcGRhdGVEaXNjb3JkQ29yZVNldHRpbmdzUmVxdWVzdBIsCg9kaXNjb3JkX2VuYWJsZWQYAS'
    'ABKAhIAFIOZGlzY29yZEVuYWJsZWSIAQESLwoRZGlzY29yZF9ib3RfdG9rZW4YAiABKAlIAVIP'
    'ZGlzY29yZEJvdFRva2VuiAEBEi0KEGRpc2NvcmRfZ3VpbGRfaWQYAyABKAlIAlIOZGlzY29yZE'
    'd1aWxkSWSIAQESSgofZGlzY29yZF9hbm5vdW5jZW1lbnRfY2hhbm5lbF9pZBgEIAEoCUgDUhxk'
    'aXNjb3JkQW5ub3VuY2VtZW50Q2hhbm5lbElkiAEBEkoKH2Rpc2NvcmRfbm90aWZpY2F0aW9uX2'
    'NoYW5uZWxfaWQYBSABKAlIBFIcZGlzY29yZE5vdGlmaWNhdGlvbkNoYW5uZWxJZIgBAUISChBf'
    'ZGlzY29yZF9lbmFibGVkQhQKEl9kaXNjb3JkX2JvdF90b2tlbkITChFfZGlzY29yZF9ndWlsZF'
    '9pZEIiCiBfZGlzY29yZF9hbm5vdW5jZW1lbnRfY2hhbm5lbF9pZEIiCiBfZGlzY29yZF9ub3Rp'
    'ZmljYXRpb25fY2hhbm5lbF9pZA==');

@$core.Deprecated('Use updateDiscordCoreSettingsResponseDescriptor instead')
const UpdateDiscordCoreSettingsResponse$json = {
  '1': 'UpdateDiscordCoreSettingsResponse',
};

/// Descriptor for `UpdateDiscordCoreSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordCoreSettingsResponseDescriptor =
    $convert.base64Decode('CiFVcGRhdGVEaXNjb3JkQ29yZVNldHRpbmdzUmVzcG9uc2U=');

@$core.Deprecated('Use updateDiscordReminderSettingsRequestDescriptor instead')
const UpdateDiscordReminderSettingsRequest$json = {
  '1': 'UpdateDiscordReminderSettingsRequest',
  '2': [
    {
      '1': 'discord_start_reminder_mins',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'discordStartReminderMins',
      '17': true
    },
    {
      '1': 'discord_end_reminder_mins',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'discordEndReminderMins',
      '17': true
    },
    {
      '1': 'discord_start_reminder_message',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'discordStartReminderMessage',
      '17': true
    },
    {
      '1': 'discord_end_reminder_message',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'discordEndReminderMessage',
      '17': true
    },
  ],
  '8': [
    {'1': '_discord_start_reminder_mins'},
    {'1': '_discord_end_reminder_mins'},
    {'1': '_discord_start_reminder_message'},
    {'1': '_discord_end_reminder_message'},
  ],
};

/// Descriptor for `UpdateDiscordReminderSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordReminderSettingsRequestDescriptor = $convert.base64Decode(
    'CiRVcGRhdGVEaXNjb3JkUmVtaW5kZXJTZXR0aW5nc1JlcXVlc3QSQgobZGlzY29yZF9zdGFydF'
    '9yZW1pbmRlcl9taW5zGAEgASgDSABSGGRpc2NvcmRTdGFydFJlbWluZGVyTWluc4gBARI+Chlk'
    'aXNjb3JkX2VuZF9yZW1pbmRlcl9taW5zGAIgASgDSAFSFmRpc2NvcmRFbmRSZW1pbmRlck1pbn'
    'OIAQESSAoeZGlzY29yZF9zdGFydF9yZW1pbmRlcl9tZXNzYWdlGAMgASgJSAJSG2Rpc2NvcmRT'
    'dGFydFJlbWluZGVyTWVzc2FnZYgBARJEChxkaXNjb3JkX2VuZF9yZW1pbmRlcl9tZXNzYWdlGA'
    'QgASgJSANSGWRpc2NvcmRFbmRSZW1pbmRlck1lc3NhZ2WIAQFCHgocX2Rpc2NvcmRfc3RhcnRf'
    'cmVtaW5kZXJfbWluc0IcChpfZGlzY29yZF9lbmRfcmVtaW5kZXJfbWluc0IhCh9fZGlzY29yZF'
    '9zdGFydF9yZW1pbmRlcl9tZXNzYWdlQh8KHV9kaXNjb3JkX2VuZF9yZW1pbmRlcl9tZXNzYWdl');

@$core.Deprecated('Use updateDiscordReminderSettingsResponseDescriptor instead')
const UpdateDiscordReminderSettingsResponse$json = {
  '1': 'UpdateDiscordReminderSettingsResponse',
};

/// Descriptor for `UpdateDiscordReminderSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordReminderSettingsResponseDescriptor =
    $convert
        .base64Decode('CiVVcGRhdGVEaXNjb3JkUmVtaW5kZXJTZXR0aW5nc1Jlc3BvbnNl');

@$core.Deprecated('Use updateDiscordBehaviorSettingsRequestDescriptor instead')
const UpdateDiscordBehaviorSettingsRequest$json = {
  '1': 'UpdateDiscordBehaviorSettingsRequest',
  '2': [
    {
      '1': 'discord_self_link_enabled',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'discordSelfLinkEnabled',
      '17': true
    },
    {
      '1': 'discord_name_sync_enabled',
      '3': 2,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'discordNameSyncEnabled',
      '17': true
    },
    {
      '1': 'discord_overtime_dm_enabled',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 2,
      '10': 'discordOvertimeDmEnabled',
      '17': true
    },
    {
      '1': 'discord_overtime_dm_mins',
      '3': 4,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'discordOvertimeDmMins',
      '17': true
    },
    {
      '1': 'discord_overtime_dm_message',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'discordOvertimeDmMessage',
      '17': true
    },
    {
      '1': 'discord_auto_checkout_dm_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'discordAutoCheckoutDmEnabled',
      '17': true
    },
    {
      '1': 'discord_auto_checkout_dm_message',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'discordAutoCheckoutDmMessage',
      '17': true
    },
    {
      '1': 'discord_checkout_enabled',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 7,
      '10': 'discordCheckoutEnabled',
      '17': true
    },
    {
      '1': 'discord_rsvp_reactions_enabled',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'discordRsvpReactionsEnabled',
      '17': true
    },
  ],
  '8': [
    {'1': '_discord_self_link_enabled'},
    {'1': '_discord_name_sync_enabled'},
    {'1': '_discord_overtime_dm_enabled'},
    {'1': '_discord_overtime_dm_mins'},
    {'1': '_discord_overtime_dm_message'},
    {'1': '_discord_auto_checkout_dm_enabled'},
    {'1': '_discord_auto_checkout_dm_message'},
    {'1': '_discord_checkout_enabled'},
    {'1': '_discord_rsvp_reactions_enabled'},
  ],
};

/// Descriptor for `UpdateDiscordBehaviorSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordBehaviorSettingsRequestDescriptor = $convert.base64Decode(
    'CiRVcGRhdGVEaXNjb3JkQmVoYXZpb3JTZXR0aW5nc1JlcXVlc3QSPgoZZGlzY29yZF9zZWxmX2'
    'xpbmtfZW5hYmxlZBgBIAEoCEgAUhZkaXNjb3JkU2VsZkxpbmtFbmFibGVkiAEBEj4KGWRpc2Nv'
    'cmRfbmFtZV9zeW5jX2VuYWJsZWQYAiABKAhIAVIWZGlzY29yZE5hbWVTeW5jRW5hYmxlZIgBAR'
    'JCChtkaXNjb3JkX292ZXJ0aW1lX2RtX2VuYWJsZWQYAyABKAhIAlIYZGlzY29yZE92ZXJ0aW1l'
    'RG1FbmFibGVkiAEBEjwKGGRpc2NvcmRfb3ZlcnRpbWVfZG1fbWlucxgEIAEoA0gDUhVkaXNjb3'
    'JkT3ZlcnRpbWVEbU1pbnOIAQESQgobZGlzY29yZF9vdmVydGltZV9kbV9tZXNzYWdlGAUgASgJ'
    'SARSGGRpc2NvcmRPdmVydGltZURtTWVzc2FnZYgBARJLCiBkaXNjb3JkX2F1dG9fY2hlY2tvdX'
    'RfZG1fZW5hYmxlZBgGIAEoCEgFUhxkaXNjb3JkQXV0b0NoZWNrb3V0RG1FbmFibGVkiAEBEksK'
    'IGRpc2NvcmRfYXV0b19jaGVja291dF9kbV9tZXNzYWdlGAcgASgJSAZSHGRpc2NvcmRBdXRvQ2'
    'hlY2tvdXREbU1lc3NhZ2WIAQESPQoYZGlzY29yZF9jaGVja291dF9lbmFibGVkGAggASgISAdS'
    'FmRpc2NvcmRDaGVja291dEVuYWJsZWSIAQESSAoeZGlzY29yZF9yc3ZwX3JlYWN0aW9uc19lbm'
    'FibGVkGAkgASgISAhSG2Rpc2NvcmRSc3ZwUmVhY3Rpb25zRW5hYmxlZIgBAUIcChpfZGlzY29y'
    'ZF9zZWxmX2xpbmtfZW5hYmxlZEIcChpfZGlzY29yZF9uYW1lX3N5bmNfZW5hYmxlZEIeChxfZG'
    'lzY29yZF9vdmVydGltZV9kbV9lbmFibGVkQhsKGV9kaXNjb3JkX292ZXJ0aW1lX2RtX21pbnNC'
    'HgocX2Rpc2NvcmRfb3ZlcnRpbWVfZG1fbWVzc2FnZUIjCiFfZGlzY29yZF9hdXRvX2NoZWNrb3'
    'V0X2RtX2VuYWJsZWRCIwohX2Rpc2NvcmRfYXV0b19jaGVja291dF9kbV9tZXNzYWdlQhsKGV9k'
    'aXNjb3JkX2NoZWNrb3V0X2VuYWJsZWRCIQofX2Rpc2NvcmRfcnN2cF9yZWFjdGlvbnNfZW5hYm'
    'xlZA==');

@$core.Deprecated('Use updateDiscordBehaviorSettingsResponseDescriptor instead')
const UpdateDiscordBehaviorSettingsResponse$json = {
  '1': 'UpdateDiscordBehaviorSettingsResponse',
};

/// Descriptor for `UpdateDiscordBehaviorSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDiscordBehaviorSettingsResponseDescriptor =
    $convert
        .base64Decode('CiVVcGRhdGVEaXNjb3JkQmVoYXZpb3JTZXR0aW5nc1Jlc3BvbnNl');

@$core.Deprecated('Use discordRoleDescriptor instead')
const DiscordRole$json = {
  '1': 'DiscordRole',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `DiscordRole`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List discordRoleDescriptor = $convert.base64Decode(
    'CgtEaXNjb3JkUm9sZRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use getDiscordRolesRequestDescriptor instead')
const GetDiscordRolesRequest$json = {
  '1': 'GetDiscordRolesRequest',
};

/// Descriptor for `GetDiscordRolesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiscordRolesRequestDescriptor =
    $convert.base64Decode('ChZHZXREaXNjb3JkUm9sZXNSZXF1ZXN0');

@$core.Deprecated('Use getDiscordRolesResponseDescriptor instead')
const GetDiscordRolesResponse$json = {
  '1': 'GetDiscordRolesResponse',
  '2': [
    {
      '1': 'roles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.DiscordRole',
      '10': 'roles'
    },
  ],
};

/// Descriptor for `GetDiscordRolesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiscordRolesResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXREaXNjb3JkUm9sZXNSZXNwb25zZRIpCgVyb2xlcxgBIAMoCzITLnRrLmFwaS5EaXNjb3'
        'JkUm9sZVIFcm9sZXM=');

@$core.Deprecated('Use importDiscordMembersRequestDescriptor instead')
const ImportDiscordMembersRequest$json = {
  '1': 'ImportDiscordMembersRequest',
  '2': [
    {'1': 'role_id', '3': 1, '4': 1, '5': 9, '10': 'roleId'},
    {
      '1': 'member_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tk.db.TeamMemberType',
      '10': 'memberType'
    },
  ],
};

/// Descriptor for `ImportDiscordMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDiscordMembersRequestDescriptor =
    $convert.base64Decode(
        'ChtJbXBvcnREaXNjb3JkTWVtYmVyc1JlcXVlc3QSFwoHcm9sZV9pZBgBIAEoCVIGcm9sZUlkEj'
        'YKC21lbWJlcl90eXBlGAIgASgOMhUudGsuZGIuVGVhbU1lbWJlclR5cGVSCm1lbWJlclR5cGU=');

@$core.Deprecated('Use importDiscordMembersResponseDescriptor instead')
const ImportDiscordMembersResponse$json = {
  '1': 'ImportDiscordMembersResponse',
  '2': [
    {'1': 'imported', '3': 1, '4': 1, '5': 5, '10': 'imported'},
    {'1': 'linked', '3': 2, '4': 1, '5': 5, '10': 'linked'},
    {'1': 'already_linked', '3': 3, '4': 1, '5': 5, '10': 'alreadyLinked'},
  ],
};

/// Descriptor for `ImportDiscordMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDiscordMembersResponseDescriptor =
    $convert.base64Decode(
        'ChxJbXBvcnREaXNjb3JkTWVtYmVyc1Jlc3BvbnNlEhoKCGltcG9ydGVkGAEgASgFUghpbXBvcn'
        'RlZBIWCgZsaW5rZWQYAiABKAVSBmxpbmtlZBIlCg5hbHJlYWR5X2xpbmtlZBgDIAEoBVINYWxy'
        'ZWFkeUxpbmtlZA==');

@$core.Deprecated('Use purgeDatabaseRequestDescriptor instead')
const PurgeDatabaseRequest$json = {
  '1': 'PurgeDatabaseRequest',
};

/// Descriptor for `PurgeDatabaseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purgeDatabaseRequestDescriptor =
    $convert.base64Decode('ChRQdXJnZURhdGFiYXNlUmVxdWVzdA==');

@$core.Deprecated('Use purgeDatabaseResponseDescriptor instead')
const PurgeDatabaseResponse$json = {
  '1': 'PurgeDatabaseResponse',
};

/// Descriptor for `PurgeDatabaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List purgeDatabaseResponseDescriptor =
    $convert.base64Decode('ChVQdXJnZURhdGFiYXNlUmVzcG9uc2U=');
