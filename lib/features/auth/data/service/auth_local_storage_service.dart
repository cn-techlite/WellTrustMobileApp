import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ginilog_customer_app/core/utils/constants.dart';
import 'package:ginilog_customer_app/features/auth/data/model/login_response_model.dart';

class AuthLocalStorageService {
  static const _secureStorage = FlutterSecureStorage();

  static const tokenKey = "token";
  static const refreshTokenKey = "refreshToken";
  static const userEmailKey = "userEmail";
  static const userIdKey = "userId";
  static const userNameKey = "userName";
  static const profilePictureKey = "profilePicture";
  static const userPasswordKey = "userPassword";

  Future<void> saveLoginSession({
    required LoginResponseModel model,
    String? password,
  }) async {
    await _saveSecureSession(model);

    await setBoolToLocalStorage(name: "isHomeLoaded", data: true);
    await setBoolToLocalStorage(
      name: "isEmailVerified",
      data: model.emailVerified ?? false,
    );
    await setListToLocalStorage(name: "roles", data: model.roles ?? []);
    await setListToLocalStorage(
      name: "permissions",
      data: model.permissions ?? [],
    );
  }

  Future<void> saveSocialLoginSession({
    required LoginResponseModel model,
    required String providerUid,
  }) async {
    await _saveSecureSession(model);

    await setBoolToLocalStorage(name: "isHomeLoaded", data: true);
    await setBoolToLocalStorage(
      name: "isEmailVerified",
      data: model.emailVerified ?? false,
    );
    await setListToLocalStorage(name: "roles", data: model.roles ?? []);
    await setListToLocalStorage(
      name: "permissions",
      data: model.permissions ?? [],
    );
  }

  Future<void> saveVerifiedEmailSession({
    required LoginResponseModel model,
    required String password,
  }) async {
    await _saveSecureSession(model);

    await setBoolToLocalStorage(
      name: "isEmailVerified",
      data: model.emailVerified ?? false,
    );
    await setToLocalStorage(name: "isLoggedIn", data: "isLoggedIn");
    await setListToLocalStorage(name: "roles", data: model.roles ?? []);
    await setListToLocalStorage(
      name: "permissions",
      data: model.permissions ?? [],
    );
  }

  Future<void> clearAuthSession() async {
    await clearSecureAuthSession();
    await _removeLegacySensitiveValues();

    await setToLocalStorage(name: "isLoggedIn", data: "");
    await setBoolToLocalStorage(name: "isHomeLoaded", data: false);
    await setBoolToLocalStorage(name: "isEmailVerified", data: false);
    await setListToLocalStorage(name: "roles", data: []);
    await setListToLocalStorage(name: "permissions", data: []);
    await setBoolToLocalStorage(name: "activateBrand", data: false);
    await setBoolToLocalStorage(name: "activateProfession", data: false);
  }

  Future<String?> readSecureAuthValue(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> migrateLegacySessionIfNeeded() async {
    final secureToken = await readSecureAuthValue(tokenKey);
    if ((secureToken ?? '').isNotEmpty) {
      await removeFromLocalStorage(name: userPasswordKey);
      return;
    }

    for (final key in _secureKeys) {
      if (key == userPasswordKey) continue;

      final value = await getFromLocalStorage(name: key);
      if ((value ?? '').toString().isNotEmpty) {
        await _writeSecureString(key, value);
      }
    }

    await _removeLegacySensitiveValues();
  }

  Future<void> clearSecureAuthSession() async {
    for (final key in _secureKeys) {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> _saveSecureSession(LoginResponseModel model) async {
    await _writeSecureString(tokenKey, model.token);
    await _writeSecureString(refreshTokenKey, model.refreshToken);
    await _writeSecureString(userEmailKey, model.email);
    await _writeSecureString(userIdKey, model.userId);
    await _writeSecureString(userNameKey, model.fullName);
    await _writeSecureString(profilePictureKey, model.profileImage);
    await removeFromLocalStorage(name: userPasswordKey);
  }

  Future<void> _writeSecureString(String key, String? value) async {
    final normalizedValue = (value ?? '').trim();
    if (normalizedValue.isEmpty) {
      await _secureStorage.delete(key: key);
      return;
    }

    await _secureStorage.write(key: key, value: normalizedValue);
  }

  Future<void> _removeLegacySensitiveValues() async {
    for (final key in _secureKeys) {
      await removeFromLocalStorage(name: key);
    }
  }
}

const _secureKeys = <String>[
  AuthLocalStorageService.tokenKey,
  AuthLocalStorageService.refreshTokenKey,
  AuthLocalStorageService.userEmailKey,
  AuthLocalStorageService.userIdKey,
  AuthLocalStorageService.userNameKey,
  AuthLocalStorageService.profilePictureKey,
  AuthLocalStorageService.userPasswordKey,
];
