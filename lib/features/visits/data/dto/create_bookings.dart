class CreateAccomodationReservationRequest {
  final String reservationId;
  final String userId;
  final String customerName;
  final String customerPhoneNumber;
  final String? customerEmail;
  final String? trnxReference;
  final bool paymentStatus;
  final num numberOfGuests;
  final String paymentChannel;
  final String comment;
  final bool ticketClosed;
  final String reservationStartDate;
  final String reservationEndDate;
  final num noOfDays;
  final String staffId;
  final String staffName;
  final String purchaseChannel;
  final String userType;
  final String paymentType;

  const CreateAccomodationReservationRequest({
    required this.reservationId,
    required this.userId,
    required this.customerName,
    required this.customerPhoneNumber,
    required this.customerEmail,
    required this.trnxReference,
    required this.paymentStatus,
    required this.numberOfGuests,
    required this.paymentChannel,
    required this.comment,
    required this.ticketClosed,
    required this.reservationStartDate,
    required this.reservationEndDate,
    required this.noOfDays,
    required this.staffId,
    required this.staffName,
    required this.purchaseChannel,
    required this.userType,
    required this.paymentType,
  });

  Map<String, dynamic> toJson() {
    return {
      "reservationId": reservationId,
      "userId": userId,
      "customerName": customerName,
      "customerPhoneNumber": customerPhoneNumber,
      "customerEmail": customerEmail,
      "trnxReference": trnxReference,
      "paymentStatus": paymentStatus,
      "numberOfGuests": numberOfGuests,
      "paymentChannel": paymentChannel,
      "comment": comment,
      "ticketClosed": ticketClosed,
      "reservationStartDate": reservationStartDate,
      "reservationEndDate": reservationEndDate,
      "noOfDays": noOfDays,
      "staffId": staffId,
      "staffName": staffName,
      "purchaseChannel": purchaseChannel,
      "userType": userType,
      "paymentType": paymentType,
    };
  }
}
