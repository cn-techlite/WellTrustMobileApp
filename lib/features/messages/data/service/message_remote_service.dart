import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/messages/data/dto/send_message_request.dart';
import 'package:well_trust_mobile_app/features/messages/data/model/message_thread.dart';

class MessageRemoteService {
  final MobileApiClient _api;

  MessageRemoteService({MobileApiClient? api})
    : _api = api ?? MobileApiClient();

  Future<List<MessageThread>> getMessages({bool archived = false}) async {
    final rows = _rows(
      await _api.get(
        Endpoints.messagesUrl,
        query: {'archived': archived.toString()},
      ),
    );
    final byThread = <String, List<MessageEntry>>{};
    final metadata = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final threadId = (row['threadId'] ?? row['id'] ?? '').toString();
      byThread.putIfAbsent(threadId, () => []).add(MessageEntry.fromJson(row));
      metadata[threadId] = row;
    }
    return [
      for (final entry in byThread.entries)
        MessageThread.fromMessages(
          entry.key,
          metadata[entry.key]!,
          entry.value..sort((a, b) => a.at.compareTo(b.at)),
        ),
    ];
  }

  Future<MessageThread> send(SendMessageRequest request) async {
    final row = _object(
      await _api.post(Endpoints.messagesUrl, body: request.toJson()),
    );
    return MessageThread.fromMessages(
      (row['threadId'] ?? row['id'] ?? '').toString(),
      row,
      [MessageEntry.fromJson(row)],
    );
  }

  Future<void> markRead(String messageId) async {
    await _api.put(Endpoints.markMessageRead(messageId));
  }

  List<Map<String, dynamic>> _rows(dynamic value) => [
    for (final item in (value is List ? value : const []))
      if (item is Map) Map<String, dynamic>.from(item),
  ];

  Map<String, dynamic> _object(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const MobileApiException(500, 'The server returned invalid data.');
  }
}
