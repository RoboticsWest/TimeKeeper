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
      '1': 'discord_reminder_mins',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'discordReminderMins'
    },
    {
      '1': 'discord_self_link_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'discordSelfLinkEnabled'
    },
    {
      '1': 'discord_name_sync_enabled',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'discordNameSyncEnabled'
    },
  ],
};

/// Descriptor for `UpdateSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTZXR0aW5nc1JlcXVlc3QSPQobbmV4dF9zZXNzaW9uX3RocmVzaG9sZF9zZWNzGA'
    'EgASgDUhhuZXh0U2Vzc2lvblRocmVzaG9sZFNlY3MSKgoRZGlzY29yZF9ib3RfdG9rZW4YAiAB'
    'KAlSD2Rpc2NvcmRCb3RUb2tlbhIoChBkaXNjb3JkX2d1aWxkX2lkGAMgASgJUg5kaXNjb3JkR3'
    'VpbGRJZBIsChJkaXNjb3JkX2NoYW5uZWxfaWQYBCABKAlSEGRpc2NvcmRDaGFubmVsSWQSMgoV'
    'ZGlzY29yZF9yZW1pbmRlcl9taW5zGAUgASgDUhNkaXNjb3JkUmVtaW5kZXJNaW5zEjkKGWRpc2'
    'NvcmRfc2VsZl9saW5rX2VuYWJsZWQYBiABKAhSFmRpc2NvcmRTZWxmTGlua0VuYWJsZWQSOQoZ'
    'ZGlzY29yZF9uYW1lX3N5bmNfZW5hYmxlZBgHIAEoCFIWZGlzY29yZE5hbWVTeW5jRW5hYmxlZA'
    '==');

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
