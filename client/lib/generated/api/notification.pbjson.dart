// This is a generated file - do not edit.
//
// Generated from api/notification.proto.

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

@$core.Deprecated('Use notificationResponseDescriptor instead')
const NotificationResponse$json = {
  '1': 'NotificationResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'notification',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tk.db.Notification',
      '10': 'notification'
    },
  ],
};

/// Descriptor for `NotificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationResponseDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25SZXNwb25zZRIOCgJpZBgBIAEoCVICaWQSNwoMbm90aWZpY2F0aW9uGA'
    'IgASgLMhMudGsuZGIuTm90aWZpY2F0aW9uUgxub3RpZmljYXRpb24=');

@$core.Deprecated('Use getNotificationsRequestDescriptor instead')
const GetNotificationsRequest$json = {
  '1': 'GetNotificationsRequest',
};

/// Descriptor for `GetNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationsRequestDescriptor =
    $convert.base64Decode('ChdHZXROb3RpZmljYXRpb25zUmVxdWVzdA==');

@$core.Deprecated('Use getNotificationsResponseDescriptor instead')
const GetNotificationsResponse$json = {
  '1': 'GetNotificationsResponse',
  '2': [
    {
      '1': 'notifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.NotificationResponse',
      '10': 'notifications'
    },
  ],
};

/// Descriptor for `GetNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationsResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXROb3RpZmljYXRpb25zUmVzcG9uc2USQgoNbm90aWZpY2F0aW9ucxgBIAMoCzIcLnRrLm'
        'FwaS5Ob3RpZmljYXRpb25SZXNwb25zZVINbm90aWZpY2F0aW9ucw==');

@$core.Deprecated('Use streamNotificationsRequestDescriptor instead')
const StreamNotificationsRequest$json = {
  '1': 'StreamNotificationsRequest',
};

/// Descriptor for `StreamNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamNotificationsRequestDescriptor =
    $convert.base64Decode('ChpTdHJlYW1Ob3RpZmljYXRpb25zUmVxdWVzdA==');

@$core.Deprecated('Use streamNotificationsResponseDescriptor instead')
const StreamNotificationsResponse$json = {
  '1': 'StreamNotificationsResponse',
  '2': [
    {
      '1': 'notifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tk.api.NotificationResponse',
      '10': 'notifications'
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

/// Descriptor for `StreamNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamNotificationsResponseDescriptor =
    $convert.base64Decode(
        'ChtTdHJlYW1Ob3RpZmljYXRpb25zUmVzcG9uc2USQgoNbm90aWZpY2F0aW9ucxgBIAMoCzIcLn'
        'RrLmFwaS5Ob3RpZmljYXRpb25SZXNwb25zZVINbm90aWZpY2F0aW9ucxIwCglzeW5jX3R5cGUY'
        'AiABKA4yEy50ay5jb21tb24uU3luY1R5cGVSCHN5bmNUeXBl');

@$core.Deprecated('Use createNotificationRequestDescriptor instead')
const CreateNotificationRequest$json = {
  '1': 'CreateNotificationRequest',
  '2': [
    {
      '1': 'notification_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.tk.db.NotificationType',
      '10': 'notificationType'
    },
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'team_member_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'teamMemberId',
      '17': true
    },
    {'1': 'sent', '3': 4, '4': 1, '5': 8, '10': 'sent'},
  ],
  '8': [
    {'1': '_team_member_id'},
  ],
};

/// Descriptor for `CreateNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNotificationRequestDescriptor = $convert.base64Decode(
    'ChlDcmVhdGVOb3RpZmljYXRpb25SZXF1ZXN0EkQKEW5vdGlmaWNhdGlvbl90eXBlGAEgASgOMh'
    'cudGsuZGIuTm90aWZpY2F0aW9uVHlwZVIQbm90aWZpY2F0aW9uVHlwZRIdCgpzZXNzaW9uX2lk'
    'GAIgASgJUglzZXNzaW9uSWQSKQoOdGVhbV9tZW1iZXJfaWQYAyABKAlIAFIMdGVhbU1lbWJlck'
    'lkiAEBEhIKBHNlbnQYBCABKAhSBHNlbnRCEQoPX3RlYW1fbWVtYmVyX2lk');

@$core.Deprecated('Use createNotificationResponseDescriptor instead')
const CreateNotificationResponse$json = {
  '1': 'CreateNotificationResponse',
};

/// Descriptor for `CreateNotificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNotificationResponseDescriptor =
    $convert.base64Decode('ChpDcmVhdGVOb3RpZmljYXRpb25SZXNwb25zZQ==');

@$core.Deprecated('Use updateNotificationRequestDescriptor instead')
const UpdateNotificationRequest$json = {
  '1': 'UpdateNotificationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'notification_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tk.db.NotificationType',
      '10': 'notificationType'
    },
    {'1': 'session_id', '3': 3, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'team_member_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'teamMemberId',
      '17': true
    },
    {'1': 'sent', '3': 5, '4': 1, '5': 8, '10': 'sent'},
  ],
  '8': [
    {'1': '_team_member_id'},
  ],
};

/// Descriptor for `UpdateNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationRequestDescriptor = $convert.base64Decode(
    'ChlVcGRhdGVOb3RpZmljYXRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBJEChFub3RpZmljYX'
    'Rpb25fdHlwZRgCIAEoDjIXLnRrLmRiLk5vdGlmaWNhdGlvblR5cGVSEG5vdGlmaWNhdGlvblR5'
    'cGUSHQoKc2Vzc2lvbl9pZBgDIAEoCVIJc2Vzc2lvbklkEikKDnRlYW1fbWVtYmVyX2lkGAQgAS'
    'gJSABSDHRlYW1NZW1iZXJJZIgBARISCgRzZW50GAUgASgIUgRzZW50QhEKD190ZWFtX21lbWJl'
    'cl9pZA==');

@$core.Deprecated('Use updateNotificationResponseDescriptor instead')
const UpdateNotificationResponse$json = {
  '1': 'UpdateNotificationResponse',
};

/// Descriptor for `UpdateNotificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationResponseDescriptor =
    $convert.base64Decode('ChpVcGRhdGVOb3RpZmljYXRpb25SZXNwb25zZQ==');

@$core.Deprecated('Use deleteNotificationRequestDescriptor instead')
const DeleteNotificationRequest$json = {
  '1': 'DeleteNotificationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteNotificationRequestDescriptor =
    $convert.base64Decode(
        'ChlEZWxldGVOb3RpZmljYXRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use deleteNotificationResponseDescriptor instead')
const DeleteNotificationResponse$json = {
  '1': 'DeleteNotificationResponse',
};

/// Descriptor for `DeleteNotificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteNotificationResponseDescriptor =
    $convert.base64Decode('ChpEZWxldGVOb3RpZmljYXRpb25SZXNwb25zZQ==');
