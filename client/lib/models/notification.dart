class Notification {
  final String id;
  final String notificationType;
  final String sessionId;
  final String? teamMemberId;
  final bool sent;
  final String? discordMessageId;

  Notification({
    required this.id,
    required this.notificationType,
    required this.sessionId,
    this.teamMemberId,
    required this.sent,
    this.discordMessageId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      notificationType: json['notificationType'] as String,
      sessionId: json['sessionId'] as String,
      teamMemberId: json['teamMemberId'] as String?,
      sent: json['sent'] as bool,
      discordMessageId: json['discordMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'notificationType': notificationType,
    'sessionId': sessionId,
    'teamMemberId': teamMemberId,
    'sent': sent,
    'discordMessageId': discordMessageId,
  };
}

/// Matches the `notifications.notification_type` CHECK constraint on the server.
class NotificationType {
  static const sessionStartReminder = 'session_start_reminder';
  static const sessionEndReminder = 'session_end_reminder';
  static const overtime = 'overtime';
  static const autoCheckout = 'auto_checkout';
}
