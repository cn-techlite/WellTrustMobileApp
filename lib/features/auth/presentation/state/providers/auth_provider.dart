import 'package:ginilog_customer_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_remote_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_session_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/social_auth_service.dart';
import 'package:ginilog_customer_app/features/auth/domain/controller/auth_controller.dart';
import 'package:ginilog_customer_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService();
});

final socialAuthServiceProvider = Provider<SocialAuthService>((ref) {
  return SocialAuthService();
});

final authLocalStorageServiceProvider = Provider<AuthLocalStorageService>((
  ref,
) {
  return AuthLocalStorageService();
});

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteService: ref.read(authRemoteServiceProvider),
    socialAuthService: ref.read(socialAuthServiceProvider),
    localStorageService: ref.read(authLocalStorageServiceProvider),
    sessionService: ref.read(authSessionServiceProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
