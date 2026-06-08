import 'package:well_trust_mobile_app/core/helpers/globals.dart';

class AuthSessionService {
  Future<void> initialize() async {
    await globals.init();
  }

  Future<void> clear() async {
    globals.token = "";
    globals.refreshToken = "";
    globals.userId = "";
    globals.userEmail = "";
    globals.userName = "";
    globals.profilePicture = "";
    globals.roles = [];
    globals.permissions = [];
    globals.deviceToken =
        globals.deviceToken; // keep current device token if needed
  }
}
