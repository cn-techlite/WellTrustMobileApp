class SendMessageRequest {
  final String subject;
  final String message;
  final String recipientGroup;
  final String? threadId;

  const SendMessageRequest({
    required this.subject,
    required this.message,
    required this.recipientGroup,
    this.threadId,
  });

  Map<String, dynamic> toJson() => {
    'receiverId': null,
    'subject': subject,
    'message': message,
    'recipientGroup': recipientGroup,
    'threadId': threadId,
    'messageType': 'Group',
    'contentType': 'Text',
    'fileUrl': null,
    'fileName': null,
    'fileExtension': null,
    'fileSizeBytes': null,
  };
}
