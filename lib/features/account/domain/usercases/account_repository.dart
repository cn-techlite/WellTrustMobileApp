import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class AccountRepository {
  Future<RegisterResponseModel> getUserData();

  //! UPDATE PROFILE
  Future<GeneralResultModel> updateProfile({
    required String firstName,
    required String lastName,
    required String imageFile,
    required String phoneNo,
    required bool availability,
  });
  Future<GeneralResultModel> addNewAddress({
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
  });
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
  });
  Future<GeneralResultModel> deleteDeliveryAddress({required String addressId});
  Future<GeneralResultModel> sendFeedBack({
    required String feedback,
    required String phoneNo,
  });
}
