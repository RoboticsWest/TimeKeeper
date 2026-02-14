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
      '1': 'discord_auto_checkout_dm_mins',
      '3': 15,
      '4': 1,
      '5': 3,
      '10': 'discordAutoCheckoutDmMins'
    },
    {
      '1': 'discord_auto_checkout_dm_message',
      '3': 16,
      '4': 1,
      '5': 9,
      '10': 'discordAutoCheckoutDmMessage'
    },
  ],
};

/// Descriptor for `UpdateSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTZXR0aW5nc1JlcXVlc3QSPQobbmV4dF9zZXNzaW9uX3RocmVzaG9sZF9zZWNzGA'
    'EgASgDUhhuZXh0U2Vzc2lvblRocmVzaG9sZFNlY3MSKgoRZGlzY29yZF9ib3RfdG9rZW4YAiAB'
    'KAlSD2Rpc2NvcmRCb3RUb2tlbhIoChBkaXNjb3JkX2d1aWxkX2lkGAMgASgJUg5kaXNjb3JkR3'
    'VpbGRJZBIsChJkaXNjb3JkX2NoYW5uZWxfaWQYBCABKAlSEGRpc2NvcmRDaGFubmVsSWQSOQoZ'
    'ZGlzY29yZF9zZWxmX2xpbmtfZW5hYmxlZBgFIAEoCFIWZGlzY29yZFNlbGZMaW5rRW5hYmxlZB'
    'I5ChlkaXNjb3JkX25hbWVfc3luY19lbmFibGVkGAYgASgIUhZkaXNjb3JkTmFtZVN5bmNFbmFi'
    'bGVkEj0KG2Rpc2NvcmRfc3RhcnRfcmVtaW5kZXJfbWlucxgHIAEoA1IYZGlzY29yZFN0YXJ0Um'
    'VtaW5kZXJNaW5zEjkKGWRpc2NvcmRfZW5kX3JlbWluZGVyX21pbnMYCCABKANSFmRpc2NvcmRF'
    'bmRSZW1pbmRlck1pbnMSQwoeZGlzY29yZF9zdGFydF9yZW1pbmRlcl9tZXNzYWdlGAkgASgJUh'
    'tkaXNjb3JkU3RhcnRSZW1pbmRlck1lc3NhZ2USPwocZGlzY29yZF9lbmRfcmVtaW5kZXJfbWVz'
    'c2FnZRgKIAEoCVIZZGlzY29yZEVuZFJlbWluZGVyTWVzc2FnZRI9ChtkaXNjb3JkX292ZXJ0aW'
    '1lX2RtX2VuYWJsZWQYCyABKAhSGGRpc2NvcmRPdmVydGltZURtRW5hYmxlZBI3ChhkaXNjb3Jk'
    'X292ZXJ0aW1lX2RtX21pbnMYDCABKANSFWRpc2NvcmRPdmVydGltZURtTWlucxI9ChtkaXNjb3'
    'JkX292ZXJ0aW1lX2RtX21lc3NhZ2UYDSABKAlSGGRpc2NvcmRPdmVydGltZURtTWVzc2FnZRJG'
    'CiBkaXNjb3JkX2F1dG9fY2hlY2tvdXRfZG1fZW5hYmxlZBgOIAEoCFIcZGlzY29yZEF1dG9DaG'
    'Vja291dERtRW5hYmxlZBJACh1kaXNjb3JkX2F1dG9fY2hlY2tvdXRfZG1fbWlucxgPIAEoA1IZ'
    'ZGlzY29yZEF1dG9DaGVja291dERtTWlucxJGCiBkaXNjb3JkX2F1dG9fY2hlY2tvdXRfZG1fbW'
    'Vzc2FnZRgQIAEoCVIcZGlzY29yZEF1dG9DaGVja291dERtTWVzc2FnZQ==');

@$core.Deprecated('Use updateSettingsResponseDescriptor instead')
const UpdateSettingsResponse$json = {
  '1': 'UpdateSettingsResponse',
};

/// Descriptor for `UpdateSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsResponseDescriptor =
    $convert.base64Decode('ChZVcGRhdGVTZXR0aW5nc1Jlc3BvbnNl');

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
