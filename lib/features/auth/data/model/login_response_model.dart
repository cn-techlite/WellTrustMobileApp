// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  final String? token;
  final String? refreshToken;
  final String? email;
  final String? userId;
  final String? userType;
  final bool? emailVerified;
  final bool? phoneVerified;
  final String? fullName;
  final String? profileImage;
  final String? idAuthPassword;
  final bool? walletActivation;
  final List<String>? roles;
  final List<String>? permissions;
  final DateTime? refreshTokenExpiryTime;

  LoginResponseModel({
    this.token,
    this.refreshToken,
    this.email,
    this.userId,
    this.userType,
    this.emailVerified,
    this.phoneVerified,
    this.fullName,
    this.profileImage,
    this.idAuthPassword,
    this.walletActivation,
    this.roles,
    this.permissions,
    this.refreshTokenExpiryTime,
  });

  LoginResponseModel copyWith({
    String? token,
    String? refreshToken,
    String? email,
    String? userId,
    String? userType,
    bool? emailVerified,
    bool? phoneVerified,
    String? fullName,
    String? profileImage,
    String? idAuthPassword,
    bool? walletActivation,
    bool? activateProfession,
    bool? activateBrand,
    List<String>? roles,
    List<String>? permissions,
    DateTime? refreshTokenExpiryTime,
    String? videoSdkToken,
  }) => LoginResponseModel(
    token: token ?? this.token,
    refreshToken: refreshToken ?? this.refreshToken,
    email: email ?? this.email,
    userId: userId ?? this.userId,
    userType: userType ?? this.userType,
    emailVerified: emailVerified ?? this.emailVerified,
    phoneVerified: phoneVerified ?? this.phoneVerified,
    fullName: fullName ?? this.fullName,
    profileImage: profileImage ?? this.profileImage,
    idAuthPassword: idAuthPassword ?? this.idAuthPassword,
    walletActivation: walletActivation ?? this.walletActivation,
    roles: roles ?? this.roles,
    permissions: permissions ?? this.permissions,
    refreshTokenExpiryTime:
        refreshTokenExpiryTime ?? this.refreshTokenExpiryTime,
  );

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        token: json["token"],
        refreshToken: json["refreshToken"],
        email: json["email"],
        userId: json["userId"],
        userType: json["userType"],
        emailVerified: json["emailVerified"],
        phoneVerified: json["phoneVerified"],
        fullName: json["fullName"],
        profileImage: json["profileImage"],
        idAuthPassword: json["idAuthPassword"],
        walletActivation: json["walletActivation"],
        roles:
            json["roles"] == null
                ? []
                : List<String>.from(json["roles"]!.map((x) => x)),
        permissions:
            json["permissions"] == null
                ? []
                : List<String>.from(json["permissions"]!.map((x) => x)),
        refreshTokenExpiryTime:
            json["refreshTokenExpiryTime"] == null
                ? null
                : DateTime.parse(json["refreshTokenExpiryTime"]),
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "refreshToken": refreshToken,
    "email": email,
    "userId": userId,
    "userType": userType,
    "emailVerified": emailVerified,
    "phoneVerified": phoneVerified,
    "fullName": fullName,
    "profileImage": profileImage,
    "idAuthPassword": idAuthPassword,
    "walletActivation": walletActivation,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "permissions":
        permissions == null
            ? []
            : List<dynamic>.from(permissions!.map((x) => x)),
    "refreshTokenExpiryTime": refreshTokenExpiryTime?.toIso8601String(),
  };
}
