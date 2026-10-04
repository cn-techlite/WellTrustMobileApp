import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';

abstract class CareNoteRepository {
  Future<List<CareNoteEntry>> getCareNotes({String? clientId});
  Future<CareNoteEntry> create(CareNoteEntry note);
}
