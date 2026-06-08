import 'dart:async';

import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dto/register_request.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;

  @override
  FutureOr<AuthState> build() async {
    _repository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  AuthState get _current => state.value ?? const AuthState();

  void toggleRememberMe(bool value) {
    state = AsyncData(_current.copyWith(rememberMe: value));
  }

  void toggleTerms(bool value) {
    state = AsyncData(_current.copyWith(agreedToTerms: value));
  }

  void selectEmail() {
    state = AsyncData(
      _current.copyWith(
        isEmailSelected: true,
        isPhoneSelected: false,
        email: '',
        phone: '',
      ),
    );
  }

  void selectPhone() {
    state = AsyncData(
      _current.copyWith(
        isEmailSelected: false,
        isPhoneSelected: true,
        email: '',
        phone: '',
      ),
    );
  }

  void onEmailChanged(String value) {
    state = AsyncData(_current.copyWith(email: value));
  }

  void onPasswordChanged(String value) {
    state = AsyncData(_current.copyWith(password: value));
  }

  void onPhoneChanged(String value) {
    state = AsyncData(_current.copyWith(phone: value));
  }

  void onCountryCodeChanged(String value) {
    state = AsyncData(_current.copyWith(countryCode: value));
  }

  void onFirstNameChanged(String value) {
    state = AsyncData(_current.copyWith(firstName: value));
  }

  void onLastNameChanged(String value) {
    state = AsyncData(_current.copyWith(lastName: value));
  }

  void onConfirmPasswordChanged(String value) {
    state = AsyncData(_current.copyWith(confirmPassword: value));
  }

  void onOtpChanged(String value) {
    state = AsyncData(_current.copyWith(otp: value));
  }

  Future<AuthResultModel> login({
    required String identifier,
    required String password,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.login(
        identifier: identifier,
        password: password,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Login failed");
  }

  Future<AuthResultModel> register({required RegisterRequest request}) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.register(request: request);
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Registration failed");
  }

  Future<AuthResultModel> verifyEmail({
    required String token,
    required String password,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.verifyEmail(token: token, password: password);
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Verification failed");
  }

  Future<AuthResultModel> sendVerificationCode({required String email}) async {
    return await _repository.sendVerificationCode(email: email);
  }

  Future<AuthResultModel> resendPasswordCode({required String email}) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.resendPasswordCode(email: email);
    });

    state = AsyncData(previous);

    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Failed to send OTP");
  }

  Future<AuthResultModel> resetPassword({
    required String token,
    required String password,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.resetPassword(token: token, password: password);
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(
          isSuccess: false,
          message: "Password reset failed",
        );
  }

  Future<AuthResultModel> deleteUser() async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.deleteUser();
    });

    state = AsyncData(previous);
    return result.value ??
        const AuthResultModel(
          isSuccess: false,
          message: "Delete account failed",
        );
  }

  Future<AuthResultModel> logout() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.logout();
    });

    state = AsyncData(const AuthState());

    return result.value ??
        const AuthResultModel(isSuccess: false, message: "Logout failed");
  }
}
