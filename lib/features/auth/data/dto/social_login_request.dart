class SocialLoginRequest {
  final String? email;
  final String? idToken;
  final String? externalId;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final String phoneNo;

  const SocialLoginRequest({
    required this.email,
    required this.idToken,
    required this.externalId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.phoneNo,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "idToken": idToken,
      "externalId": externalId,
      "firstName": firstName,
      "lastName": lastName,
      "profilePicture": profilePicture,
      "phoneNo": phoneNo,
    };
  }
}
