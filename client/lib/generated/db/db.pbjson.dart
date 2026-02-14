// This is a generated file - do not edit.
//
// Generated from db/db.proto.

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

@$core.Deprecated('Use teamMemberTypeDescriptor instead')
const TeamMemberType$json = {
  '1': 'TeamMemberType',
  '2': [
    {'1': 'STUDENT', '2': 0},
    {'1': 'MENTOR', '2': 1},
  ],
};

/// Descriptor for `TeamMemberType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List teamMemberTypeDescriptor = $convert
    .base64Decode('Cg5UZWFtTWVtYmVyVHlwZRILCgdTVFVERU5UEAASCgoGTUVOVE9SEAE=');

@$core.Deprecated('Use notificationTypeDescriptor instead')
const NotificationType$json = {
  '1': 'NotificationType',
  '2': [
    {'1': 'SESSION_START_REMINDER', '2': 0},
    {'1': 'SESSION_END_REMINDER', '2': 1},
    {'1': 'OVERTIME', '2': 2},
    {'1': 'AUTO_CHECKOUT', '2': 3},
  ],
};

/// Descriptor for `NotificationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationTypeDescriptor = $convert.base64Decode(
    'ChBOb3RpZmljYXRpb25UeXBlEhoKFlNFU1NJT05fU1RBUlRfUkVNSU5ERVIQABIYChRTRVNTSU'
    '9OX0VORF9SRU1JTkRFUhABEgwKCE9WRVJUSU1FEAISEQoNQVVUT19DSEVDS09VVBAD');

@$core.Deprecated('Use secretDescriptor instead')
const Secret$json = {
  '1': 'Secret',
  '2': [
    {'1': 'secret_bytes', '3': 1, '4': 1, '5': 12, '10': 'secretBytes'},
  ],
};

/// Descriptor for `Secret`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List secretDescriptor = $convert.base64Decode(
    'CgZTZWNyZXQSIQoMc2VjcmV0X2J5dGVzGAEgASgMUgtzZWNyZXRCeXRlcw==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {
      '1': 'roles',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.tk.common.Role',
      '10': 'roles'
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEhoKCHVzZXJuYW1lGAEgASgJUgh1c2VybmFtZRIaCghwYXNzd29yZBgCIAEoCVIIcG'
    'Fzc3dvcmQSJQoFcm9sZXMYAyADKA4yDy50ay5jb21tb24uUm9sZVIFcm9sZXM=');

@$core.Deprecated('Use teamMemberDescriptor instead')
const TeamMember$json = {
  '1': 'TeamMember',
  '2': [
    {'1': 'first_name', '3': 1, '4': 1, '5': 9, '10': 'firstName'},
    {'1': 'last_name', '3': 2, '4': 1, '5': 9, '10': 'lastName'},
    {
      '1': 'member_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.tk.db.TeamMemberType',
      '10': 'memberType'
    },
    {
      '1': 'display_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'displayName',
      '17': true
    },
    {
      '1': 'mobile_number',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'mobileNumber',
      '17': true
    },
    {
      '1': 'discord_username',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'discordUsername',
      '17': true
    },
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_mobile_number'},
    {'1': '_discord_username'},
  ],
};

/// Descriptor for `TeamMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMemberDescriptor = $convert.base64Decode(
    'CgpUZWFtTWVtYmVyEh0KCmZpcnN0X25hbWUYASABKAlSCWZpcnN0TmFtZRIbCglsYXN0X25hbW'
    'UYAiABKAlSCGxhc3ROYW1lEjYKC21lbWJlcl90eXBlGAMgASgOMhUudGsuZGIuVGVhbU1lbWJl'
    'clR5cGVSCm1lbWJlclR5cGUSJgoMZGlzcGxheV9uYW1lGAQgASgJSABSC2Rpc3BsYXlOYW1liA'
    'EBEigKDW1vYmlsZV9udW1iZXIYBSABKAlIAVIMbW9iaWxlTnVtYmVyiAEBEi4KEGRpc2NvcmRf'
    'dXNlcm5hbWUYBiABKAlIAlIPZGlzY29yZFVzZXJuYW1liAEBQg8KDV9kaXNwbGF5X25hbWVCEA'
    'oOX21vYmlsZV9udW1iZXJCEwoRX2Rpc2NvcmRfdXNlcm5hbWU=');

@$core.Deprecated('Use rfidTagDescriptor instead')
const RfidTag$json = {
  '1': 'RfidTag',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
    {'1': 'tag', '3': 2, '4': 1, '5': 9, '10': 'tag'},
  ],
};

/// Descriptor for `RfidTag`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rfidTagDescriptor = $convert.base64Decode(
    'CgdSZmlkVGFnEiQKDnRlYW1fbWVtYmVyX2lkGAEgASgJUgx0ZWFtTWVtYmVySWQSEAoDdGFnGA'
    'IgASgJUgN0YWc=');

@$core.Deprecated('Use locationDescriptor instead')
const Location$json = {
  '1': 'Location',
  '2': [
    {'1': 'location', '3': 1, '4': 1, '5': 9, '10': 'location'},
  ],
};

/// Descriptor for `Location`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDescriptor = $convert
    .base64Decode('CghMb2NhdGlvbhIaCghsb2NhdGlvbhgBIAEoCVIIbG9jYXRpb24=');

@$core.Deprecated('Use teamMemberSessionDescriptor instead')
const TeamMemberSession$json = {
  '1': 'TeamMemberSession',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'check_in_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tk.common.Timestamp',
      '10': 'checkInTime'
    },
    {
      '1': 'check_out_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.tk.common.Timestamp',
      '9': 0,
      '10': 'checkOutTime',
      '17': true
    },
  ],
  '8': [
    {'1': '_check_out_time'},
  ],
};

/// Descriptor for `TeamMemberSession`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMemberSessionDescriptor = $convert.base64Decode(
    'ChFUZWFtTWVtYmVyU2Vzc2lvbhIkCg50ZWFtX21lbWJlcl9pZBgBIAEoCVIMdGVhbU1lbWJlck'
    'lkEh0KCnNlc3Npb25faWQYAiABKAlSCXNlc3Npb25JZBI4Cg1jaGVja19pbl90aW1lGAMgASgL'
    'MhQudGsuY29tbW9uLlRpbWVzdGFtcFILY2hlY2tJblRpbWUSPwoOY2hlY2tfb3V0X3RpbWUYBC'
    'ABKAsyFC50ay5jb21tb24uVGltZXN0YW1wSABSDGNoZWNrT3V0VGltZYgBAUIRCg9fY2hlY2tf'
    'b3V0X3RpbWU=');

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {
      '1': 'start_time',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tk.common.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.common.Timestamp',
      '10': 'endTime'
    },
    {'1': 'location_id', '3': 3, '4': 1, '5': 9, '10': 'locationId'},
    {'1': 'finished', '3': 4, '4': 1, '5': 8, '10': 'finished'},
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEjMKCnN0YXJ0X3RpbWUYASABKAsyFC50ay5jb21tb24uVGltZXN0YW1wUglzdG'
    'FydFRpbWUSLwoIZW5kX3RpbWUYAiABKAsyFC50ay5jb21tb24uVGltZXN0YW1wUgdlbmRUaW1l'
    'Eh8KC2xvY2F0aW9uX2lkGAMgASgJUgpsb2NhdGlvbklkEhoKCGZpbmlzaGVkGAQgASgIUghmaW'
    '5pc2hlZA==');

@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = {
  '1': 'Notification',
  '2': [
    {
      '1': 'notification_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.tk.db.NotificationType',
      '10': 'notificationType'
    },
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'team_member_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'teamMemberId',
      '17': true
    },
    {'1': 'sent', '3': 4, '4': 1, '5': 8, '10': 'sent'},
  ],
  '8': [
    {'1': '_team_member_id'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SRAoRbm90aWZpY2F0aW9uX3R5cGUYASABKA4yFy50ay5kYi5Ob3RpZm'
    'ljYXRpb25UeXBlUhBub3RpZmljYXRpb25UeXBlEh0KCnNlc3Npb25faWQYAiABKAlSCXNlc3Np'
    'b25JZBIpCg50ZWFtX21lbWJlcl9pZBgDIAEoCUgAUgx0ZWFtTWVtYmVySWSIAQESEgoEc2VudB'
    'gEIAEoCFIEc2VudEIRCg9fdGVhbV9tZW1iZXJfaWQ=');

@$core.Deprecated('Use settingsDescriptor instead')
const Settings$json = {
  '1': 'Settings',
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
    {'1': 'discord_enabled', '3': 17, '4': 1, '5': 8, '10': 'discordEnabled'},
    {'1': 'timezone', '3': 18, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxI9ChtuZXh0X3Nlc3Npb25fdGhyZXNob2xkX3NlY3MYASABKANSGG5leHRTZX'
    'NzaW9uVGhyZXNob2xkU2VjcxIqChFkaXNjb3JkX2JvdF90b2tlbhgCIAEoCVIPZGlzY29yZEJv'
    'dFRva2VuEigKEGRpc2NvcmRfZ3VpbGRfaWQYAyABKAlSDmRpc2NvcmRHdWlsZElkEiwKEmRpc2'
    'NvcmRfY2hhbm5lbF9pZBgEIAEoCVIQZGlzY29yZENoYW5uZWxJZBI5ChlkaXNjb3JkX3NlbGZf'
    'bGlua19lbmFibGVkGAUgASgIUhZkaXNjb3JkU2VsZkxpbmtFbmFibGVkEjkKGWRpc2NvcmRfbm'
    'FtZV9zeW5jX2VuYWJsZWQYBiABKAhSFmRpc2NvcmROYW1lU3luY0VuYWJsZWQSPQobZGlzY29y'
    'ZF9zdGFydF9yZW1pbmRlcl9taW5zGAcgASgDUhhkaXNjb3JkU3RhcnRSZW1pbmRlck1pbnMSOQ'
    'oZZGlzY29yZF9lbmRfcmVtaW5kZXJfbWlucxgIIAEoA1IWZGlzY29yZEVuZFJlbWluZGVyTWlu'
    'cxJDCh5kaXNjb3JkX3N0YXJ0X3JlbWluZGVyX21lc3NhZ2UYCSABKAlSG2Rpc2NvcmRTdGFydF'
    'JlbWluZGVyTWVzc2FnZRI/ChxkaXNjb3JkX2VuZF9yZW1pbmRlcl9tZXNzYWdlGAogASgJUhlk'
    'aXNjb3JkRW5kUmVtaW5kZXJNZXNzYWdlEj0KG2Rpc2NvcmRfb3ZlcnRpbWVfZG1fZW5hYmxlZB'
    'gLIAEoCFIYZGlzY29yZE92ZXJ0aW1lRG1FbmFibGVkEjcKGGRpc2NvcmRfb3ZlcnRpbWVfZG1f'
    'bWlucxgMIAEoA1IVZGlzY29yZE92ZXJ0aW1lRG1NaW5zEj0KG2Rpc2NvcmRfb3ZlcnRpbWVfZG'
    '1fbWVzc2FnZRgNIAEoCVIYZGlzY29yZE92ZXJ0aW1lRG1NZXNzYWdlEkYKIGRpc2NvcmRfYXV0'
    'b19jaGVja291dF9kbV9lbmFibGVkGA4gASgIUhxkaXNjb3JkQXV0b0NoZWNrb3V0RG1FbmFibG'
    'VkEkYKIGRpc2NvcmRfYXV0b19jaGVja291dF9kbV9tZXNzYWdlGA8gASgJUhxkaXNjb3JkQXV0'
    'b0NoZWNrb3V0RG1NZXNzYWdlEjgKGGRpc2NvcmRfY2hlY2tvdXRfZW5hYmxlZBgQIAEoCFIWZG'
    'lzY29yZENoZWNrb3V0RW5hYmxlZBInCg9kaXNjb3JkX2VuYWJsZWQYESABKAhSDmRpc2NvcmRF'
    'bmFibGVkEhoKCHRpbWV6b25lGBIgASgJUgh0aW1lem9uZQ==');
