import 'login_response_model.dart';

class AuthResultModel {
  final bool isSuccess;
  final String? message;
  final LoginResponseModel? loginData;
  final dynamic rawData;

  const AuthResultModel({
    required this.isSuccess,
    this.message,
    this.loginData,
    this.rawData,
  });

  factory AuthResultModel.success({
    LoginResponseModel? loginData,
    dynamic rawData,
    String? message,
  }) {
    return AuthResultModel(
      isSuccess: true,
      loginData: loginData,
      rawData: rawData,
      message: message,
    );
  }

  factory AuthResultModel.failure(String message) {
    return AuthResultModel(isSuccess: false, message: message);
  }
}
