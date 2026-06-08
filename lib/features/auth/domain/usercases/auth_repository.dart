import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';

import '../../data/dto/register_request.dart';

abstract class AuthRepository {
  Future<AuthResultModel> login({
    required String identifier,
    required String password,
  });

  Future<AuthResultModel> register({required RegisterRequest request});

  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  });

  Future<AuthResultModel> sendVerificationCode({required String email});

  Future<AuthResultModel> resendPasswordCode({required String email});

  Future<AuthResultModel> resetPassword({
    required String token,
    required String password,
  });

  Future<AuthResultModel> deleteUser();
  Future<void> syncDeviceToken();
  Future<void> restoreSessionAndSyncDeviceToken();
  Future<AuthResultModel> logout();
  Future<AuthResultModel> refreshTokens();
}
