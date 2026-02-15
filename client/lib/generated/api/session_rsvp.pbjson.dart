// This is a generated file - do not edit.
//
// Generated from api/session_rsvp.proto.

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

@$core.Deprecated('Use sessionRsvpResponseDescriptor instead')
const SessionRsvpResponse$json = {
  '1': 'SessionRsvpResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'rsvp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.SessionRsvp',
      '10': 'rsvp'
    },
  ],
};

/// Descriptor for `SessionRsvpResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionRsvpResponseDescriptor = $convert.base64Decode(
    'ChNTZXNzaW9uUnN2cFJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZBImCgRyc3ZwGAIgASgLMhIudG'
    'suZGIuU2Vzc2lvblJzdnBSBHJzdnA=');

@$core.Deprecated('Use getSessionRsvpsRequestDescriptor instead')
const GetSessionRsvpsRequest$json = {
  '1': 'GetSessionRsvpsRequest',
};

/// Descriptor for `GetSessionRsvpsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionRsvpsRequestDescriptor =
    $convert.base64Decode('ChZHZXRTZXNzaW9uUnN2cHNSZXF1ZXN0');

@$core.Deprecated('Use getSessionRsvpsResponseDescriptor instead')
const GetSessionRsvpsResponse$json = {
  '1': 'GetSessionRsvpsResponse',
  '2': [
    {
      '1': 'rsvps',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.SessionRsvpResponse',
      '10': 'rsvps'
    },
  ],
};

/// Descriptor for `GetSessionRsvpsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionRsvpsResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRTZXNzaW9uUnN2cHNSZXNwb25zZRIxCgVyc3ZwcxgBIAMoCzIbLnRrLmFwaS5TZXNzaW'
        '9uUnN2cFJlc3BvbnNlUgVyc3Zwcw==');

@$core.Deprecated('Use streamSessionRsvpsRequestDescriptor instead')
const StreamSessionRsvpsRequest$json = {
  '1': 'StreamSessionRsvpsRequest',
};

/// Descriptor for `StreamSessionRsvpsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamSessionRsvpsRequestDescriptor =
    $convert.base64Decode('ChlTdHJlYW1TZXNzaW9uUnN2cHNSZXF1ZXN0');

@$core.Deprecated('Use streamSessionRsvpsResponseDescriptor instead')
const StreamSessionRsvpsResponse$json = {
  '1': 'StreamSessionRsvpsResponse',
  '2': [
    {
      '1': 'rsvps',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.SessionRsvpResponse',
      '10': 'rsvps'
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

/// Descriptor for `StreamSessionRsvpsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamSessionRsvpsResponseDescriptor =
    $convert.base64Decode(
        'ChpTdHJlYW1TZXNzaW9uUnN2cHNSZXNwb25zZRIxCgVyc3ZwcxgBIAMoCzIbLnRrLmFwaS5TZX'
        'NzaW9uUnN2cFJlc3BvbnNlUgVyc3ZwcxIwCglzeW5jX3R5cGUYAiABKA4yEy50ay5jb21tb24u'
        'U3luY1R5cGVSCHN5bmNUeXBl');
