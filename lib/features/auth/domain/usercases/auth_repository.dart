import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';

abstract class AuthRepository {
  /// Kiosk device login: a username and the 5 digit passcode (PIN).
  Future<AuthResultModel> login({
    required String username,
    required String pin,
  });

  Future<AuthResultModel> deleteUser();
  Future<void> syncDeviceToken();
  Future<void> restoreSessionAndSyncDeviceToken();
  Future<AuthResultModel> logout();
  Future<AuthResultModel> refreshTokens();
}
