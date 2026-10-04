import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/handover/data/dto/handover_requests.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

class HandoverRemoteService {
  final MobileApiClient _api;

  HandoverRemoteService({MobileApiClient? api})
    : _api = api ?? MobileApiClient();

  Future<List<HandoverEntry>> getHandovers({
    String? clientId,
    bool? openOnly,
  }) async => [
    for (final row in _rows(
      await _api.get(
        Endpoints.handoversUrl,
        query: {'clientId': clientId, 'openOnly': openOnly?.toString()},
      ),
    ))
      HandoverEntry.fromJson(row),
  ];

  Future<HandoverEntry> create(CreateHandoverRequest request) async =>
      HandoverEntry.fromJson(
        _object(
          await _api.post(Endpoints.handoversUrl, body: request.toJson()),
        ),
      );

  Future<HandoverEntry> resolve(
    String id,
    ResolveHandoverRequest request,
  ) async => HandoverEntry.fromJson(
    _object(
      await _api.put(Endpoints.resolveHandover(id), body: request.toJson()),
    ),
  );

  Future<void> markRead(String clientId) async {
    await _api.put(Endpoints.markClientHandoversRead(clientId));
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
