// This is a generated file - do not edit.
//
// Generated from api/stats.proto.

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

@$core.Deprecated('Use hoursBucketDescriptor instead')
const HoursBucket$json = {
  '1': 'HoursBucket',
  '2': [
    {'1': 'regular_secs', '3': 1, '4': 1, '5': 1, '10': 'regularSecs'},
    {'1': 'overtime_secs', '3': 2, '4': 1, '5': 1, '10': 'overtimeSecs'},
  ],
};

/// Descriptor for `HoursBucket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hoursBucketDescriptor = $convert.base64Decode(
    'CgtIb3Vyc0J1Y2tldBIhCgxyZWd1bGFyX3NlY3MYASABKAFSC3JlZ3VsYXJTZWNzEiMKDW92ZX'
    'J0aW1lX3NlY3MYAiABKAFSDG92ZXJ0aW1lU2Vjcw==');

@$core.Deprecated('Use leaderboardEntryDescriptor instead')
const LeaderboardEntry$json = {
  '1': 'LeaderboardEntry',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
    {
      '1': 'team_member',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.TeamMember',
      '10': 'teamMember'
    },
    {
      '1': 'active_session',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tk.api.HoursBucket',
      '10': 'activeSession'
    },
    {
      '1': 'this_week',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.tk.api.HoursBucket',
      '10': 'thisWeek'
    },
    {
      '1': 'all_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tk.api.HoursBucket',
      '10': 'allTime'
    },
    {'1': 'total_secs', '3': 6, '4': 1, '5': 1, '10': 'totalSecs'},
  ],
};

/// Descriptor for `LeaderboardEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardEntryDescriptor = $convert.base64Decode(
    'ChBMZWFkZXJib2FyZEVudHJ5EiQKDnRlYW1fbWVtYmVyX2lkGAEgASgJUgx0ZWFtTWVtYmVySW'
    'QSMgoLdGVhbV9tZW1iZXIYAiABKAsyES50ay5kYi5UZWFtTWVtYmVyUgp0ZWFtTWVtYmVyEjoK'
    'DmFjdGl2ZV9zZXNzaW9uGAMgASgLMhMudGsuYXBpLkhvdXJzQnVja2V0Ug1hY3RpdmVTZXNzaW'
    '9uEjAKCXRoaXNfd2VlaxgEIAEoCzITLnRrLmFwaS5Ib3Vyc0J1Y2tldFIIdGhpc1dlZWsSLgoI'
    'YWxsX3RpbWUYBSABKAsyEy50ay5hcGkuSG91cnNCdWNrZXRSB2FsbFRpbWUSHQoKdG90YWxfc2'
    'VjcxgGIAEoAVIJdG90YWxTZWNz');

@$core.Deprecated('Use getLeaderboardRequestDescriptor instead')
const GetLeaderboardRequest$json = {
  '1': 'GetLeaderboardRequest',
};

/// Descriptor for `GetLeaderboardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLeaderboardRequestDescriptor =
    $convert.base64Decode('ChVHZXRMZWFkZXJib2FyZFJlcXVlc3Q=');

@$core.Deprecated('Use getLeaderboardResponseDescriptor instead')
const GetLeaderboardResponse$json = {
  '1': 'GetLeaderboardResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.LeaderboardEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `GetLeaderboardResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLeaderboardResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRMZWFkZXJib2FyZFJlc3BvbnNlEjIKB2VudHJpZXMYASADKAsyGC50ay5hcGkuTGVhZG'
        'VyYm9hcmRFbnRyeVIHZW50cmllcw==');
