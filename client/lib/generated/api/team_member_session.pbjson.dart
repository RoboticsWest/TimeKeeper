// This is a generated file - do not edit.
//
// Generated from api/team_member_session.proto.

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

@$core.Deprecated('Use teamMemberSessionResponseDescriptor instead')
const TeamMemberSessionResponse$json = {
  '1': 'TeamMemberSessionResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'team_member_session',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.TeamMemberSession',
      '10': 'teamMemberSession'
    },
  ],
};

/// Descriptor for `TeamMemberSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMemberSessionResponseDescriptor = $convert.base64Decode(
    'ChlUZWFtTWVtYmVyU2Vzc2lvblJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZBJIChN0ZWFtX21lbW'
    'Jlcl9zZXNzaW9uGAIgASgLMhgudGsuZGIuVGVhbU1lbWJlclNlc3Npb25SEXRlYW1NZW1iZXJT'
    'ZXNzaW9u');

@$core.Deprecated('Use getTeamMemberSessionsRequestDescriptor instead')
const GetTeamMemberSessionsRequest$json = {
  '1': 'GetTeamMemberSessionsRequest',
};

/// Descriptor for `GetTeamMemberSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTeamMemberSessionsRequestDescriptor =
    $convert.base64Decode('ChxHZXRUZWFtTWVtYmVyU2Vzc2lvbnNSZXF1ZXN0');

@$core.Deprecated('Use getTeamMemberSessionsResponseDescriptor instead')
const GetTeamMemberSessionsResponse$json = {
  '1': 'GetTeamMemberSessionsResponse',
  '2': [
    {
      '1': 'team_member_sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberSessionResponse',
      '10': 'teamMemberSessions'
    },
  ],
};

/// Descriptor for `GetTeamMemberSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTeamMemberSessionsResponseDescriptor =
    $convert.base64Decode(
        'Ch1HZXRUZWFtTWVtYmVyU2Vzc2lvbnNSZXNwb25zZRJTChR0ZWFtX21lbWJlcl9zZXNzaW9ucx'
        'gBIAMoCzIhLnRrLmFwaS5UZWFtTWVtYmVyU2Vzc2lvblJlc3BvbnNlUhJ0ZWFtTWVtYmVyU2Vz'
        'c2lvbnM=');

@$core.Deprecated('Use streamTeamMemberSessionsRequestDescriptor instead')
const StreamTeamMemberSessionsRequest$json = {
  '1': 'StreamTeamMemberSessionsRequest',
};

/// Descriptor for `StreamTeamMemberSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamMemberSessionsRequestDescriptor =
    $convert.base64Decode('Ch9TdHJlYW1UZWFtTWVtYmVyU2Vzc2lvbnNSZXF1ZXN0');

@$core.Deprecated('Use streamTeamMemberSessionsResponseDescriptor instead')
const StreamTeamMemberSessionsResponse$json = {
  '1': 'StreamTeamMemberSessionsResponse',
  '2': [
    {
      '1': 'team_member_sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberSessionResponse',
      '10': 'teamMemberSessions'
    },
    {
      '1': 'sync_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tk.common.SyncType',
      '10': 'syncType'
    },
  ],
};

/// Descriptor for `StreamTeamMemberSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamMemberSessionsResponseDescriptor =
    $convert.base64Decode(
        'CiBTdHJlYW1UZWFtTWVtYmVyU2Vzc2lvbnNSZXNwb25zZRJTChR0ZWFtX21lbWJlcl9zZXNzaW'
        '9ucxgBIAMoCzIhLnRrLmFwaS5UZWFtTWVtYmVyU2Vzc2lvblJlc3BvbnNlUhJ0ZWFtTWVtYmVy'
        'U2Vzc2lvbnMSMAoJc3luY190eXBlGAIgASgOMhMudGsuY29tbW9uLlN5bmNUeXBlUghzeW5jVH'
        'lwZQ==');
