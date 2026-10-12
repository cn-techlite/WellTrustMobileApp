import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/home/data/repository/message_repository_impl.dart';
import 'package:well_trust_mobile_app/features/home/data/service/message_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/message_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/message_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/message_state.dart';

final messageRemoteServiceProvider = Provider<MessageRemoteService>((ref) {
  return MessageRemoteService();
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(
    remoteService: ref.read(messageRemoteServiceProvider),
  );
});

final messagesProvider = NotifierProvider<MessageController, MessageState>(
  MessageController.new,
);

final unreadMessageCountProvider = Provider<int>(
  (ref) => ref
      .watch(messagesProvider)
      .threads
      .where((thread) => thread.unread)
      .length,
);
