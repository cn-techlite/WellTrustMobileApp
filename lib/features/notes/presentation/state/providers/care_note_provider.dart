import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/notes/data/repository/care_note_repository_impl.dart';
import 'package:well_trust_mobile_app/features/notes/data/service/care_note_remote_service.dart';
import 'package:well_trust_mobile_app/features/notes/domain/controller/care_note_controller.dart';
import 'package:well_trust_mobile_app/features/notes/domain/usercases/care_note_repository.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/state_model/care_note_state.dart';

final careNoteRemoteServiceProvider = Provider<CareNoteRemoteService>((ref) {
  return CareNoteRemoteService();
});

final careNoteRepositoryProvider = Provider<CareNoteRepository>((ref) {
  return CareNoteRepositoryImpl(
    remoteService: ref.read(careNoteRemoteServiceProvider),
  );
});

final careNotesProvider = NotifierProvider<CareNoteController, CareNoteState>(
  CareNoteController.new,
);
