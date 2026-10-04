import 'package:well_trust_mobile_app/features/notes/data/dto/create_care_note_request.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/data/service/care_note_remote_service.dart';
import 'package:well_trust_mobile_app/features/notes/domain/usercases/care_note_repository.dart';

class CareNoteRepositoryImpl implements CareNoteRepository {
  final CareNoteRemoteService _remoteService;

  const CareNoteRepositoryImpl({required CareNoteRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<CareNoteEntry>> getCareNotes({String? clientId}) =>
      _remoteService.getCareNotes(clientId: clientId);

  @override
  Future<CareNoteEntry> create(CareNoteEntry note) =>
      _remoteService.create(CreateCareNoteRequest(note));
}
