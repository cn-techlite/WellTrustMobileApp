import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/notes/data/dto/create_care_note_request.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';

class CareNoteRemoteService {
  final MobileApiClient _api;

  CareNoteRemoteService({MobileApiClient? api})
    : _api = api ?? MobileApiClient();

  Future<List<CareNoteEntry>> getCareNotes({String? clientId}) async => [
    for (final row in _rows(
      await _api.get(Endpoints.careNotesUrl, query: {'clientId': clientId}),
    ))
      CareNoteEntry.fromJson(row),
  ];

  Future<CareNoteEntry> create(CreateCareNoteRequest request) async =>
      CareNoteEntry.fromJson(
        _object(
          await _api.post(Endpoints.careNotesUrl, body: request.toJson()),
        ),
      );

  List<Map<String, dynamic>> _rows(dynamic value) => [
    for (final item in (value is List ? value : const []))
      if (item is Map) Map<String, dynamic>.from(item),
  ];

  Map<String, dynamic> _object(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const MobileApiException(500, 'The server returned invalid data.');
  }
}
