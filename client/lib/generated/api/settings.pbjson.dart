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

@$core.Deprecated('Use updateSettingsRequestDescriptor instead')
const UpdateSettingsRequest$json = {
  '1': 'UpdateSettingsRequest',
  '2': [
    {
      '1': 'next_session_threshold_secs',
      '3': 1,
      '4': 1,
      '5': 3,
      '10': 'nextSessionThresholdSecs'
    },
    {'1': 'discord_enabled', '3': 17, '4': 1, '5': 8, '10': 'discordEnabled'},
    {'1': 'discord_bot_token', '3': 2, '4': 1, '5': 9, '10': 'discordBotToken'},
    {'1': 'discord_guild_id', '3': 3, '4': 1, '5': 9, '10': 'discordGuildId'},
    {
      '1': 'discord_channel_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'discordChannelId'
    },
    {
      '1': 'discord_self_link_enabled',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'discordSelfLinkEnabled'
    },
    {
      '1': 'discord_name_sync_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'discordNameSyncEnabled'
    },
    {
      '1': 'discord_start_reminder_mins',
      '3': 7,
      '4': 1,
      '5': 3,
      '10': 'discordStartReminderMins'
    },
    {
      '1': 'discord_end_reminder_mins',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'discordEndReminderMins'
    },
    {
      '1': 'discord_start_reminder_message',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'discordStartReminderMessage'
    },
    {
      '1': 'discord_end_reminder_message',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'discordEndReminderMessage'
    },
    {
      '1': 'discord_overtime_dm_enabled',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'discordOvertimeDmEnabled'
    },
    {
      '1': 'discord_overtime_dm_mins',
      '3': 12,
      '4': 1,
      '5': 3,
      '10': 'discordOvertimeDmMins'
    },
    {
      '1': 'discord_overtime_dm_message',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'discordOvertimeDmMessage'
    },
    {
      '1': 'discord_auto_checkout_dm_enabled',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'discordAutoCheckoutDmEnabled'
    },
    {
      '1': 'discord_auto_checkout_dm_message',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'discordAutoCheckoutDmMessage'
    },
    {
      '1': 'discord_checkout_enabled',
      '3': 16,
      '4': 1,
      '5': 8,
      '10': 'discordCheckoutEnabled'
    },
    {'1': 'timezone', '3': 18, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'primary_color', '3': 19, '4': 1, '5': 9, '10': 'primaryColor'},
    {'1': 'secondary_color', '3': 20, '4': 1, '5': 9, '10': 'secondaryColor'},
  ],
};

/// Descriptor for `UpdateSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTZXR0aW5nc1JlcXVlc3QSPQobbmV4dF9zZXNzaW9uX3RocmVzaG9sZF9zZWNzGA'
    'EgASgDUhhuZXh0U2Vzc2lvblRocmVzaG9sZFNlY3MSJwoPZGlzY29yZF9lbmFibGVkGBEgASgI'
    'Ug5kaXNjb3JkRW5hYmxlZBIqChFkaXNjb3JkX2JvdF90b2tlbhgCIAEoCVIPZGlzY29yZEJvdF'
    'Rva2VuEigKEGRpc2NvcmRfZ3VpbGRfaWQYAyABKAlSDmRpc2NvcmRHdWlsZElkEiwKEmRpc2Nv'
    'cmRfY2hhbm5lbF9pZBgEIAEoCVIQZGlzY29yZENoYW5uZWxJZBI5ChlkaXNjb3JkX3NlbGZfbG'
    'lua19lbmFibGVkGAUgASgIUhZkaXNjb3JkU2VsZkxpbmtFbmFibGVkEjkKGWRpc2NvcmRfbmFt'
    'ZV9zeW5jX2VuYWJsZWQYBiABKAhSFmRpc2NvcmROYW1lU3luY0VuYWJsZWQSPQobZGlzY29yZF'
    '9zdGFydF9yZW1pbmRlcl9taW5zGAcgASgDUhhkaXNjb3JkU3RhcnRSZW1pbmRlck1pbnMSOQoZ'
    'ZGlzY29yZF9lbmRfcmVtaW5kZXJfbWlucxgIIAEoA1IWZGlzY29yZEVuZFJlbWluZGVyTWlucx'
    'JDCh5kaXNjb3JkX3N0YXJ0X3JlbWluZGVyX21lc3NhZ2UYCSABKAlSG2Rpc2NvcmRTdGFydFJl'
    'bWluZGVyTWVzc2FnZRI/ChxkaXNjb3JkX2VuZF9yZW1pbmRlcl9tZXNzYWdlGAogASgJUhlkaX'
    'Njb3JkRW5kUmVtaW5kZXJNZXNzYWdlEj0KG2Rpc2NvcmRfb3ZlcnRpbWVfZG1fZW5hYmxlZBgL'
    'IAEoCFIYZGlzY29yZE92ZXJ0aW1lRG1FbmFibGVkEjcKGGRpc2NvcmRfb3ZlcnRpbWVfZG1fbW'
    'lucxgMIAEoA1IVZGlzY29yZE92ZXJ0aW1lRG1NaW5zEj0KG2Rpc2NvcmRfb3ZlcnRpbWVfZG1f'
    'bWVzc2FnZRgNIAEoCVIYZGlzY29yZE92ZXJ0aW1lRG1NZXNzYWdlEkYKIGRpc2NvcmRfYXV0b1'
    '9jaGVja291dF9kbV9lbmFibGVkGA4gASgIUhxkaXNjb3JkQXV0b0NoZWNrb3V0RG1FbmFibGVk'
    'EkYKIGRpc2NvcmRfYXV0b19jaGVja291dF9kbV9tZXNzYWdlGA8gASgJUhxkaXNjb3JkQXV0b0'
    'NoZWNrb3V0RG1NZXNzYWdlEjgKGGRpc2NvcmRfY2hlY2tvdXRfZW5hYmxlZBgQIAEoCFIWZGlz'
    'Y29yZENoZWNrb3V0RW5hYmxlZBIaCgh0aW1lem9uZRgSIAEoCVIIdGltZXpvbmUSIwoNcHJpbW'
    'FyeV9jb2xvchgTIAEoCVIMcHJpbWFyeUNvbG9yEicKD3NlY29uZGFyeV9jb2xvchgUIAEoCVIO'
    'c2Vjb25kYXJ5Q29sb3I=');

@$core.Deprecated('Use updateSettingsResponseDescriptor instead')
const UpdateSettingsResponse$json = {
  '1': 'UpdateSettingsResponse',
};

/// Descriptor for `UpdateSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsResponseDescriptor =
    $convert.base64Decode('ChZVcGRhdGVTZXR0aW5nc1Jlc3BvbnNl');

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
