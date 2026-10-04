import 'package:well_trust_mobile_app/features/home/data/dto/notification_request.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/data/service/home_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteService _remoteService;

  const HomeRepositoryImpl(this._remoteService);

  @override
  Future<List<NotificationResponseModel>> getAllNotificationData() =>
      _remoteService.getNotifications();

  @override
  Future<NotificationResponseModel> getNotificationData({required String id}) =>
      _remoteService.getNotification(id);

  @override
  Future<GeneralResultModel> sendNotification({
    required String title,
    required String body,
    required String notificationType,
    required String deviceToken,
  }) async {
    await _remoteService.sendNotification(
      NotificationRequest(
        title: title,
        body: body,
        notificationType: notificationType,
        deviceToken: deviceToken,
      ),
    );
    return GeneralResultModel.success(message: 'Notification sent');
  }

  @override
  Future<GeneralResultModel> sendNotificationRider({
    required String title,
    required String body,
    required String notificationType,
    required String riderDeviceToken,
    required String riderId,
  }) async {
    await _remoteService.sendNotification(
      NotificationRequest(
        title: title,
        body: body,
        notificationType: notificationType,
        deviceToken: riderDeviceToken,
        recipientId: riderId,
      ),
    );
    return GeneralResultModel.success(message: 'Notification sent');
  }
}
