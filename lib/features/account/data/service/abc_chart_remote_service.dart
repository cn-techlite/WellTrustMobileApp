import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/create_abc_chart_request.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';

class AbcChartRemoteService {
  final MobileApiClient _api;

  AbcChartRemoteService({MobileApiClient? api})
    : _api = api ?? MobileApiClient();

  Future<List<AbcChartEntry>> getForClient(String clientId) async => [
    for (final row in _rows(
      await _api.get(Endpoints.clientAbcCharts(clientId)),
    ))
      AbcChartEntry.fromJson(row),
  ];

  Future<AbcChartEntry> create(CreateAbcChartRequest request) async =>
      AbcChartEntry.fromJson(
        _object(
          await _api.post(Endpoints.abcChartsUrl, body: request.toJson()),
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
