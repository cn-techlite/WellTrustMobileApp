import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';

class ClientRemoteService {
  final MobileApiClient _api;

  ClientRemoteService({MobileApiClient? api}) : _api = api ?? MobileApiClient();

  Future<List<AssignedClient>> getAssignedClients() async => [
    for (final item in _rows(await _api.get(Endpoints.assignedClientsUrl)))
      AssignedClient.fromJson(item),
  ];

  List<Map<String, dynamic>> _rows(dynamic value) => [
    for (final item in (value is List ? value : const []))
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}
