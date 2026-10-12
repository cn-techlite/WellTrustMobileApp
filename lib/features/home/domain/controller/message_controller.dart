import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/home/data/model/message_thread.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/message_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/message_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/message_state.dart';

class MessageController extends Notifier<MessageState> {
  late final MessageRepository _repository;

  @override
  MessageState build() {
    _repository = ref.read(messageRepositoryProvider);
    if (hasActiveSession) unawaited(_loadInitial());
    return const MessageState();
  }

  Future<void> _loadInitial() async {
    try {
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = MessageState(threads: await _repository.getMessages());
  }

  MessageThread? thread(String id) {
    for (final thread in state.threads) {
      if (thread.id == id) return thread;
    }
    return null;
  }

  Future<void> markRead(String id) async {
    final existing = thread(id);
    final unreadEntry = existing?.entries
        .where((entry) => !entry.mine)
        .lastOrNull;
    state = MessageState(
      threads: [
        for (final thread in state.threads)
          if (thread.id == id) thread.copyWith(unread: false) else thread,
      ],
    );
    if (hasActiveSession && unreadEntry != null && unreadEntry.id.isNotEmpty) {
      try {
        await _repository.markRead(unreadEntry.id);
      } catch (_) {}
    }
  }

  Future<void> reply(String id, String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final existing = thread(id);
    if (existing == null) return;
    if (!hasActiveSession) throw StateError('You must be signed in.');
    await _repository.send(
      subject: existing.subject,
      message: text,
      recipientGroup: existing.party,
      threadId: existing.id,
    );
    state = MessageState(
      threads: [
        for (final thread in state.threads)
          if (thread.id == id)
            thread.copyWith(
              unread: false,
              entries: [
                ...thread.entries,
                MessageEntry(body: text, at: DateTime.now(), mine: true),
              ],
            )
          else
            thread,
      ],
    );
  }

  Future<String> compose({
    required String to,
    required String subject,
    required String body,
  }) async {
    if (!hasActiveSession) throw StateError('You must be signed in.');
    final saved = await _repository.send(
      subject: subject.trim(),
      message: body.trim(),
      recipientGroup: to,
    );
    state = MessageState(
      threads: [
        MessageThread(
          id: saved.id,
          party: to,
          subject: subject.trim(),
          unread: false,
          entries: [
            MessageEntry(body: body.trim(), at: DateTime.now(), mine: true),
          ],
        ),
        ...state.threads,
      ],
    );
    return saved.id;
  }
}
