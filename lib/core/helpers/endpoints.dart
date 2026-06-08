class Endpoints {
  static const env = String.fromEnvironment('ENV');
  static const _production =
      "https://new-api-connection.welltrusthealthstaff.co.uk/";
  static const _live = "https://new-api-connection.welltrusthealthstaff.co.uk/";
  static const _test = "https://new-api-connection.welltrusthealthstaff.co.uk/";

  static String get appBaseUrl {
    switch (env) {
      case 'production':
        return _production;
      case 'live':
        return _live;
      case 'test':
        return _test;
      default:
        return _test;
    }
  }

  static String socketBaseUrl = appBaseUrl;
  static String baseUrl = "$appBaseUrl/api/";

  static String usersUrl = "auth-users";
  static String usersLoginUrl = "auth-users/login";
  static String logoutUrl = "auth-users/logout";
  static String refreshTokenUrl = "auth-users/tokens/refresh";
  static String updateBrowseModeUrl = "auth-users/update-user-browse-only";
  static String emailVerificationUrl = "auth-users/email-verification";
  static String phoneVerificationUrl = "auth-users/phone-no-verification";
  static String phoneNoVerificationUrl = "auth-users/PhoneNo-Verification";
  static String twoFactorEnabledUrl = "auth-users/two-factor-enabled";
  static String forgetPasswordUrl = "auth-users/forgot-password-request-token";
  static String resetPasswordUrl = "auth-users/reset-password";
  static String userUpdate = "auth-users/update-user";
  static String uploadUrl = "upload-file/upload-web-server";

  static String resendEmailVerificationTokenUrl =
      "auth-users/email-verification-request-token";
  static String contactUsUrl = "info/contact-us";
  static String googleApiKey = "AIzaSyA1WkH5DbnyUVLhPtqo_qj3Bmr0uKPolSw";
  //Flutterwave
  static String flutterWaveKey =
      "FLWPUBK_TEST-0401652f50334af315d414a6568bdf5f-X";

  static String flutterWaveTestedKey =
      "FLWPUBK_TEST-0401652f50334af315d414a6568bdf5f-X";
  static String flutterWaveLiveEdKey =
      "FLWPUBK_TEST-2624c0cbf9db0abffb95401130be6432-X";
  // Paystack
  static String paystackSecretKey =
      "sk_test_bddced709bd1dc7069ed81c77644f531cc86cb74";
  static String paystackPublicKey =
      "pk_test_22bfc066e91d081926d5d5fa7701770dd90ce89a";
  static String paystackSecretTestedKey =
      "sk_test_bddced709bd1dc7069ed81c77644f531cc86cb74";
  static String paystackPublicTestedKey =
      "pk_test_22bfc066e91d081926d5d5fa7701770dd90ce89a";
  static String paystackSecretLiveKey =
      "FLWPUBK_TEST-2624c0cbf9db0abffb95401130be6432-X";
  static String paystackPublicLiveKey =
      "FLWPUBK_TEST-2624c0cbf9db0abffb95401130be6432-X";
}
