/// Body for POST /api/welltrust-kiosk/login.
class LoginRequest {
  final String username;
  final String pin;

  const LoginRequest({required this.username, required this.pin});

  Map<String, dynamic> toJson() {
    return {"username": username, "passcode": pin};
  }
}
