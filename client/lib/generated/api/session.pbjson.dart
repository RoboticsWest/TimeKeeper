// This is a generated file - do not edit.
//
// Generated from api/session.proto.

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

@$core.Deprecated('Use sessionResponseDescriptor instead')
const SessionResponse$json = {
  '1': 'SessionResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'session',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.Session',
      '10': 'session'
    },
  ],
};

/// Descriptor for `SessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionResponseDescriptor = $convert.base64Decode(
    'Cg9TZXNzaW9uUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEigKB3Nlc3Npb24YAiABKAsyDi50ay'
    '5kYi5TZXNzaW9uUgdzZXNzaW9u');

@$core.Deprecated('Use getSessionsRequestDescriptor instead')
const GetSessionsRequest$json = {
  '1': 'GetSessionsRequest',
};

/// Descriptor for `GetSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionsRequestDescriptor =
    $convert.base64Decode('ChJHZXRTZXNzaW9uc1JlcXVlc3Q=');

@$core.Deprecated('Use getSessionsResponseDescriptor instead')
const GetSessionsResponse$json = {
  '1': 'GetSessionsResponse',
  '2': [
    {
      '1': 'sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.SessionResponse',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `GetSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTZXNzaW9uc1Jlc3BvbnNlEjMKCHNlc3Npb25zGAEgAygLMhcudGsuYXBpLlNlc3Npb2'
    '5SZXNwb25zZVIIc2Vzc2lvbnM=');

@$core.Deprecated('Use streamSessionsRequestDescriptor instead')
const StreamSessionsRequest$json = {
  '1': 'StreamSessionsRequest',
};

/// Descriptor for `StreamSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamSessionsRequestDescriptor =
    $convert.base64Decode('ChVTdHJlYW1TZXNzaW9uc1JlcXVlc3Q=');

@$core.Deprecated('Use streamSessionsResponseDescriptor instead')
const StreamSessionsResponse$json = {
  '1': 'StreamSessionsResponse',
  '2': [
    {
      '1': 'sessions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.SessionResponse',
      '10': 'sessions'
    },
  ],
};

/// Descriptor for `StreamSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamSessionsResponseDescriptor =
    $convert.base64Decode(
        'ChZTdHJlYW1TZXNzaW9uc1Jlc3BvbnNlEjMKCHNlc3Npb25zGAEgAygLMhcudGsuYXBpLlNlc3'
        'Npb25SZXNwb25zZVIIc2Vzc2lvbnM=');

@$core.Deprecated('Use checkInOutRequestDescriptor instead')
const CheckInOutRequest$json = {
  '1': 'CheckInOutRequest',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
    {
      '1': 'location',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.Location',
      '10': 'location'
    },
  ],
};

/// Descriptor for `CheckInOutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInOutRequestDescriptor = $convert.base64Decode(
    'ChFDaGVja0luT3V0UmVxdWVzdBIkCg50ZWFtX21lbWJlcl9pZBgBIAEoCVIMdGVhbU1lbWJlck'
    'lkEisKCGxvY2F0aW9uGAIgASgLMg8udGsuZGIuTG9jYXRpb25SCGxvY2F0aW9u');

@$core.Deprecated('Use checkInOutResponseDescriptor instead')
const CheckInOutResponse$json = {
  '1': 'CheckInOutResponse',
  '2': [
    {'1': 'checked_in', '3': 1, '4': 1, '5': 8, '10': 'checkedIn'},
  ],
};

/// Descriptor for `CheckInOutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkInOutResponseDescriptor =
    $convert.base64Decode(
        'ChJDaGVja0luT3V0UmVzcG9uc2USHQoKY2hlY2tlZF9pbhgBIAEoCFIJY2hlY2tlZElu');
