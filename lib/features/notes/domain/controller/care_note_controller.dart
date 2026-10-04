import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/domain/usercases/care_note_repository.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/providers/care_note_provider.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/state_model/care_note_state.dart';

class CareNoteController extends Notifier<CareNoteState> {
  late final CareNoteRepository _repository;

  @override
  CareNoteState build() {
    _repository = ref.read(careNoteRepositoryProvider);
    if (hasActiveSession) unawaited(_loadInitial());
    return const CareNoteState();
  }

  Future<void> _loadInitial() async {
    try {
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh({String? clientId}) async {
    state = CareNoteState(
      notes: await _repository.getCareNotes(clientId: clientId),
    );
  }

  Future<CareNoteEntry> add(CareNoteEntry note) async {
    if (!hasActiveSession) throw StateError('You must be signed in.');
    final saved = await _repository.create(note);
    state = CareNoteState(notes: [saved, ...state.notes]);
    return saved;
  }
}
