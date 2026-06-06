// To parse this JSON data, do
//
//     final RegisterRequest  = RegisterRequest FromJson(jsonString);

class RegisterRequest {
  final String lastName;
  final String firstName;
  final String email;
  final String password;
  final String phoneNo;

  RegisterRequest({
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.password,
    required this.phoneNo,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        lastName: json["lastName"],
        firstName: json["firstName"],
        email: json["email"],
        password: json["password"],
        phoneNo: json["phoneNo"],
      );

  Map<String, dynamic> toJson() => {
    "lastName": lastName,
    "firstName": firstName,
    "email": email,
    "password": password,
    "phoneNo": phoneNo,
  };
}
