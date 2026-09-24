import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/features/home/data/model/advert_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/riders_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/services/home_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteService _remoteService;

  HomeRepositoryImpl(this._remoteService);

  //! LOGISTIC COMPANY DATA
  @override
  Future<LogisticPaginatedModel> getAllLogisticData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) {
    return _remoteService.getAllLogisticsData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
    );
  }

  @override
  Future<LogisticResponseModel> getLogisticData({required String id}) {
    return _remoteService.getLogisticsData(id: id);
  }

  @override
  Future<GeneralResultModel> addLogisticsReview({
    required String stationId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final response = await _remoteService.addLogisticsReview(
      stationId: stationId,
      orderId: orderId,
      ratingNum: ratingNum,
      reviewMessage: reviewMessage,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Add Company Review successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  //! NOTIFICATIONS

  @override
  Future<GeneralResultModel> sendNotification({
    required String title,
    required String body,
    required String notificationType,
    required String deviceToken,
  }) async {
    final response = await _remoteService.sendNotification(
      title: title,
      body: body,
      notificationType: notificationType,
      deviceToken: deviceToken,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Added Notification successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> sendNotificationRider({
    required String title,
    required String body,
    required String notificationType,
    required String riderDeviceToken,
    required String riderId,
  }) async {
    final response = await _remoteService.sendNotificationRider(
      title: title,
      body: body,
      notificationType: notificationType,
      riderDeviceToken: riderDeviceToken,
      riderId: riderId,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Added Rider Notification successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<NotificationResponseModel> getNotificationData({required String id}) {
    return _remoteService.getNotificationData(id: id);
  }

  @override
  Future<List<NotificationResponseModel>> getAllNotificationData() {
    return _remoteService.getAllNotificationData();
  }

  //! RIDERS

  @override
  Future<RidersPaginatedModel> getAllRidersData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) {
    return _remoteService.getAllRidersData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
    );
  }

  @override
  Future<RidersResponseModel> getRidersData({required String id}) {
    return _remoteService.getRidersData(id: id);
  }

  @override
  Future<GeneralResultModel> addRiderReview({
    required String riderId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final response = await _remoteService.addRiderReview(
      riderId: riderId,
      orderId: orderId,
      reviewMessage: reviewMessage,
      ratingNum: ratingNum,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Rider Review Added successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  //!Advert Placement
  @override
  Future<List<AdvertResponseModel>> getAllAdvertisements() {
    return _remoteService.getAllAdvertisements();
  }
}
