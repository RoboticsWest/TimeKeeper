// This is a generated file - do not edit.
//
// Generated from api/user.proto.

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

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGA'
    'IgASgJUghwYXNzd29yZA==');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'roles',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.tk.common.Role',
      '10': 'roles'
    },
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbhIlCgVyb2xlcxgCIAMoDjIPLn'
    'RrLmNvbW1vbi5Sb2xlUgVyb2xlcw==');

@$core.Deprecated('Use validateTokenRequestDescriptor instead')
const ValidateTokenRequest$json = {
  '1': 'ValidateTokenRequest',
};

/// Descriptor for `ValidateTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateTokenRequestDescriptor =
    $convert.base64Decode('ChRWYWxpZGF0ZVRva2VuUmVxdWVzdA==');

@$core.Deprecated('Use validateTokenResponseDescriptor instead')
const ValidateTokenResponse$json = {
  '1': 'ValidateTokenResponse',
};

/// Descriptor for `ValidateTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateTokenResponseDescriptor =
    $convert.base64Decode('ChVWYWxpZGF0ZVRva2VuUmVzcG9uc2U=');

@$core.Deprecated('Use updateAdminPasswordRequestDescriptor instead')
const UpdateAdminPasswordRequest$json = {
  '1': 'UpdateAdminPasswordRequest',
  '2': [
    {'1': 'password', '3': 1, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `UpdateAdminPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateAdminPasswordRequestDescriptor =
    $convert.base64Decode(
        'ChpVcGRhdGVBZG1pblBhc3N3b3JkUmVxdWVzdBIaCghwYXNzd29yZBgBIAEoCVIIcGFzc3dvcm'
        'Q=');

@$core.Deprecated('Use updateAdminPasswordResponseDescriptor instead')
const UpdateAdminPasswordResponse$json = {
  '1': 'UpdateAdminPasswordResponse',
};

/// Descriptor for `UpdateAdminPasswordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateAdminPasswordResponseDescriptor =
    $convert.base64Decode('ChtVcGRhdGVBZG1pblBhc3N3b3JkUmVzcG9uc2U=');

@$core.Deprecated('Use userResponseDescriptor instead')
const UserResponse$json = {
  '1': 'UserResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
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

/// Descriptor for `UserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userResponseDescriptor = $convert.base64Decode(
    'CgxVc2VyUmVzcG9uc2USDgoCaWQYASABKAlSAmlkEhoKCHVzZXJuYW1lGAIgASgJUgh1c2Vybm'
    'FtZRIlCgVyb2xlcxgDIAMoDjIPLnRrLmNvbW1vbi5Sb2xlUgVyb2xlcw==');

@$core.Deprecated('Use streamUsersRequestDescriptor instead')
const StreamUsersRequest$json = {
  '1': 'StreamUsersRequest',
};

/// Descriptor for `StreamUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamUsersRequestDescriptor =
    $convert.base64Decode('ChJTdHJlYW1Vc2Vyc1JlcXVlc3Q=');

@$core.Deprecated('Use streamUsersResponseDescriptor instead')
const StreamUsersResponse$json = {
  '1': 'StreamUsersResponse',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.UserResponse',
      '10': 'users'
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

/// Descriptor for `StreamUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamUsersResponseDescriptor = $convert.base64Decode(
    'ChNTdHJlYW1Vc2Vyc1Jlc3BvbnNlEioKBXVzZXJzGAEgAygLMhQudGsuYXBpLlVzZXJSZXNwb2'
    '5zZVIFdXNlcnMSMAoJc3luY190eXBlGAIgASgOMhMudGsuY29tbW9uLlN5bmNUeXBlUghzeW5j'
    'VHlwZQ==');

@$core.Deprecated('Use createUserRequestDescriptor instead')
const CreateUserRequest$json = {
  '1': 'CreateUserRequest',
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

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVVc2VyUmVxdWVzdBIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3'
    'dvcmQYAiABKAlSCHBhc3N3b3JkEiUKBXJvbGVzGAMgAygOMg8udGsuY29tbW9uLlJvbGVSBXJv'
    'bGVz');

@$core.Deprecated('Use createUserResponseDescriptor instead')
const CreateUserResponse$json = {
  '1': 'CreateUserResponse',
};

/// Descriptor for `CreateUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserResponseDescriptor =
    $convert.base64Decode('ChJDcmVhdGVVc2VyUmVzcG9uc2U=');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
    {
      '1': 'roles',
      '3': 4,
      '4': 3,
      '5': 14,
      '6': '.tk.common.Role',
      '10': 'roles'
    },
  ],
};

/// Descriptor for `UpdateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVVc2VyUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGgoIdXNlcm5hbWUYAiABKAlSCH'
    'VzZXJuYW1lEhoKCHBhc3N3b3JkGAMgASgJUghwYXNzd29yZBIlCgVyb2xlcxgEIAMoDjIPLnRr'
    'LmNvbW1vbi5Sb2xlUgVyb2xlcw==');

@$core.Deprecated('Use updateUserResponseDescriptor instead')
const UpdateUserResponse$json = {
  '1': 'UpdateUserResponse',
};

/// Descriptor for `UpdateUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserResponseDescriptor =
    $convert.base64Decode('ChJVcGRhdGVVc2VyUmVzcG9uc2U=');

@$core.Deprecated('Use deleteUserRequestDescriptor instead')
const DeleteUserRequest$json = {
  '1': 'DeleteUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteUserRequestDescriptor =
    $convert.base64Decode('ChFEZWxldGVVc2VyUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteUserResponseDescriptor instead')
const DeleteUserResponse$json = {
  '1': 'DeleteUserResponse',
};

/// Descriptor for `DeleteUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteUserResponseDescriptor =
    $convert.base64Decode('ChJEZWxldGVVc2VyUmVzcG9uc2U=');
