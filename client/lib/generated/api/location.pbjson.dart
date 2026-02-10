// This is a generated file - do not edit.
//
// Generated from api/location.proto.

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

@$core.Deprecated('Use locationResponseDescriptor instead')
const LocationResponse$json = {
  '1': 'LocationResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
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

/// Descriptor for `LocationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationResponseDescriptor = $convert.base64Decode(
    'ChBMb2NhdGlvblJlc3BvbnNlEg4KAmlkGAEgASgJUgJpZBIrCghsb2NhdGlvbhgCIAEoCzIPLn'
    'RrLmRiLkxvY2F0aW9uUghsb2NhdGlvbg==');

@$core.Deprecated('Use getLocationsRequestDescriptor instead')
const GetLocationsRequest$json = {
  '1': 'GetLocationsRequest',
};

/// Descriptor for `GetLocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLocationsRequestDescriptor =
    $convert.base64Decode('ChNHZXRMb2NhdGlvbnNSZXF1ZXN0');

@$core.Deprecated('Use getLocationsResponseDescriptor instead')
const GetLocationsResponse$json = {
  '1': 'GetLocationsResponse',
  '2': [
    {
      '1': 'locations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.LocationResponse',
      '10': 'locations'
    },
  ],
};

/// Descriptor for `GetLocationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLocationsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRMb2NhdGlvbnNSZXNwb25zZRI2Cglsb2NhdGlvbnMYASADKAsyGC50ay5hcGkuTG9jYX'
    'Rpb25SZXNwb25zZVIJbG9jYXRpb25z');

@$core.Deprecated('Use streamLocationsRequestDescriptor instead')
const StreamLocationsRequest$json = {
  '1': 'StreamLocationsRequest',
};

/// Descriptor for `StreamLocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamLocationsRequestDescriptor =
    $convert.base64Decode('ChZTdHJlYW1Mb2NhdGlvbnNSZXF1ZXN0');

@$core.Deprecated('Use streamLocationsResponseDescriptor instead')
const StreamLocationsResponse$json = {
  '1': 'StreamLocationsResponse',
  '2': [
    {
      '1': 'locations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.LocationResponse',
      '10': 'locations'
    },
  ],
};

/// Descriptor for `StreamLocationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamLocationsResponseDescriptor =
    $convert.base64Decode(
        'ChdTdHJlYW1Mb2NhdGlvbnNSZXNwb25zZRI2Cglsb2NhdGlvbnMYASADKAsyGC50ay5hcGkuTG'
        '9jYXRpb25SZXNwb25zZVIJbG9jYXRpb25z');
