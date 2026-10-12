import 'package:well_trust_mobile_app/features/home/data/model/message_thread.dart';

abstract class MessageRepository {
  Future<List<MessageThread>> getMessages({bool archived = false});
  Future<MessageThread> send({
    required String subject,
    required String message,
    required String recipientGroup,
    String? threadId,
  });
  Future<void> markRead(String messageId);
}
