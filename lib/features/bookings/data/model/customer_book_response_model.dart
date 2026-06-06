// To parse this JSON data, do
//
//     final airlineResponseModel = airlineResponseModelFromJson(jsonString);

import 'dart:convert';

CustomerBookPaginatedModel customerBookPaginatedModelFromJson(String str) =>
    CustomerBookPaginatedModel.fromJson(json.decode(str));

String customerBookPaginatedModelToJson(CustomerBookPaginatedModel data) =>
    json.encode(data.toJson());

class CustomerBookPaginatedModel {
  final List<CustomerBookResponseModel>? data;
  final int? totalCount;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final bool? hasPrevious;
  final bool? hasNext;

  CustomerBookPaginatedModel({
    this.data,
    this.totalCount,
    this.page,
    this.pageSize,
    this.totalPages,
    this.hasPrevious,
    this.hasNext,
  });

  CustomerBookPaginatedModel copyWith({
    List<CustomerBookResponseModel>? data,
    int? totalCount,
    int? page,
    int? pageSize,
    int? totalPages,
    bool? hasPrevious,
    bool? hasNext,
  }) => CustomerBookPaginatedModel(
    data: data ?? this.data,
    totalCount: totalCount ?? this.totalCount,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    totalPages: totalPages ?? this.totalPages,
    hasPrevious: hasPrevious ?? this.hasPrevious,
    hasNext: hasNext ?? this.hasNext,
  );

  factory CustomerBookPaginatedModel.fromJson(Map<String, dynamic> json) =>
      CustomerBookPaginatedModel(
        data:
            json["data"] == null
                ? []
                : List<CustomerBookResponseModel>.from(
                  json["data"]!.map(
                    (x) => CustomerBookResponseModel.fromJson(x),
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

class CustomerBookResponseModel {
  final String? id;
  final String? resevationId;
  final String? accomodationId;
  final String? accomodationType;
  final String? accomodationName;
  final String? accomodationImage;
  final String? accomodationLocation;
  final String? userId;
  final num? roomNumber;
  final String? qrCode;
  final String? customerName;
  final String? customerPhoneNumber;
  final String? customerEmail;
  final num? numberOfGuests;
  final String? trnxReference;
  final String? paymentChannel;
  final bool? paymentStatus;
  final String? comment;
  final String? ticketNum;
  final DateTime? reservationStartDate;
  final DateTime? reservationEndDate;
  final num? noOfDays;
  final bool? ticketClosed;
  final num? totalCost;
  final DateTime? updateddAt;
  final DateTime? createdAt;

  CustomerBookResponseModel({
    this.id,
    this.resevationId,
    this.accomodationId,
    this.accomodationType,
    this.accomodationName,
    this.accomodationImage,
    this.accomodationLocation,
    this.userId,
    this.roomNumber,
    this.qrCode,
    this.customerName,
    this.customerPhoneNumber,
    this.customerEmail,
    this.numberOfGuests,
    this.trnxReference,
    this.paymentChannel,
    this.paymentStatus,
    this.comment,
    this.ticketNum,
    this.reservationStartDate,
    this.reservationEndDate,
    this.noOfDays,
    this.ticketClosed,
    this.totalCost,
    this.updateddAt,
    this.createdAt,
  });

  factory CustomerBookResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => CustomerBookResponseModel(
    id: json["id"],
    resevationId: json["resevationId"],
    accomodationId: json["accomodationId"],
    accomodationType: json["accomodationType"],
    accomodationName: json["accomodationName"],
    accomodationImage: json["accomodationImage"],
    accomodationLocation: json["accomodationLocation"],
    userId: json["userId"],
    roomNumber: json["roomNumber"],
    qrCode: json["qrCode"],
    customerName: json["customerName"],
    customerPhoneNumber: json["customerPhoneNumber"],
    customerEmail: json["customerEmail"],
    numberOfGuests: json["numberOfGuests"],
    trnxReference: json["trnxReference"],
    paymentChannel: json["paymentChannel"],
    paymentStatus: json["paymentStatus"],
    comment: json["comment"],
    ticketNum: json["ticketNum"],
    reservationStartDate:
        json["reservationStartDate"] == null
            ? null
            : DateTime.parse(json["reservationStartDate"]),
    reservationEndDate:
        json["reservationEndDate"] == null
            ? null
            : DateTime.parse(json["reservationEndDate"]),
    noOfDays: json["noOfDays"],
    ticketClosed: json["ticketClosed"],
    totalCost: json["totalCost"],
    updateddAt:
        json["updateddAt"] == null ? null : DateTime.parse(json["updateddAt"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  CustomerBookResponseModel copyWith({
    String? id,
    String? resevationId,
    String? accomodationId,
    String? accomodationType,
    String? accomodationName,
    String? accomodationImage,
    String? accomodationLocation,
    String? userId,
    num? roomNumber,
    String? qrCode,
    String? customerName,
    String? customerPhoneNumber,
    String? customerEmail,
    num? numberOfGuests,
    String? trnxReference,
    String? paymentChannel,
    bool? paymentStatus,
    String? comment,
    String? ticketNum,
    DateTime? reservationStartDate,
    DateTime? reservationEndDate,
    num? noOfDays,
    bool? ticketClosed,
    num? totalCost,
    DateTime? updateddAt,
    DateTime? createdAt,
  }) {
    return CustomerBookResponseModel(
      id: id ?? this.id,
      resevationId: resevationId ?? this.resevationId,
      accomodationId: accomodationId ?? this.accomodationId,
      accomodationType: accomodationType ?? this.accomodationType,
      accomodationName: accomodationName ?? this.accomodationName,
      accomodationImage: accomodationImage ?? this.accomodationImage,
      accomodationLocation: accomodationLocation ?? this.accomodationLocation,
      userId: userId ?? this.userId,
      roomNumber: roomNumber ?? this.roomNumber,
      qrCode: qrCode ?? this.qrCode,
      customerName: customerName ?? this.customerName,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      customerEmail: customerEmail ?? this.customerEmail,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      trnxReference: trnxReference ?? this.trnxReference,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      comment: comment ?? this.comment,
      ticketNum: ticketNum ?? this.ticketNum,
      reservationStartDate: reservationStartDate ?? this.reservationStartDate,
      reservationEndDate: reservationEndDate ?? this.reservationEndDate,
      noOfDays: noOfDays ?? this.noOfDays,
      ticketClosed: ticketClosed ?? this.ticketClosed,
      totalCost: totalCost ?? this.totalCost,
      updateddAt: updateddAt ?? this.updateddAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "resevationId": resevationId,
    "accomodationId": accomodationId,
    "accomodationType": accomodationType,
    "accomodationName": accomodationName,
    "accomodationImage": accomodationImage,
    "accomodationLocation": accomodationLocation,
    "userId": userId,
    "roomNumber": roomNumber,
    "qrCode": qrCode,
    "customerName": customerName,
    "customerPhoneNumber": customerPhoneNumber,
    "customerEmail": customerEmail,
    "numberOfGuests": numberOfGuests,
    "trnxReference": trnxReference,
    "paymentChannel": paymentChannel,
    "paymentStatus": paymentStatus,
    "comment": comment,
    "ticketNum": ticketNum,
    "reservationStartDate": reservationStartDate,
    "reservationEndDate": reservationEndDate,
    "noOfDays": noOfDays,
    "ticketClosed": ticketClosed,
    "totalCost": totalCost,
    "updateddAt": updateddAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
  };
}
