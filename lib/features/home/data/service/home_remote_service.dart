import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/home/data/dto/notification_request.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';

class HomeRemoteService {
  final MobileApiClient _api;

  HomeRemoteService({MobileApiClient? api}) : _api = api ?? MobileApiClient();

  Future<List<NotificationResponseModel>> getNotifications() async => [
    for (final row in _rows(await _api.get(Endpoints.notificationsUrl)))
      NotificationResponseModel.fromJson(row),
  ];

  Future<NotificationResponseModel> getNotification(String id) async =>
      NotificationResponseModel.fromJson(
        _object(await _api.get(Endpoints.notification(id))),
      );

  Future<void> sendNotification(NotificationRequest request) async {
    await _api.post(Endpoints.notificationsUrl, body: request.toJson());
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
