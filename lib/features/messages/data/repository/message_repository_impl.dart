import 'package:well_trust_mobile_app/features/messages/data/dto/send_message_request.dart';
import 'package:well_trust_mobile_app/features/messages/data/model/message_thread.dart';
import 'package:well_trust_mobile_app/features/messages/data/service/message_remote_service.dart';
import 'package:well_trust_mobile_app/features/messages/domain/usercases/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteService _remoteService;

  const MessageRepositoryImpl({required MessageRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<MessageThread>> getMessages({bool archived = false}) =>
      _remoteService.getMessages(archived: archived);

  @override
  Future<MessageThread> send({
    required String subject,
    required String message,
    required String recipientGroup,
    String? threadId,
  }) => _remoteService.send(
    SendMessageRequest(
      subject: subject,
      message: message,
      recipientGroup: recipientGroup,
      threadId: threadId,
    ),
  );

  @override
  Future<void> markRead(String messageId) => _remoteService.markRead(messageId);
}
