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
  Future<AuthResultModel> login({
    required String username,
    required String pin,
  }) async {
    final response = await _remoteService.login(
      LoginRequest(username: username, pin: pin),
    );
    final decodedBody = _decodeObject(response.body);

    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decodedBody == null) {
        return AuthResultModel.failure(
          "The server returned an invalid response.",
        );
      }

      // The kiosk login has no email in its response. Keep the one in the
      // token (if any) so a refresh can still identify the account.
      final parsed = LoginResponseModel.fromJson(decodedBody);
      final model = parsed.copyWith(
        email: parsed.email ?? _emailFromJwt(parsed.token),
      );
      if ((model.token ?? '').trim().isEmpty ||
          (model.userId ?? '').trim().isEmpty) {
        return AuthResultModel.failure(
          "The login response did not contain a valid session.",
        );
      }

      await _localStorageService.saveLoginSession(
        model: model,
        username: (model.username ?? '').trim().isNotEmpty
            ? model.username
            : username,
      );
      await _sessionService.initialize();
      await syncDeviceToken();
      return AuthResultModel.success(loginData: model);
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
      await _localStorageService.clearAuthSession();
      await _sessionService.clear();
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

      final username = globals.username.trim();
      final refreshToken = globals.refreshToken.trim();

      if (username.isEmpty || refreshToken.isEmpty) {
        return AuthResultModel.failure("No saved session to refresh");
      }

      final response = await _remoteService.refreshTokens(
        username: username,
        email: globals.userEmail.trim(),
        refreshToken: refreshToken,
      );

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

Map<String, dynamic>? _decodeObject(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } on FormatException {
    return null;
  }
  return null;
}

/// Reads the email claim from a JWT without verifying it. Only used to tell
/// the server which account to refresh; the server still validates the token.
String? _emailFromJwt(String? token) {
  try {
    final parts = (token ?? '').split('.');
    if (parts.length != 3) return null;
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map) return null;
    for (final key in const [
      'email',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
    ]) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  } catch (_) {
    // Not a readable JWT: nothing to add.
  }
  return null;
}
