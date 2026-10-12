import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/home/data/model/meeting_model.dart';

class MeetingRemoteService {
  final MobileApiClient _api;

  MeetingRemoteService({MobileApiClient? api})
    : _api = api ?? MobileApiClient();

  Future<List<TeamMeeting>> getMeetings() async => [
    for (final item in _rows(await _api.get(Endpoints.meetingsUrl)))
      TeamMeeting.fromJson(item),
  ];

  List<Map<String, dynamic>> _rows(dynamic value) => [
    for (final item in (value is List ? value : const []))
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}
