import 'package:well_trust_mobile_app/features/home/data/model/message_thread.dart';

class MessageState {
  final List<MessageThread> threads;

  const MessageState({this.threads = const []});
}
