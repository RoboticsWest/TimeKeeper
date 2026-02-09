// This is a generated file - do not edit.
//
// Generated from api/team_member.proto.

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

@$core.Deprecated('Use uploadStudentCsvRequestDescriptor instead')
const UploadStudentCsvRequest$json = {
  '1': 'UploadStudentCsvRequest',
  '2': [
    {'1': 'csv_data', '3': 1, '4': 1, '5': 12, '10': 'csvData'},
  ],
};

/// Descriptor for `UploadStudentCsvRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadStudentCsvRequestDescriptor =
    $convert.base64Decode(
        'ChdVcGxvYWRTdHVkZW50Q3N2UmVxdWVzdBIZCghjc3ZfZGF0YRgBIAEoDFIHY3N2RGF0YQ==');

@$core.Deprecated('Use uploadStudentCsvResponseDescriptor instead')
const UploadStudentCsvResponse$json = {
  '1': 'UploadStudentCsvResponse',
};

/// Descriptor for `UploadStudentCsvResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadStudentCsvResponseDescriptor =
    $convert.base64Decode('ChhVcGxvYWRTdHVkZW50Q3N2UmVzcG9uc2U=');

@$core.Deprecated('Use uploadMentorCsvRequestDescriptor instead')
const UploadMentorCsvRequest$json = {
  '1': 'UploadMentorCsvRequest',
  '2': [
    {'1': 'csv_data', '3': 1, '4': 1, '5': 12, '10': 'csvData'},
  ],
};

/// Descriptor for `UploadMentorCsvRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMentorCsvRequestDescriptor =
    $convert.base64Decode(
        'ChZVcGxvYWRNZW50b3JDc3ZSZXF1ZXN0EhkKCGNzdl9kYXRhGAEgASgMUgdjc3ZEYXRh');

@$core.Deprecated('Use uploadMentorCsvResponseDescriptor instead')
const UploadMentorCsvResponse$json = {
  '1': 'UploadMentorCsvResponse',
};

/// Descriptor for `UploadMentorCsvResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMentorCsvResponseDescriptor =
    $convert.base64Decode('ChdVcGxvYWRNZW50b3JDc3ZSZXNwb25zZQ==');

@$core.Deprecated('Use teamMemberResponseDescriptor instead')
const TeamMemberResponse$json = {
  '1': 'TeamMemberResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'team_member',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.TeamMember',
      '10': 'teamMember'
    },
  ],
};

/// Descriptor for `TeamMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List teamMemberResponseDescriptor = $convert.base64Decode(
    'ChJUZWFtTWVtYmVyUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEjIKC3RlYW1fbWVtYmVyGAIgAS'
    'gLMhEudGsuZGIuVGVhbU1lbWJlclIKdGVhbU1lbWJlcg==');

@$core.Deprecated('Use getTeamMembersRequestDescriptor instead')
const GetTeamMembersRequest$json = {
  '1': 'GetTeamMembersRequest',
};

/// Descriptor for `GetTeamMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTeamMembersRequestDescriptor =
    $convert.base64Decode('ChVHZXRUZWFtTWVtYmVyc1JlcXVlc3Q=');

@$core.Deprecated('Use getTeamMembersResponseDescriptor instead')
const GetTeamMembersResponse$json = {
  '1': 'GetTeamMembersResponse',
  '2': [
    {
      '1': 'team_members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'teamMembers'
    },
  ],
};

/// Descriptor for `GetTeamMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTeamMembersResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRUZWFtTWVtYmVyc1Jlc3BvbnNlEj0KDHRlYW1fbWVtYmVycxgBIAMoCzIaLnRrLmFwaS'
        '5UZWFtTWVtYmVyUmVzcG9uc2VSC3RlYW1NZW1iZXJz');

@$core.Deprecated('Use getStudentsRequestDescriptor instead')
const GetStudentsRequest$json = {
  '1': 'GetStudentsRequest',
};

/// Descriptor for `GetStudentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStudentsRequestDescriptor =
    $convert.base64Decode('ChJHZXRTdHVkZW50c1JlcXVlc3Q=');

@$core.Deprecated('Use getStudentsResponseDescriptor instead')
const GetStudentsResponse$json = {
  '1': 'GetStudentsResponse',
  '2': [
    {
      '1': 'students',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'students'
    },
  ],
};

/// Descriptor for `GetStudentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStudentsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTdHVkZW50c1Jlc3BvbnNlEjYKCHN0dWRlbnRzGAEgAygLMhoudGsuYXBpLlRlYW1NZW'
    '1iZXJSZXNwb25zZVIIc3R1ZGVudHM=');

@$core.Deprecated('Use getMentorsRequestDescriptor instead')
const GetMentorsRequest$json = {
  '1': 'GetMentorsRequest',
};

/// Descriptor for `GetMentorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMentorsRequestDescriptor =
    $convert.base64Decode('ChFHZXRNZW50b3JzUmVxdWVzdA==');

@$core.Deprecated('Use getMentorsResponseDescriptor instead')
const GetMentorsResponse$json = {
  '1': 'GetMentorsResponse',
  '2': [
    {
      '1': 'mentors',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'mentors'
    },
  ],
};

/// Descriptor for `GetMentorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMentorsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRNZW50b3JzUmVzcG9uc2USNAoHbWVudG9ycxgBIAMoCzIaLnRrLmFwaS5UZWFtTWVtYm'
    'VyUmVzcG9uc2VSB21lbnRvcnM=');

@$core.Deprecated('Use streamTeamMembersRequestDescriptor instead')
const StreamTeamMembersRequest$json = {
  '1': 'StreamTeamMembersRequest',
};

/// Descriptor for `StreamTeamMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamMembersRequestDescriptor =
    $convert.base64Decode('ChhTdHJlYW1UZWFtTWVtYmVyc1JlcXVlc3Q=');

@$core.Deprecated('Use streamTeamMembersResponseDescriptor instead')
const StreamTeamMembersResponse$json = {
  '1': 'StreamTeamMembersResponse',
  '2': [
    {
      '1': 'team_members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'teamMembers'
    },
  ],
};

/// Descriptor for `StreamTeamMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamTeamMembersResponseDescriptor =
    $convert.base64Decode(
        'ChlTdHJlYW1UZWFtTWVtYmVyc1Jlc3BvbnNlEj0KDHRlYW1fbWVtYmVycxgBIAMoCzIaLnRrLm'
        'FwaS5UZWFtTWVtYmVyUmVzcG9uc2VSC3RlYW1NZW1iZXJz');

@$core.Deprecated('Use streamStudentsRequestDescriptor instead')
const StreamStudentsRequest$json = {
  '1': 'StreamStudentsRequest',
};

/// Descriptor for `StreamStudentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamStudentsRequestDescriptor =
    $convert.base64Decode('ChVTdHJlYW1TdHVkZW50c1JlcXVlc3Q=');

@$core.Deprecated('Use streamStudentsResponseDescriptor instead')
const StreamStudentsResponse$json = {
  '1': 'StreamStudentsResponse',
  '2': [
    {
      '1': 'students',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'students'
    },
  ],
};

/// Descriptor for `StreamStudentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamStudentsResponseDescriptor =
    $convert.base64Decode(
        'ChZTdHJlYW1TdHVkZW50c1Jlc3BvbnNlEjYKCHN0dWRlbnRzGAEgAygLMhoudGsuYXBpLlRlYW'
        '1NZW1iZXJSZXNwb25zZVIIc3R1ZGVudHM=');

@$core.Deprecated('Use streamMentorsRequestDescriptor instead')
const StreamMentorsRequest$json = {
  '1': 'StreamMentorsRequest',
};

/// Descriptor for `StreamMentorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMentorsRequestDescriptor =
    $convert.base64Decode('ChRTdHJlYW1NZW50b3JzUmVxdWVzdA==');

@$core.Deprecated('Use streamMentorsResponseDescriptor instead')
const StreamMentorsResponse$json = {
  '1': 'StreamMentorsResponse',
  '2': [
    {
      '1': 'mentors',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.TeamMemberResponse',
      '10': 'mentors'
    },
  ],
};

/// Descriptor for `StreamMentorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamMentorsResponseDescriptor = $convert.base64Decode(
    'ChVTdHJlYW1NZW50b3JzUmVzcG9uc2USNAoHbWVudG9ycxgBIAMoCzIaLnRrLmFwaS5UZWFtTW'
    'VtYmVyUmVzcG9uc2VSB21lbnRvcnM=');
