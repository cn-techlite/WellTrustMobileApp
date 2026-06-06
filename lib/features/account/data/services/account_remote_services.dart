import 'dart:convert';
import 'package:ginilog_customer_app/core/extension/error_handling.dart';
import 'package:http/http.dart' as http;
import '../../../../core/helpers/endpoints.dart';
import '../../../../core/helpers/globals.dart';
import '../../../../core/utils/constants.dart';

import '../model/user_response_model.dart';

class AccountRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<RegisterResponseModel> getUserData() async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/profile",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = RegisterResponseModel.fromJson(jsonDecode(response.body));

        printData('User Data', response.body);
        return data;
      }

      printData('User Data Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('User Data Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> updateProfile({
    String? firstName,
    String? lastName,
    String? imageFile,
    String? phoneNo,
    bool? availability,
  }) async {
    try {
      var stingUrl = Uri.parse("${Endpoints.baseUrl}${Endpoints.userUpdate}");

      final msg = jsonEncode({
        "firstName": firstName ?? "",
        "lastName": lastName ?? "",
        "profilePicture": imageFile ?? "",
        "phoneNo": phoneNo ?? "",
        "userStatus": availability ?? false,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: _headers,
      );
      printData("Response", response.body);
      printData("Response Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> addNewAddress({
    required String userId,
    required String address,
    required String addressPostCodes,
    required String houseNo,
    required String city,
    required String state,
    required double latitude,
    required double longitude,
    required String phoneNo,
    required String userName,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/add-new-address/$userId",
      );

      final msg = jsonEncode({
        "address": address,
        "phoneNo": phoneNo,
        "userName": userName,
        "addressPostCodes": addressPostCodes,
        "houseNo": houseNo,
        "city": city,
        "state": state,
        "latitude": latitude,
        "longitude": longitude,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: _headers,
      );
      printData("Add New Address Response", response.body);
      printData("Response Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Add New Address Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> updateAddress({
    required String addressId,
    required String address,
    required String addressPostCodes,
    required String houseNo,
    required String city,
    required double latitude,
    required double longitude,
    required String phoneNo,
    required String userName,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/update-delivery-address/$addressId",
      );
      final msg = jsonEncode({
        "phoneNo": phoneNo,
        "userName": userName,
        "address": address,
        "addressPostCodes": addressPostCodes,
        "houseNo": houseNo,
        "city": city,
        "latitude": latitude,
        "longitude": longitude,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: _headers,
      );

      printData("Add New Address Response", response.body);
      printData("Update Address Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Add New Address Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> deleteDeliveryAddress({
    required String addressId,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/delete-delivery-address/$addressId",
      );
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
      };
      http.Response response = await http.delete(stingUrl, headers: headers);
      printData("Delete Delivery Address Response", response.body);
      printData("Delete Delivery Address Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Delete Delivery Address Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> sendFeedBack({
    required String feedback,
    required String phoneNo,
  }) async {
    try {
      var stingUrl = Uri.parse("${Endpoints.baseUrl}info/feedback");

      final msg = jsonEncode({
        "name": globals.userName,
        "email": globals.userEmail,
        "feedback": feedback,
        "phoneNo": phoneNo,
      });
      http.Response response = await http.post(
        stingUrl,
        body: msg,
        headers: _headers,
      );

      printData("Send Feedback Response", response.body);
      printData("Send Feedback Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Send Feedback Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }
}
