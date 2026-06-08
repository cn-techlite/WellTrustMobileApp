import 'package:well_trust_mobile_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:well_trust_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:well_trust_mobile_app/features/auth/domain/controller/auth_controller.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteServiceProvider = Provider<AuthRemoteService>((ref) {
  return AuthRemoteService();
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
    localStorageService: ref.read(authLocalStorageServiceProvider),
    sessionService: ref.read(authSessionServiceProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
