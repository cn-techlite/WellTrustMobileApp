import 'package:intl/intl.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';

class CreateCareNoteRequest {
  final CareNoteEntry note;

  const CreateCareNoteRequest(this.note);

  Map<String, dynamic> toJson() => {
    'clientId': note.clientId,
    'text': note.text,
    if (note.mood.isNotEmpty) 'mood': note.mood,
    if (note.intake.isNotEmpty) 'intake': note.intake,
    if (note.skin.isNotEmpty) 'skin': note.skin,
    'flagged': note.flagged,
    'tags': note.tags,
    if (note.visitDate != null)
      'visitDate': DateFormat('yyyy-MM-dd').format(note.visitDate!),
    if (note.startTime != null) 'startTime': note.startTime,
    if (note.endTime != null) 'endTime': note.endTime,
    if (note.supportType != null) 'supportType': note.supportType,
    if (note.outcome != null) 'outcome': note.outcome,
  };
}
