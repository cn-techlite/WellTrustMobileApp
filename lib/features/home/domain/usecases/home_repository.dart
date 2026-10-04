import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class HomeRepository {
  Future<GeneralResultModel> sendNotification({
    required String title,
    required String body,
    required String notificationType,
    required String deviceToken,
  });

  Future<GeneralResultModel> sendNotificationRider({
    required String title,
    required String body,
    required String notificationType,
    required String riderDeviceToken,
    required String riderId,
  });

  Future<NotificationResponseModel> getNotificationData({required String id});

  Future<List<NotificationResponseModel>> getAllNotificationData();
}
