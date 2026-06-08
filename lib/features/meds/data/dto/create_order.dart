class CreatePackageOrderRequest {
  final String companyId;
  final String itemName;
  final String itemDescription;
  final String itemModelNumber;
  final num itemCost;
  final num itemWeight;
  final int itemQuantity;
  final String packageType;

  final String senderName;
  final String senderPhoneNo;
  final String senderEmail;
  final String senderAddress;
  final String senderState;
  final String senderCountry;
  final String senderLocality;
  final String senderPostalCode;
  final num senderLatitude;
  final num senderLongitude;

  final String recieverName;
  final String recieverPhoneNo;
  final String recieverEmail;
  final String recieverAddress;
  final String recieverState;
  final String recieverCountry;
  final String recieverLocality;
  final String recieverPostalCode;
  final num recieverLatitude;
  final num recieverLongitude;

  final List<String> packageImageLists;

  final String riderType;
  final String shippingType;

  final String staffId;
  final String staffName;
  final String purchaseChannel;
  final String userType;

  const CreatePackageOrderRequest({
    required this.companyId,
    required this.itemName,
    required this.itemDescription,
    required this.itemModelNumber,
    required this.itemCost,
    required this.itemWeight,
    required this.itemQuantity,
    required this.packageType,
    required this.senderName,
    required this.senderPhoneNo,
    required this.senderEmail,
    required this.senderAddress,
    required this.senderState,
    required this.senderCountry,
    required this.senderLocality,
    required this.senderPostalCode,
    required this.senderLatitude,
    required this.senderLongitude,
    required this.recieverName,
    required this.recieverPhoneNo,
    required this.recieverEmail,
    required this.recieverAddress,
    required this.recieverState,
    required this.recieverCountry,
    required this.recieverLocality,
    required this.recieverPostalCode,
    required this.recieverLatitude,
    required this.recieverLongitude,
    required this.packageImageLists,
    required this.riderType,
    required this.shippingType,
    required this.staffId,
    required this.staffName,
    required this.purchaseChannel,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      "companyId": companyId,
      "itemName": itemName,
      "itemDescription": itemDescription,
      "itemModelNumber": itemModelNumber,
      "itemCost": itemCost,
      "itemWeight": itemWeight,
      "itemQuantity": itemQuantity,
      "packageType": packageType,

      "senderName": senderName,
      "senderPhoneNo": senderPhoneNo,
      "senderEmail": senderEmail,
      "senderAddress": senderAddress,
      "senderState": senderState,
      "senderCountry": senderCountry,
      "senderLocality": senderLocality,
      "senderPostalCode": senderPostalCode,
      "senderLatitude": senderLatitude,
      "senderLongitude": senderLongitude,

      "recieverName": recieverName,
      "recieverPhoneNo": recieverPhoneNo,
      "recieverEmail": recieverEmail,
      "recieverAddress": recieverAddress,
      "recieverState": recieverState,
      "recieverCountry": recieverCountry,
      "recieverLocality": recieverLocality,
      "recieverPostalCode": recieverPostalCode,
      "recieverLatitude": recieverLatitude,
      "recieverLongitude": recieverLongitude,

      "packageImageLists": packageImageLists,

      "riderType": riderType,
      "shippingType": shippingType,

      "staffId": staffId,
      "staffName": staffName,
      "purchaseChannel": purchaseChannel,
      "userType": userType,
    };
  }
}
