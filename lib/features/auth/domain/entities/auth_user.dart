class AuthUser {
  final String? token;
  final String? email;
  final String? userId;
  final String? fullName;
  final String? profileImage;
  final bool emailVerified;
  final bool? activateBrand;

  const AuthUser({
    this.token,
    this.email,
    this.userId,
    this.fullName,
    this.profileImage,
    required this.emailVerified,
    this.activateBrand,
  });
}
