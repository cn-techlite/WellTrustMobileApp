import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/features/home/data/model/advert_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/riders_response_model.dart';
import 'package:http/http.dart' as http;

class HomeRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<http.Response> getPlaceDetails(String placeId) async {
    final String apiKey = Endpoints.googleApiKey;
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    printData('Places Details', response.body);
    return response;
  }

  Future<http.Response> getFullAddressFromLatLng(double lat, double lng) async {
    final apiKey = Endpoints.googleApiKey;
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    printData("Response", response.body);

    return response;
  }

  //!LOGISTICS COMPANY DATA

  Future<LogisticPaginatedModel> getAllLogisticsData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) async {
    try {
      final queryParams = <String, String>{
        //"UserId":globals.userId,
        "Page": page.toString(),
        "PageSize": pageSize.toString(),
      };

      if (state != null && state.trim().isNotEmpty) {
        queryParams["State"] = state.trim();
      }

      if (locality != null && locality.trim().isNotEmpty) {
        queryParams["Locality"] = locality.trim();
      }

      if (anyItem != null && anyItem.trim().isNotEmpty) {
        queryParams["AnyItem"] = anyItem.trim();
      }
      if (filterTypes != null && filterTypes.trim().isNotEmpty) {
        queryParams["FilterTypes"] = filterTypes.trim();
      }

      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All Logistics', response.body);
        return logisticPaginatedModelFromJson(response.body);
      }

      printData('All Logistic Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Logistic Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<LogisticResponseModel> getLogisticsData({required String id}) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}logistics-controller/$id");

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = LogisticResponseModel.fromJson(jsonDecode(response.body));

        printData('Single Logistic', response.body);
        return data;
      }

      printData('Single Logistic Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single Logistic Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! Notification
  Future<http.Response> sendNotification({
    required String title,
    required String body,
    required String notificationType,
    required String deviceToken,
  }) async {
    try {
      var stingUrl = Uri.parse("${Endpoints.baseUrl}notifications");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
        'userId': globals.userId.toString(),
      };
      final msg = jsonEncode({
        "title": title,
        "body": body,
        "deviceToken": deviceToken,
        "notificationType": notificationType,
      });
      http.Response response = await http.post(
        stingUrl,
        body: msg,
        headers: headers,
      );
      printData("Send Notification Response", response.body);
      return response;
    } catch (e) {
      printData('Send Notification Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> sendNotificationRider({
    required String title,
    required String body,
    required String notificationType,
    required String riderDeviceToken,
    required String riderId,
  }) async {
    try {
      var stingUrl = Uri.parse("${Endpoints.baseUrl}notifications");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
        'userId': riderId,
      };
      final msg = jsonEncode({
        "title": title,
        "body": body,
        "deviceToken": riderDeviceToken,
        "notificationType": notificationType,
      });
      http.Response response = await http.post(
        stingUrl,
        body: msg,
        headers: headers,
      );
      printData('Send Notification Rider Response', response.body);
      return response;
    } catch (e) {
      printData('Send Notification Rider Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<NotificationResponseModel> getNotificationData({
    required String id,
  }) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}notifications/$id");
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = NotificationResponseModel.fromJson(
          jsonDecode(response.body),
        );
        printData('Single Notification', response.body);
        return data;
      } else {
        printData('Single Notification Error', response.body);
        throw Exception(
          getErrorMessageFromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<List<NotificationResponseModel>> getAllNotificationData() async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}notifications");
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data1 = notificationResponseModelFromJson(response.body);
        printData('All Notification', response.body);
        return data1;
      } else {
        printData('All Notification Error', response.body);
        throw Exception(
          getErrorMessageFromResponse(response.statusCode, response.body),
        );
      }
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! Riders

  Future<RidersPaginatedModel> getAllRidersData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) async {
    try {
      final queryParams = <String, String>{
        //"UserId":globals.userId,
        "Page": page.toString(),
        "PageSize": pageSize.toString(),
      };

      if (state != null && state.trim().isNotEmpty) {
        queryParams["State"] = state.trim();
      }

      if (locality != null && locality.trim().isNotEmpty) {
        queryParams["Locality"] = locality.trim();
      }

      if (anyItem != null && anyItem.trim().isNotEmpty) {
        queryParams["AnyItem"] = anyItem.trim();
      }
      if (filterTypes != null && filterTypes.trim().isNotEmpty) {
        queryParams["FilterTypes"] = filterTypes.trim();
      }

      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/rider",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All Riders', response.body);
        return ridersPaginatedModelFromJson(response.body);
      }

      printData('All Riders Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Riders Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<RidersResponseModel> getRidersData({required String id}) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/rider/$id",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = RidersResponseModel.fromJson(jsonDecode(response.body));

        printData('Single Riders', response.body);
        return data;
      }

      printData('Single Riders Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single Riders Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! Add Rider Review
  Future<http.Response> addRiderReview({
    required String riderId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/update-riders-review/$riderId",
      );
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
        "userId": globals.userId,
      };
      final msg = jsonEncode({
        "reviewMessage": reviewMessage,
        "ratingNum": ratingNum,
        "orderId": orderId,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: headers,
      );
      printData("Add Rider Review Response", response.body);
      printData("Add Rider Review Status Code", response.statusCode);

      return response;
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! Add Logistics Company Review
  Future<http.Response> addLogisticsReview({
    required String stationId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/update-logistic-company-review/$stationId",
      );
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
        "userId": globals.userId,
      };
      final msg = jsonEncode({
        "reviewMessage": reviewMessage,
        "ratingNum": ratingNum,
        "orderId": orderId,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: headers,
      );
      printData("Add Logistics Review Response", response.body);
      printData("Add Logistics Review Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //!Advert
  Future<List<AdvertResponseModel>> getAllAdvertisements() async {
    List<AdvertResponseModel> data = [];
    try {
      var url = Uri.parse("${Endpoints.baseUrl}admin-controller/advert/");
      var response = await http.get(url, headers: _headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data1 = advertResponseModelFromJson(response.body);
        data = data1;
        printData('All Advertisements', response.body);
        return data;
      } else {
        printData('All Advertisements Error', response.body);
      }
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
    return data;
  }
}
