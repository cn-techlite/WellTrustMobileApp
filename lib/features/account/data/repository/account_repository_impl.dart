import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/data/services/account_remote_services.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteService remoteService;

  AccountRepositoryImpl(this.remoteService);

  @override
  Future<RegisterResponseModel> getUserData() {
    return remoteService.getUserData();
  }

  @override
  Future<GeneralResultModel> updateProfile({
    required String firstName,
    required String lastName,
    required String imageFile,
    required String phoneNo,
    required bool availability,
  }) async {
    final response = await remoteService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      imageFile: imageFile,
      phoneNo: phoneNo,
      availability: availability,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Profile updated successfully",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> addNewAddress({
    required String address,
    required String city,
    required String state,
    required double latitude,
    required double longitude,
    required String userId,
    required String addressPostCodes,
    required String houseNo,
    required String phoneNo,
    required String userName,
  }) async {
    final response = await remoteService.addNewAddress(
      address: address,
      city: city,
      state: state,
      latitude: latitude,
      longitude: longitude,
      userId: userId,
      addressPostCodes: addressPostCodes,
      houseNo: houseNo,
      phoneNo: phoneNo,
      userName: userName,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Address added successfully",
        data: data,
      );
    }
    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> updateAddress({
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
    final response = await remoteService.updateAddress(
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      addressId: addressId,
      addressPostCodes: addressPostCodes,
      houseNo: houseNo,
      phoneNo: phoneNo,
      userName: userName,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Address updated successfully",
        data: data,
      );
    }
    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> deleteDeliveryAddress({
    required String addressId,
  }) async {
    final response = await remoteService.deleteDeliveryAddress(
      addressId: addressId,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Address deleted successfully",
        data: data,
      );
    }
    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> sendFeedBack({
    required String feedback,
    required String phoneNo,
  }) async {
    final response = await remoteService.sendFeedBack(
      feedback: feedback,
      phoneNo: phoneNo,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Feedback sent successfully",
        data: data,
      );
    }
    return GeneralResultModel.failure(errorMessage);
  }
}
