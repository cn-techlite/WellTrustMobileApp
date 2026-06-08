import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:well_trust_mobile_app/features/auth/data/model/login_response_model.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../dto/resend_code_request.dart';
import '../dto/reset_password_request.dart';
import '../dto/verify_email_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remoteService;
  final AuthLocalStorageService _localStorageService;
  final AuthSessionService _sessionService;

  AuthRepositoryImpl({
    required AuthRemoteService remoteService,
    required AuthLocalStorageService localStorageService,
    required AuthSessionService sessionService,
  }) : _remoteService = remoteService,
       _localStorageService = localStorageService,
       _sessionService = sessionService;

  @override
  Future<AuthResultModel> register({required RegisterRequest request}) async {
    final response = await _remoteService.register(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Registration successful",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _remoteService.login(
      LoginRequest(identifier: identifier, password: password),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);

    final message = (body["message"] ?? "").toString().trim();

    // Handle unverified email first
    if (message == "User Email Not Yet Verify") {
      return AuthResultModel.failure("User Email Not Yet Verify");
    }

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = LoginResponseModel.fromJson(jsonDecode(response.body));
      await _localStorageService.saveLoginSession(
        model: model,
        password: password,
      );
      await _sessionService.initialize();
      await _remoteService.updateDeviceToken();
      await syncDeviceToken();
      return AuthResultModel.success(loginData: model);
    }

    return AuthResultModel.failure(errorMessage);
  }


  @override
  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  }) async {
    final response = await _remoteService.verifyEmail(
      VerifyEmailRequest(token: token, password: password),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = LoginResponseModel.fromJson(jsonDecode(response.body));
      await _localStorageService.saveVerifiedEmailSession(
        model: model,
        password: password,
      );
      await _sessionService.initialize();

      return AuthResultModel.success(loginData: model);
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> sendVerificationCode({required String email}) async {
    final response = await _remoteService.sendVerificationCode(
      ResendCodeRequest(email: email),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Verification code sent",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> resendPasswordCode({required String email}) async {
    final response = await _remoteService.resendPasswordCode(
      ResendCodeRequest(email: email),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Password reset code sent",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await _remoteService.resetPassword(
      ResetPasswordRequest(token: token, password: password),
    );

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Password updated successfully",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<AuthResultModel> deleteUser() async {
    final response = await _remoteService.deleteUser();
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResultModel.success(
        rawData: response.body,
        message: "Account deleted successfully",
      );
    }

    return AuthResultModel.failure(errorMessage);
  }

  @override
  Future<void> syncDeviceToken() async {
    try {
      await _sessionService.initialize();

      final token = (globals.token).toString();
      final deviceToken = (globals.deviceToken).toString();

      if (token.isEmpty || deviceToken.isEmpty) return;

      await _remoteService.updateDeviceToken();
    } catch (e) {
      printData("syncDeviceToken", e.toString());
    }
  }

  @override
  Future<void> restoreSessionAndSyncDeviceToken() async {
    try {
      await _sessionService.initialize();

      final token = (globals.token).toString();
      if (token.isEmpty) return;

      final deviceToken = (globals.deviceToken).toString();
      if (deviceToken.isNotEmpty) {
        await _remoteService.updateDeviceToken();
      }
    } catch (e) {
      printData("restoreSessionAndSyncDeviceToken", e.toString());
    }
  }

  @override
  Future<AuthResultModel> logout() async {
    try {
      await _sessionService.initialize();

      final hasToken = (globals.token).toString().isNotEmpty;

      if (hasToken) {
        try {
          await _remoteService.logout();
        } catch (_) {}
      }

      await _localStorageService.clearAuthSession();
      await _sessionService.clear();

      return AuthResultModel.success(message: "Logged out successfully");
    } catch (e) {
      return AuthResultModel.failure(e.toString());
    }
  }

  @override
  Future<AuthResultModel> refreshTokens() async {
    try {
      await _sessionService.initialize();

      final email = globals.userEmail.trim();
      final refreshToken = globals.refreshToken.trim();

      if (email.isEmpty || refreshToken.isEmpty) {
        return AuthResultModel.failure("No saved session to refresh");
      }

      final response = await _remoteService.refreshTokens(email, refreshToken);

      final errorMessage = getErrorMessageFromResponse(
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = LoginResponseModel.fromJson(jsonDecode(response.body));
        await _localStorageService.saveLoginSession(model: model);
        await _sessionService.initialize();
        await syncDeviceToken();
        return AuthResultModel.success(loginData: model);
      }

      return AuthResultModel.failure(errorMessage);
    } catch (e) {
      return AuthResultModel.failure(e.toString());
    }
  }
}
