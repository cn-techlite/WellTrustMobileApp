import 'package:ginilog_customer_app/core/constants/api_constants.dart';
import 'package:ginilog_customer_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_remote_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_session_service.dart';
import 'package:ginilog_customer_app/features/auth/data/service/social_auth_service.dart';
import 'package:ginilog_customer_app/features/auth/domain/usercases/auth_repository.dart';

import '../utils/constants.dart';
import '../utils/package_export.dart';

final GetIt getIt = GetIt.instance;

class AppGlobals {
  factory AppGlobals() => instance;

  AppGlobals._();

  static final AppGlobals instance = AppGlobals._();

  String? isLoggedIn;
  int? isViewed;
  StopWatchTimer? stopWatchTimer;
  String userEmail = "";
  String userPassword = "";
  String token = "";
  String refreshToken = "";
  String userId = "";
  String userName = "";
  String deviceToken = "";
  String profilePicture = "";
  bool isEmailVerified = false;
  List<String> roles = [];
  List<String> permissions = [];

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final authStorage = AuthLocalStorageService();

    await authStorage.migrateLegacySessionIfNeeded();

    userId =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.userIdKey,
        ) ??
        "";
    token =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.tokenKey,
        ) ??
        "";
    refreshToken =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.refreshTokenKey,
        ) ??
        "";
    userEmail =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.userEmailKey,
        ) ??
        "";
    userName =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.userNameKey,
        ) ??
        "";
    deviceToken = await getFromLocalStorage(name: "deviceToken") ?? "";

    profilePicture =
        await authStorage.readSecureAuthValue(
          AuthLocalStorageService.profilePictureKey,
        ) ??
        "";

    isViewed = preferences.getInt("onBoard");
    isLoggedIn = preferences.getString("isLoggedIn") ?? "";
    isEmailVerified =
        await getBoolFromLocalStorage(name: "isEmailVerified") ?? false;

    roles = await getListFromLocalStorage(name: "roles") ?? <String>[];
    permissions =
        await getListFromLocalStorage(name: "permissions") ?? <String>[];

    printData("userId", userId);
    printData("userEmail", userEmail);
    printData("deviceToken", deviceToken);
    printData("roles", roles);
    printData("permissions", permissions);
  }

  void dispose() {}
}

AppGlobals globals = getIt.get<AppGlobals>();

Future<void> setupLocator() async {
  if (!getIt.isRegistered<AppGlobals>()) {
    getIt.registerLazySingleton<AppGlobals>(() => AppGlobals.instance);
  }

  if (!getIt.isRegistered<PushNotificationService>()) {
    getIt.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(),
    );
  }

  if (!getIt.isRegistered<AuthLocalStorageService>()) {
    getIt.registerLazySingleton<AuthLocalStorageService>(
      () => AuthLocalStorageService(),
    );
  }

  if (!getIt.isRegistered<AuthRemoteService>()) {
    getIt.registerLazySingleton<AuthRemoteService>(() => AuthRemoteService());
  }

  if (!getIt.isRegistered<SocialAuthService>()) {
    getIt.registerLazySingleton<SocialAuthService>(() => SocialAuthService());
  }

  if (!getIt.isRegistered<AuthSessionService>()) {
    getIt.registerLazySingleton<AuthSessionService>(() => AuthSessionService());
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteService: getIt<AuthRemoteService>(),
        socialAuthService: getIt<SocialAuthService>(),
        localStorageService: getIt<AuthLocalStorageService>(),
        sessionService: getIt<AuthSessionService>(),
      ),
    );
  }
}
