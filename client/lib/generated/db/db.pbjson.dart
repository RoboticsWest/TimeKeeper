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
    {'1': 'alias', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'alias', '17': true},
    {
      '1': 'secondary_alias',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'secondaryAlias',
      '17': true
    },
  ],
  '8': [
    {'1': '_alias'},
    {'1': '_secondary_alias'},
  ],
};

/// Descriptor for `TeamMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMemberDescriptor = $convert.base64Decode(
    'CgpUZWFtTWVtYmVyEh0KCmZpcnN0X25hbWUYASABKAlSCWZpcnN0TmFtZRIbCglsYXN0X25hbW'
    'UYAiABKAlSCGxhc3ROYW1lEjYKC21lbWJlcl90eXBlGAMgASgOMhUudGsuZGIuVGVhbU1lbWJl'
    'clR5cGVSCm1lbWJlclR5cGUSGQoFYWxpYXMYBCABKAlIAFIFYWxpYXOIAQESLAoPc2Vjb25kYX'
    'J5X2FsaWFzGAUgASgJSAFSDnNlY29uZGFyeUFsaWFziAEBQggKBl9hbGlhc0ISChBfc2Vjb25k'
    'YXJ5X2FsaWFz');

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
    {
      '1': 'check_in_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkDateTime',
      '10': 'checkInTime'
    },
    {
      '1': 'check_out_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkDateTime',
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
    'lkEjkKDWNoZWNrX2luX3RpbWUYAiABKAsyFS50ay5jb21tb24uVGtEYXRlVGltZVILY2hlY2tJ'
    'blRpbWUSQAoOY2hlY2tfb3V0X3RpbWUYAyABKAsyFS50ay5jb21tb24uVGtEYXRlVGltZUgAUg'
    'xjaGVja091dFRpbWWIAQFCEQoPX2NoZWNrX291dF90aW1l');

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {
      '1': 'start_time',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkDateTime',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkDateTime',
      '10': 'endTime'
    },
    {'1': 'location_id', '3': 3, '4': 1, '5': 9, '10': 'locationId'},
    {
      '1': 'member_sessions',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.tk.db.TeamMemberSession',
      '10': 'memberSessions'
    },
    {'1': 'finished', '3': 5, '4': 1, '5': 8, '10': 'finished'},
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEjQKCnN0YXJ0X3RpbWUYASABKAsyFS50ay5jb21tb24uVGtEYXRlVGltZVIJc3'
    'RhcnRUaW1lEjAKCGVuZF90aW1lGAIgASgLMhUudGsuY29tbW9uLlRrRGF0ZVRpbWVSB2VuZFRp'
    'bWUSHwoLbG9jYXRpb25faWQYAyABKAlSCmxvY2F0aW9uSWQSQQoPbWVtYmVyX3Nlc3Npb25zGA'
    'QgAygLMhgudGsuZGIuVGVhbU1lbWJlclNlc3Npb25SDm1lbWJlclNlc3Npb25zEhoKCGZpbmlz'
    'aGVkGAUgASgIUghmaW5pc2hlZA==');
