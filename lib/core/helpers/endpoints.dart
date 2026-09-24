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
  // appBaseUrl already ends in a slash, so trim it before adding /api/ or the
  // URL comes out as ...co.uk//api/.
  static String baseUrl = "${appBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/";

  static String usersUrl = "admin-users";
  static String kioskLoginUrl = "welltrust-kiosk/login";
  static String logoutUrl = "auth/logout";
  static String refreshTokenUrl = "auth/tokens/refresh";

  static String userUpdate = "admin-users/update";
  static String staffRecordsUrl = "admin-staff-records";
  static String uploadUrl = "upload-files/upload-web-server";
}
