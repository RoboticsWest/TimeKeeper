// This is a generated file - do not edit.
//
// Generated from api/rfid_tag.proto.

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

@$core.Deprecated('Use rfidTagResponseDescriptor instead')
const RfidTagResponse$json = {
  '1': 'RfidTagResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'rfid_tag',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.RfidTag',
      '10': 'rfidTag'
    },
  ],
};

/// Descriptor for `RfidTagResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rfidTagResponseDescriptor = $convert.base64Decode(
    'Cg9SZmlkVGFnUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEikKCHJmaWRfdGFnGAIgASgLMg4udG'
    'suZGIuUmZpZFRhZ1IHcmZpZFRhZw==');

@$core.Deprecated('Use getRfidTagsRequestDescriptor instead')
const GetRfidTagsRequest$json = {
  '1': 'GetRfidTagsRequest',
};

/// Descriptor for `GetRfidTagsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRfidTagsRequestDescriptor =
    $convert.base64Decode('ChJHZXRSZmlkVGFnc1JlcXVlc3Q=');

@$core.Deprecated('Use getRfidTagsResponseDescriptor instead')
const GetRfidTagsResponse$json = {
  '1': 'GetRfidTagsResponse',
  '2': [
    {
      '1': 'rfid_tags',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.RfidTagResponse',
      '10': 'rfidTags'
    },
  ],
};

/// Descriptor for `GetRfidTagsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRfidTagsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRSZmlkVGFnc1Jlc3BvbnNlEjQKCXJmaWRfdGFncxgBIAMoCzIXLnRrLmFwaS5SZmlkVG'
    'FnUmVzcG9uc2VSCHJmaWRUYWdz');

@$core.Deprecated('Use streamRfidTagsRequestDescriptor instead')
const StreamRfidTagsRequest$json = {
  '1': 'StreamRfidTagsRequest',
};

/// Descriptor for `StreamRfidTagsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamRfidTagsRequestDescriptor =
    $convert.base64Decode('ChVTdHJlYW1SZmlkVGFnc1JlcXVlc3Q=');

@$core.Deprecated('Use streamRfidTagsResponseDescriptor instead')
const StreamRfidTagsResponse$json = {
  '1': 'StreamRfidTagsResponse',
  '2': [
    {
      '1': 'rfid_tags',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.RfidTagResponse',
      '10': 'rfidTags'
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

/// Descriptor for `StreamRfidTagsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamRfidTagsResponseDescriptor = $convert.base64Decode(
    'ChZTdHJlYW1SZmlkVGFnc1Jlc3BvbnNlEjQKCXJmaWRfdGFncxgBIAMoCzIXLnRrLmFwaS5SZm'
    'lkVGFnUmVzcG9uc2VSCHJmaWRUYWdzEjAKCXN5bmNfdHlwZRgCIAEoDjITLnRrLmNvbW1vbi5T'
    'eW5jVHlwZVIIc3luY1R5cGU=');

@$core.Deprecated('Use createRfidTagRequestDescriptor instead')
const CreateRfidTagRequest$json = {
  '1': 'CreateRfidTagRequest',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
    {'1': 'tag', '3': 2, '4': 1, '5': 9, '10': 'tag'},
  ],
};

/// Descriptor for `CreateRfidTagRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRfidTagRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVSZmlkVGFnUmVxdWVzdBIkCg50ZWFtX21lbWJlcl9pZBgBIAEoCVIMdGVhbU1lbW'
    'JlcklkEhAKA3RhZxgCIAEoCVIDdGFn');

@$core.Deprecated('Use createRfidTagResponseDescriptor instead')
const CreateRfidTagResponse$json = {
  '1': 'CreateRfidTagResponse',
};

/// Descriptor for `CreateRfidTagResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRfidTagResponseDescriptor =
    $convert.base64Decode('ChVDcmVhdGVSZmlkVGFnUmVzcG9uc2U=');

@$core.Deprecated('Use deleteRfidTagRequestDescriptor instead')
const DeleteRfidTagRequest$json = {
  '1': 'DeleteRfidTagRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteRfidTagRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRfidTagRequestDescriptor = $convert
    .base64Decode('ChREZWxldGVSZmlkVGFnUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteRfidTagResponseDescriptor instead')
const DeleteRfidTagResponse$json = {
  '1': 'DeleteRfidTagResponse',
};

/// Descriptor for `DeleteRfidTagResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRfidTagResponseDescriptor =
    $convert.base64Decode('ChVEZWxldGVSZmlkVGFnUmVzcG9uc2U=');

@$core.Deprecated('Use deleteRfidTagsByMemberRequestDescriptor instead')
const DeleteRfidTagsByMemberRequest$json = {
  '1': 'DeleteRfidTagsByMemberRequest',
  '2': [
    {'1': 'team_member_id', '3': 1, '4': 1, '5': 9, '10': 'teamMemberId'},
  ],
};

/// Descriptor for `DeleteRfidTagsByMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRfidTagsByMemberRequestDescriptor =
    $convert.base64Decode(
        'Ch1EZWxldGVSZmlkVGFnc0J5TWVtYmVyUmVxdWVzdBIkCg50ZWFtX21lbWJlcl9pZBgBIAEoCV'
        'IMdGVhbU1lbWJlcklk');

@$core.Deprecated('Use deleteRfidTagsByMemberResponseDescriptor instead')
const DeleteRfidTagsByMemberResponse$json = {
  '1': 'DeleteRfidTagsByMemberResponse',
};

/// Descriptor for `DeleteRfidTagsByMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRfidTagsByMemberResponseDescriptor =
    $convert.base64Decode('Ch5EZWxldGVSZmlkVGFnc0J5TWVtYmVyUmVzcG9uc2U=');
