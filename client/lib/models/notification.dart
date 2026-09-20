import 'package:time_keeper/utils/time_utils.dart';

class Notification {
  final String id;
  final String notificationType;
  final String sessionId;
  final String? teamMemberId;
  final String? discordMessageId;

  /// When this is due. Null for kinds that fire on a condition rather than a clock.
  final DateTime? scheduledFor;
  final DateTime? sentAt;

  /// One of [NotificationStatus].
  ///
  /// Replaces the old `sent` boolean. "Should this be sent?" used to be answered by the
  /// *absence* of a row, so deleting one re-armed it; a row now always exists and always
  /// records what became of it.
  final String status;

  Notification({
    required this.id,
    required this.notificationType,
    required this.sessionId,
    this.teamMemberId,
    this.discordMessageId,
    this.scheduledFor,
    this.sentAt,
    required this.status,
  });

  bool get isPending => status == NotificationStatus.pending;
  bool get isSent => status == NotificationStatus.sent;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      notificationType: json['notificationType'] as String,
      sessionId: json['sessionId'] as String,
      teamMemberId: json['teamMemberId'] as String?,
      discordMessageId: json['discordMessageId'] as String?,
      scheduledFor: parseServerTimeOrNull(json['scheduledFor']),
      sentAt: parseServerTimeOrNull(json['sentAt']),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'notificationType': notificationType,
    'sessionId': sessionId,
    'teamMemberId': teamMemberId,
    'discordMessageId': discordMessageId,
    'scheduledFor': toServerTimeOrNull(scheduledFor),
    'sentAt': toServerTimeOrNull(sentAt),
    'status': status,
  };
}

/// Matches the `notifications.notification_type` CHECK constraint on the server.
class NotificationType {
  static const sessionStartReminder = 'session_start_reminder';
  static const sessionEndReminder = 'session_end_reminder';
  static const overtime = 'overtime';
  static const autoCheckout = 'auto_checkout';

  static const all = [sessionStartReminder, sessionEndReminder, overtime, autoCheckout];

  static const _labels = {
    sessionStartReminder: 'Session Start Reminder',
    sessionEndReminder: 'Session End Reminder',
    overtime: 'Overtime',
    autoCheckout: 'Auto Checkout',
  };

  static String label(String type) => _labels[type] ?? 'Unknown';
}

/// Matches the `notifications_status_check` constraint on the server.
class NotificationStatus {
  static const pending = 'pending';
  static const sent = 'sent';

  /// The reminder's window had already elapsed when the session was created, and the operator
  /// chose not to fire it late.
  static const skipped = 'skipped';

  /// Switched off by a user. Distinct from [skipped] so the UI can say which.
  static const cancelled = 'cancelled';
  static const failed = 'failed';

  static const all = [pending, sent, skipped, cancelled, failed];

  static String label(String status) {
    switch (status) {
      case pending:
        return 'Scheduled';
      case sent:
        return 'Sent';
      case skipped:
        return 'Skipped';
      case cancelled:
        return 'Cancelled';
      case failed:
        return 'Failed';
      default:
        return status;
    }
  }
}
