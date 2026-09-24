class AuthState {
  static const pinLength = 5;

  final bool rememberMe;

  /// Sign-in credentials: a username and the 5 digit passcode (PIN).
  final String username;
  final String pin;

  const AuthState({this.rememberMe = false, this.username = '', this.pin = ''});

  static bool isValidPin(String value) => RegExp(r'^\d{5}$').hasMatch(value);

  bool get canLogin => username.trim().isNotEmpty && isValidPin(pin);

  AuthState copyWith({bool? rememberMe, String? username, String? pin}) {
    return AuthState(
      rememberMe: rememberMe ?? this.rememberMe,
      username: username ?? this.username,
      pin: pin ?? this.pin,
    );
  }
}
