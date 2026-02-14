// This is a generated file - do not edit.
//
// Generated from api/sync.proto.

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

@$core.Deprecated('Use streamEntitiesRequestDescriptor instead')
const StreamEntitiesRequest$json = {
  '1': 'StreamEntitiesRequest',
};

/// Descriptor for `StreamEntitiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamEntitiesRequestDescriptor =
    $convert.base64Decode('ChVTdHJlYW1FbnRpdGllc1JlcXVlc3Q=');

@$core.Deprecated('Use streamEntitiesResponseDescriptor instead')
const StreamEntitiesResponse$json = {
  '1': 'StreamEntitiesResponse',
  '2': [
    {
      '1': 'sync_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.tk.common.SyncType',
      '10': 'syncType'
    },
    {
      '1': 'sessions',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamSessionsResponse',
      '9': 0,
      '10': 'sessions'
    },
    {
      '1': 'locations',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamLocationsResponse',
      '9': 0,
      '10': 'locations'
    },
    {
      '1': 'team_members',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamTeamMembersResponse',
      '9': 0,
      '10': 'teamMembers'
    },
    {
      '1': 'team_member_sessions',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamTeamMemberSessionsResponse',
      '9': 0,
      '10': 'teamMemberSessions'
    },
    {
      '1': 'rfid_tags',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamRfidTagsResponse',
      '9': 0,
      '10': 'rfidTags'
    },
    {
      '1': 'notifications',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.tk.api.StreamNotificationsResponse',
      '9': 0,
      '10': 'notifications'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `StreamEntitiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamEntitiesResponseDescriptor = $convert.base64Decode(
    'ChZTdHJlYW1FbnRpdGllc1Jlc3BvbnNlEjAKCXN5bmNfdHlwZRgBIAEoDjITLnRrLmNvbW1vbi'
    '5TeW5jVHlwZVIIc3luY1R5cGUSPAoIc2Vzc2lvbnMYAiABKAsyHi50ay5hcGkuU3RyZWFtU2Vz'
    'c2lvbnNSZXNwb25zZUgAUghzZXNzaW9ucxI/Cglsb2NhdGlvbnMYAyABKAsyHy50ay5hcGkuU3'
    'RyZWFtTG9jYXRpb25zUmVzcG9uc2VIAFIJbG9jYXRpb25zEkYKDHRlYW1fbWVtYmVycxgEIAEo'
    'CzIhLnRrLmFwaS5TdHJlYW1UZWFtTWVtYmVyc1Jlc3BvbnNlSABSC3RlYW1NZW1iZXJzElwKFH'
    'RlYW1fbWVtYmVyX3Nlc3Npb25zGAUgASgLMigudGsuYXBpLlN0cmVhbVRlYW1NZW1iZXJTZXNz'
    'aW9uc1Jlc3BvbnNlSABSEnRlYW1NZW1iZXJTZXNzaW9ucxI9CglyZmlkX3RhZ3MYBiABKAsyHi'
    '50ay5hcGkuU3RyZWFtUmZpZFRhZ3NSZXNwb25zZUgAUghyZmlkVGFncxJLCg1ub3RpZmljYXRp'
    'b25zGAcgASgLMiMudGsuYXBpLlN0cmVhbU5vdGlmaWNhdGlvbnNSZXNwb25zZUgAUg1ub3RpZm'
    'ljYXRpb25zQgkKB3BheWxvYWQ=');
