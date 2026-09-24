import 'dart:async';

import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;

  @override
  FutureOr<AuthState> build() {
    _repository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  AuthState get _current => state.value ?? const AuthState();

  void toggleRememberMe(bool value) {
    state = AsyncData(_current.copyWith(rememberMe: value));
  }

  void onUsernameChanged(String value) {
    state = AsyncData(_current.copyWith(username: value));
  }

  void onPinChanged(String value) {
    state = AsyncData(_current.copyWith(pin: value));
  }

  void resetLoginForm() {
    state = AsyncData(_current.copyWith(username: '', pin: ''));
  }

  Future<AuthResultModel> _run(
    Future<AuthResultModel> Function() action, {
    required String fallbackMessage,
    bool clearStateOnSuccess = false,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    late final AuthResultModel result;
    try {
      result = await action();
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst(RegExp(r'^Exception:\s*'), '')
          .trim();
      result = AuthResultModel.failure(
        message.isEmpty ? fallbackMessage : message,
      );
    }

    state = AsyncData(
      clearStateOnSuccess && result.isSuccess ? const AuthState() : previous,
    );
    return result;
  }

  Future<AuthResultModel> login({
    required String username,
    required String pin,
  }) {
    return _run(
      () => _repository.login(username: username, pin: pin),
      fallbackMessage: "Login failed",
    );
  }

  Future<AuthResultModel> deleteUser() {
    return _run(
      _repository.deleteUser,
      fallbackMessage: "Delete account failed",
      clearStateOnSuccess: true,
    );
  }

  Future<AuthResultModel> logout() {
    return _run(
      _repository.logout,
      fallbackMessage: "Logout failed",
      clearStateOnSuccess: true,
    );
  }
}
