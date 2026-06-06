class AuthState {
  final bool rememberMe;
  final bool agreedToTerms;
  final bool isEmailSelected;
  final bool isPhoneSelected;

  final String email;
  final String password;
  final String phone;
  final String countryCode;

  final String firstName;
  final String lastName;
  final String confirmPassword;
  final String otp;

  const AuthState({
    this.rememberMe = false,
    this.agreedToTerms = false,
    this.isEmailSelected = true,
    this.isPhoneSelected = false,
    this.email = '',
    this.password = '',
    this.phone = '',
    this.countryCode = '+234',
    this.firstName = '',
    this.lastName = '',
    this.confirmPassword = '',
    this.otp = '',
  });

  bool get canLogin {
    final identifier = isPhoneSelected ? phone.trim() : email.trim();
    return identifier.isNotEmpty && password.trim().isNotEmpty;
  }

  bool get canRegister {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        agreedToTerms;
  }

  bool get canResetPassword {
    return otp.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        confirmPassword.trim().isNotEmpty &&
        password.trim() == confirmPassword.trim();
  }

  AuthState copyWith({
    bool? rememberMe,
    bool? agreedToTerms,
    bool? isEmailSelected,
    bool? isPhoneSelected,
    String? email,
    String? password,
    String? phone,
    String? countryCode,
    String? firstName,
    String? lastName,
    String? confirmPassword,
    String? otp,
  }) {
    return AuthState(
      rememberMe: rememberMe ?? this.rememberMe,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      isEmailSelected: isEmailSelected ?? this.isEmailSelected,
      isPhoneSelected: isPhoneSelected ?? this.isPhoneSelected,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      otp: otp ?? this.otp,
    );
  }
}
