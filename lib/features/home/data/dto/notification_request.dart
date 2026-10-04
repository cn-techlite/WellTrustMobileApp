class NotificationRequest {
  final String title;
  final String body;
  final String notificationType;
  final String deviceToken;
  final String? recipientId;

  const NotificationRequest({
    required this.title,
    required this.body,
    required this.notificationType,
    required this.deviceToken,
    this.recipientId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'deviceToken': deviceToken,
    'notificationType': notificationType,
    if (recipientId != null) 'riderId': recipientId,
  };
}
