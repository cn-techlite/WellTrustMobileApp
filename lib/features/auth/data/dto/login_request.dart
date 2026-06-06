class LoginRequest {
  final String identifier;
  final String password;

  const LoginRequest({required this.identifier, required this.password});

  Map<String, dynamic> toJson() {
    return {"email_PhoneNo": identifier, "password": password};
  }
}
