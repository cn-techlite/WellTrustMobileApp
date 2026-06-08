// To parse this JSON data, do
//
//     final accomodationReservationResponseModel = accomodationReservationResponseModelFromJson(jsonString);

import 'dart:convert';

AccomodationReservationPaginatedModel
accomodationReservationPaginatedModelFromJson(String str) =>
    AccomodationReservationPaginatedModel.fromJson(json.decode(str));

String accomodationReservationPaginatedModelToJson(
  AccomodationReservationPaginatedModel data,
) => json.encode(data.toJson());

class AccomodationReservationPaginatedModel {
  final List<AccomodationReservationResponseModel>? data;
  final int? totalCount;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final bool? hasPrevious;
  final bool? hasNext;

  AccomodationReservationPaginatedModel({
    this.data,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasPrevious,
    this.hasNext,
  });

  AccomodationReservationPaginatedModel copyWith({
    List<AccomodationReservationResponseModel>? data,
    int? totalCount,
    int? page,
    int? pageSize,
    int? totalPages,
    bool? hasPrevious,
    bool? hasNext,
  }) => AccomodationReservationPaginatedModel(
    data: data ?? this.data,
    totalCount: totalCount ?? this.totalCount,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    totalPages: totalPages ?? this.totalPages,
    hasPrevious: hasPrevious ?? this.hasPrevious,
    hasNext: hasNext ?? this.hasNext,
  );

  factory AccomodationReservationPaginatedModel.fromJson(
    Map<String, dynamic> json,
  ) => AccomodationReservationPaginatedModel(
    data:
        json["data"] == null
            ? []
            : List<AccomodationReservationResponseModel>.from(
              json["data"]!.map(
                (x) => AccomodationReservationResponseModel.fromJson(x),
              ),
            ),
    totalCount: json["totalCount"],
    page: json["page"],
    pageSize: json["pageSize"],
    totalPages: json["totalPages"],
    hasPrevious: json["hasPrevious"],
    hasNext: json["hasNext"],
  );

  Map<String, dynamic> toJson() => {
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "totalCount": totalCount,
    "page": page,
    "pageSize": pageSize,
    "totalPages": totalPages,
    "hasPrevious": hasPrevious,
    "hasNext": hasNext,
  };
}

class AccomodationReservationResponseModel {
  final String? id;
  final String? accomodationId;
  final String? adminId;
  final String? accomodationName;
  final String? accomodationType;
  final String? accomodationLocality;
  final String? accomodationState;
  final String? accomodationImage;
  final String? ticketNum;
  final num? roomNumber;
  final num? maximumNoOfGuest;
  final num? roomPrice;
  final String? roomType;
  final List<String>? roomImages;
  final List<String>? roomFeatures;
  final String? qrCode;
  final bool? isBooked;
  final DateTime? updateddAt;
  final DateTime? createdAt;
  final String? checkInTime;
  final String? checkOutTime;
  final String? location;

  AccomodationReservationResponseModel({
    this.id,
    this.accomodationId,
    this.adminId,
    this.accomodationName,
    this.accomodationType,
    this.accomodationLocality,
    this.accomodationState,
    this.accomodationImage,
    this.ticketNum,
    this.roomNumber,
    this.maximumNoOfGuest,
    this.roomPrice,
    this.roomType,
    this.roomImages,
    this.roomFeatures,
    this.qrCode,
    this.isBooked,
    this.updateddAt,
    this.createdAt,
    this.checkInTime,
    this.checkOutTime,
    this.location,
  });

  factory AccomodationReservationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => AccomodationReservationResponseModel(
    id: json["id"] ?? "",
    accomodationId: json["accomodationId"] ?? "",
    adminId: json["adminId"] ?? "",
    accomodationName: json["accomodationName"] ?? "",
    accomodationType: json["accomodationType"] ?? "",
    accomodationLocality: json["accomodationLocality"] ?? "",
    accomodationState: json["accomodationState"] ?? "",
    accomodationImage: json["accomodationImage"] ?? "",
    ticketNum: json["ticketNum"] ?? "",
    roomNumber: json["roomNumber"] ?? 0,
    maximumNoOfGuest: json["maximumNoOfGuest"] ?? 0,
    roomPrice: json["roomPrice"] ?? 0,
    roomType: json["roomType"] ?? "",
    roomImages:
        json["roomImages"] == null
            ? []
            : List<String>.from(json["roomImages"]!.map((x) => x)),
    roomFeatures:
        json["roomFeatures"] == null
            ? []
            : List<String>.from(json["roomFeatures"]!.map((x) => x)),
    qrCode: json["qrCode"],
    isBooked: json["isBooked"],
    updateddAt:
        json["updateddAt"] == null ? null : DateTime.parse(json["updateddAt"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    checkInTime: json["checkInTime"] ?? "",
    checkOutTime: json["checkOutTime"] ?? "",
    location: json["location"] ?? "",
  );

  AccomodationReservationResponseModel copyWith({
    String? id,
    String? accomodationId,
    String? adminId,
    String? accomodationName,
    String? accomodationType,
    String? accomodationLocality,
    String? accomodationState,
    String? accomodationImage,
    String? ticketNum,
    num? roomNumber,
    num? maximumNoOfGuest,
    num? roomPrice,
    String? roomType,
    List<String>? roomImages,
    List<String>? roomFeatures,
    String? qrCode,
    bool? isBooked,
    DateTime? updateddAt,
    DateTime? createdAt,
    String? checkInTime,
    String? checkOutTime,
    String? location,
  }) {
    return AccomodationReservationResponseModel(
      id: id ?? this.id,
      accomodationId: accomodationId ?? this.accomodationId,
      adminId: adminId ?? this.adminId,
      accomodationName: accomodationName ?? this.accomodationName,
      accomodationType: accomodationType ?? this.accomodationType,
      accomodationLocality: accomodationLocality ?? this.accomodationLocality,
      accomodationState: accomodationState ?? this.accomodationState,
      accomodationImage: accomodationImage ?? this.accomodationImage,
      ticketNum: ticketNum ?? this.ticketNum,
      roomNumber: roomNumber ?? this.roomNumber,
      maximumNoOfGuest: maximumNoOfGuest ?? this.maximumNoOfGuest,
      roomPrice: roomPrice ?? this.roomPrice,
      roomType: roomType ?? this.roomType,
      roomImages: roomImages ?? this.roomImages,
      roomFeatures: roomFeatures ?? this.roomFeatures,
      qrCode: qrCode ?? this.qrCode,
      isBooked: isBooked ?? this.isBooked,
      updateddAt: updateddAt ?? this.updateddAt,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "accomodationId": accomodationId,
    "adminId": adminId,
    "accomodationName": accomodationName,
    "accomodationType": accomodationType,
    "accomodationLocality": accomodationLocality,
    "accomodationState": accomodationState,
    "accomodationImage": accomodationImage,
    "ticketNum": ticketNum,
    "roomNumber": roomNumber,
    "roomPrice": roomPrice,
    "maximumNoOfGuest": maximumNoOfGuest,
    "roomType": roomType,
    "roomImages":
        roomImages == null ? [] : List<dynamic>.from(roomImages!.map((x) => x)),
    "roomFeatures":
        roomFeatures == null
            ? []
            : List<dynamic>.from(roomFeatures!.map((x) => x)),
    "qrCode": qrCode,
    "isBooked": isBooked,
    "updateddAt": updateddAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "checkInTime": checkInTime,
    "checkOutTime": checkOutTime,
    "location": location,
  };
}
