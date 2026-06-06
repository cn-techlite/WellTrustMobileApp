import 'dart:convert';
import 'dart:math';
import 'package:ginilog_customer_app/core/extension/error_handling.dart';
import 'package:ginilog_customer_app/core/helpers/endpoints.dart';
import 'package:ginilog_customer_app/core/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../dto/social_login_request.dart';

class SocialAuthService {
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;

  FirebaseAuth? get firebaseAuth {
    if (_firebaseAuth != null) return _firebaseAuth!;
    try {
      _firebaseAuth = FirebaseAuth.instance;
      return _firebaseAuth!;
    } catch (e) {
      printData('AuthService', 'Firebase not available: $e');
      return null;
    }
  }

  GoogleSignIn get googleSignIn {
    return _googleSignIn ??= GoogleSignIn.instance;
  }

  Future<http.Response> signInWithGoogle() async {
    try {
      final auth = firebaseAuth;
      if (auth == null) {
        throw Exception('Firebase Auth not available');
      }

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final firebaseUser = (await auth.signInWithCredential(credential)).user;

      final fullName = firebaseUser?.displayName ?? "";
      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "LastName";

      final request = SocialLoginRequest(
        email: firebaseUser?.email,
        idToken: firebaseUser?.uid,
        externalId: firebaseUser?.uid,
        firstName: firstName,
        lastName: lastName,
        profilePicture: firebaseUser?.photoURL ?? "",
        phoneNo: firebaseUser?.phoneNumber ?? "0",
      );

      final url = Uri.parse("${Endpoints.baseUrl}auth-users/auth-login");

      var response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      printData("google Login", response.body);
      return response;
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }

  String sha256ofString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  Future<http.Response> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final auth = firebaseAuth;
      if (auth == null) {
        throw Exception('Firebase Auth not available');
      }

      final firebaseUser =
          (await auth.signInWithCredential(oauthCredential)).user;

      final fullName = firebaseUser?.displayName ?? "";
      final nameParts = fullName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "LastName";

      final request = SocialLoginRequest(
        email: firebaseUser?.email,
        idToken: firebaseUser?.uid,
        externalId: firebaseUser?.uid,
        firstName: firstName,
        lastName: lastName,
        profilePicture: firebaseUser?.photoURL ?? "",
        phoneNo: firebaseUser?.phoneNumber ?? "0",
      );

      final url = Uri.parse("${Endpoints.baseUrl}auth-users/auth-login");
      var response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      printData("Apple Login", response.body);
      return response;
    } catch (error) {
      return Future.error(handleHttpError(error));
    }
  }

  Future<void> signOutSocials() async {
    try {
      final auth = firebaseAuth;
      if (auth != null) {
        await auth.signOut();
      }
    } catch (_) {}

    try {
      await googleSignIn.signOut();
    } catch (_) {}

    // Apple usually does not require explicit persistent signout
  }
}
