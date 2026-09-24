class VerifyEmailRequest {
  final String token;
  final String password;

  const VerifyEmailRequest({required this.token, required this.password});

  Map<String, dynamic> toJson() {
    return {"token": token, "password": password};
  }
}
