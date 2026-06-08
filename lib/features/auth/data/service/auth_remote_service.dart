import 'dart:convert';
import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:http/http.dart' as http;

import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../dto/verify_email_request.dart';
import '../dto/resend_code_request.dart';
import '../dto/reset_password_request.dart';

class AuthRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> register(RegisterRequest request) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.usersUrl}");

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Register Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> login(LoginRequest request) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.usersLoginUrl}");

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Login Data", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> verifyEmail(VerifyEmailRequest request) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.emailVerificationUrl}",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Verify Email", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> sendVerificationCode(ResendCodeRequest request) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.resendEmailVerificationTokenUrl}",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Send Email Verification code Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> resendPasswordCode(ResendCodeRequest request) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.forgetPasswordUrl}",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Resend Password token Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> resetPassword(ResetPasswordRequest request) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.resetPasswordUrl}",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Reset Password Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> updateDeviceToken() async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/update-device-token",
      );

      final response = await http.put(
        url,
        body: jsonEncode({"deviceToken": globals.deviceToken}),
        headers: {..._headers, 'Authorization': 'Bearer ${globals.token}'},
      );
      printData("Update Device Token Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> deleteUser() async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/${globals.userId}",
      );

      final response = await http.delete(
        url,
        headers: {..._headers, 'Authorization': 'Bearer ${globals.token}'},
      );
      printData("Delete User Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> logout() async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.logoutUrl}");

      final response = await http.post(
        url,
        headers: {..._headers, 'Authorization': 'Bearer ${globals.token}'},
      );
      printData("Log out Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> refreshTokens(String email, String refreshToken) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.refreshTokenUrl}");

      final response = await http.post(
        url,
        body: jsonEncode({"email": email, "refreshToken": refreshToken}),
        headers: _headers,
      );
      printData("Refresh Tokens Response", response.body);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }
}
