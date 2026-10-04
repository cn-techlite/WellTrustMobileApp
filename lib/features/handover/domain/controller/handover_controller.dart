import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/handover/domain/usercases/handover_repository.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/state_model/handover_state.dart';

class HandoverController extends Notifier<HandoverState> {
  late final HandoverRepository _repository;

  @override
  HandoverState build() {
    _repository = ref.read(handoverRepositoryProvider);
    if (hasActiveSession) unawaited(_loadInitial());
    return const HandoverState();
  }

  Future<void> _loadInitial() async {
    try {
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh({String? clientId, bool? openOnly}) async {
    final entries = await _repository.getHandovers(
      clientId: clientId,
      openOnly: openOnly,
    );
    state = HandoverState(entries: entries, readAt: state.readAt);
  }

  Future<void> add(HandoverEntry entry) async {
    if (!hasActiveSession) throw StateError('You must be signed in.');
    final saved = await _repository.create(entry);
    state = HandoverState(
      entries: [...state.entries, saved],
      readAt: state.readAt,
    );
  }

  Future<void> markDone(String id, String who, {String note = ''}) async {
    if (!hasActiveSession) throw StateError('You must be signed in.');
    final saved = await _repository.resolve(id, note);
    state = HandoverState(
      entries: [
        for (final entry in state.entries)
          if (entry.id == id) saved else entry,
      ],
      readAt: state.readAt,
    );
  }

  Future<void> markRead(String clientId) async {
    state = HandoverState(
      entries: state.entries,
      readAt: {...state.readAt, clientId: DateTime.now()},
    );
    if (!hasActiveSession) return;
    try {
      await _repository.markRead(clientId);
    } catch (_) {}
  }
}
