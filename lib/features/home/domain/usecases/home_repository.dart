import 'package:well_trust_mobile_app/features/home/data/model/advert_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/riders_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class HomeRepository {
  //! PLACES DETAILS
  Future<GeneralResultModel> getPlaceDetails(String placeId);

  Future<GeneralResultModel> getFullAddressFromLatLng(double lat, double lng);

  //! LOGISTIC COMPANY DATA
  Future<LogisticPaginatedModel> getAllLogisticData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  });

  Future<LogisticResponseModel> getLogisticData({required String id});

  Future<GeneralResultModel> addLogisticsReview({
    required String stationId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  });

  //! NOTIFICATIONS
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

  //! RIDERS

  Future<RidersPaginatedModel> getAllRidersData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  });

  Future<RidersResponseModel> getRidersData({required String id});

  Future<GeneralResultModel> addRiderReview({
    required String riderId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  });

  //!Advert Placement
  Future<List<AdvertResponseModel>> getAllAdvertisements();
}
