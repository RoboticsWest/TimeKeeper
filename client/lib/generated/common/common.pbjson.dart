// This is a generated file - do not edit.
//
// Generated from common/common.proto.

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

@$core.Deprecated('Use roleDescriptor instead')
const Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'ADMIN', '2': 0},
    {'1': 'KIOSK', '2': 1},
    {'1': 'STUDENT', '2': 2},
    {'1': 'MENTOR', '2': 3},
  ],
};

/// Descriptor for `Role`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List roleDescriptor = $convert.base64Decode(
    'CgRSb2xlEgkKBUFETUlOEAASCQoFS0lPU0sQARILCgdTVFVERU5UEAISCgoGTUVOVE9SEAM=');

@$core.Deprecated('Use timestampDescriptor instead')
const Timestamp$json = {
  '1': 'Timestamp',
  '2': [
    {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

/// Descriptor for `Timestamp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampDescriptor = $convert.base64Decode(
    'CglUaW1lc3RhbXASGAoHc2Vjb25kcxgBIAEoA1IHc2Vjb25kcxIUCgVuYW5vcxgCIAEoBVIFbm'
    'Fub3M=');

@$core.Deprecated('Use tkDateDescriptor instead')
const TkDate$json = {
  '1': 'TkDate',
  '2': [
    {'1': 'year', '3': 1, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 2, '4': 1, '5': 13, '10': 'month'},
    {'1': 'day', '3': 3, '4': 1, '5': 13, '10': 'day'},
  ],
};

/// Descriptor for `TkDate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tkDateDescriptor = $convert.base64Decode(
    'CgZUa0RhdGUSEgoEeWVhchgBIAEoBVIEeWVhchIUCgVtb250aBgCIAEoDVIFbW9udGgSEAoDZG'
    'F5GAMgASgNUgNkYXk=');

@$core.Deprecated('Use tkTimeDescriptor instead')
const TkTime$json = {
  '1': 'TkTime',
  '2': [
    {'1': 'hour', '3': 1, '4': 1, '5': 13, '10': 'hour'},
    {'1': 'minute', '3': 2, '4': 1, '5': 13, '10': 'minute'},
    {'1': 'second', '3': 3, '4': 1, '5': 13, '10': 'second'},
  ],
};

/// Descriptor for `TkTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tkTimeDescriptor = $convert.base64Decode(
    'CgZUa1RpbWUSEgoEaG91chgBIAEoDVIEaG91chIWCgZtaW51dGUYAiABKA1SBm1pbnV0ZRIWCg'
    'ZzZWNvbmQYAyABKA1SBnNlY29uZA==');

@$core.Deprecated('Use tkDateTimeDescriptor instead')
const TkDateTime$json = {
  '1': 'TkDateTime',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkDate',
      '9': 0,
      '10': 'date',
      '17': true
    },
    {
      '1': 'time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.common.TkTime',
      '9': 1,
      '10': 'time',
      '17': true
    },
  ],
  '8': [
    {'1': '_date'},
    {'1': '_time'},
  ],
};

/// Descriptor for `TkDateTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tkDateTimeDescriptor = $convert.base64Decode(
    'CgpUa0RhdGVUaW1lEioKBGRhdGUYASABKAsyES50ay5jb21tb24uVGtEYXRlSABSBGRhdGWIAQ'
    'ESKgoEdGltZRgCIAEoCzIRLnRrLmNvbW1vbi5Ua1RpbWVIAVIEdGltZYgBAUIHCgVfZGF0ZUIH'
    'CgVfdGltZQ==');
