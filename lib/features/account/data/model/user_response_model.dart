// To parse this JSON data, do
//
//     final registerResponseModel = registerResponseModelFromJson(jsonString);

import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) =>
    RegisterResponseModel.fromJson(json.decode(str));

String registerResponseModelToJson(RegisterResponseModel data) =>
    json.encode(data.toJson());

DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;

int? _int(dynamic v) => v is num ? v.toInt() : null;

List<String> _strings(dynamic v) =>
    v is List ? [for (final x in v) x.toString()] : const [];

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) parse) => v is List
    ? [
        for (final x in v)
          if (x is Map<String, dynamic>) parse(x),
      ]
    : const [];

/// The signed-in staff member, with their staff record.
class RegisterResponseModel {
  final String? id;
  final String? adminType;
  final String? email;
  final String? surName;
  final String? firstName;
  final String? staffCode;
  final String? phoneNo;
  final String? imagePath;
  final String? sex;
  final String? state;
  final String? locality;
  final String? address;
  final String? branch;
  final String? bankAccName;
  final String? bankAccNo;
  final String? bankSortCode;
  final String? insuranceNo;
  final String? dbsCode;
  final DateTime? dateOfBirth;
  final String? nextOfKin;
  final String? nextOfKinPhoneNo;
  final String? referenceEmail;
  final String? referenceEmail2;
  final String? nationality;
  final DateTime? createdAt;
  final String? staffStatus;
  final List<String> roles;
  final List<String> permissions;
  final bool? archivedAccount;
  final bool? suspendedAccount;
  final String? status;
  final String? complianceStatus;
  final StaffProfile? profile;
  final StaffCompliance? compliance;
  final StaffEmploymentPay? employmentPay;
  final StaffEmergencyContact? emergencyContact;
  final List<StaffQualification> qualifications;
  final List<StaffCertificate> certificates;
  final List<StaffCompetency> competencies;
  final List<StaffDocument> documents;
  final StaffAppointmentLetter? appointmentLetter;

  RegisterResponseModel({
    this.id,
    this.adminType,
    this.email,
    this.surName,
    this.firstName,
    this.staffCode,
    this.phoneNo,
    this.imagePath,
    this.sex,
    this.state,
    this.locality,
    this.address,
    this.branch,
    this.bankAccName,
    this.bankAccNo,
    this.bankSortCode,
    this.insuranceNo,
    this.dbsCode,
    this.dateOfBirth,
    this.nextOfKin,
    this.nextOfKinPhoneNo,
    this.referenceEmail,
    this.referenceEmail2,
    this.nationality,
    this.createdAt,
    this.staffStatus,
    this.roles = const [],
    this.permissions = const [],
    this.archivedAccount,
    this.suspendedAccount,
    this.status,
    this.complianceStatus,
    this.profile,
    this.compliance,
    this.employmentPay,
    this.emergencyContact,
    this.qualifications = const [],
    this.certificates = const [],
    this.competencies = const [],
    this.documents = const [],
    this.appointmentLetter,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        id: json["id"],
        adminType: json["adminType"],
        email: json["email"],
        surName: json["surName"],
        firstName: json["firstName"],
        staffCode: json["staffCode"],
        phoneNo: json["phoneNo"],
        imagePath: json["imagePath"],
        sex: json["sex"],
        state: json["state"],
        locality: json["locality"],
        address: json["address"],
        branch: json["branch"],
        bankAccName: json["bankAccName"],
        bankAccNo: json["bankAccNo"],
        bankSortCode: json["bankSortCode"],
        insuranceNo: json["insuranceNo"],
        dbsCode: json["dbsCode"],
        dateOfBirth: _date(json["dateOfBirth"]),
        nextOfKin: json["nextOfKin"],
        nextOfKinPhoneNo: json["nextOfKinPhoneNo"],
        referenceEmail: json["referenceEmail"],
        referenceEmail2: json["referenceEmail2"],
        nationality: json["nationality"],
        createdAt: _date(json["createdAt"]),
        staffStatus: json["staffStatus"],
        roles: _strings(json["roles"]),
        permissions: _strings(json["permissions"]),
        archivedAccount: json["archivedAccount"],
        suspendedAccount: json["suspendedAccount"],
        status: json["status"],
        complianceStatus: json["complianceStatus"],
        profile: json["profile"] == null
            ? null
            : StaffProfile.fromJson(json["profile"]),
        compliance: json["compliance"] == null
            ? null
            : StaffCompliance.fromJson(json["compliance"]),
        employmentPay: json["employmentPay"] == null
            ? null
            : StaffEmploymentPay.fromJson(json["employmentPay"]),
        emergencyContact: json["emergencyContact"] == null
            ? null
            : StaffEmergencyContact.fromJson(json["emergencyContact"]),
        qualifications: _list(
          json["qualifications"],
          StaffQualification.fromJson,
        ),
        certificates: _list(json["certificates"], StaffCertificate.fromJson),
        competencies: _list(json["competencies"], StaffCompetency.fromJson),
        documents: _list(json["documents"], StaffDocument.fromJson),
        appointmentLetter: json["appointmentLetter"] == null
            ? null
            : StaffAppointmentLetter.fromJson(json["appointmentLetter"]),
      );

  RegisterResponseModel copyWith({
    String? id,
    String? adminType,
    String? email,
    String? surName,
    String? firstName,
    String? staffCode,
    String? phoneNo,
    String? imagePath,
    String? sex,
    String? state,
    String? locality,
    String? address,
    String? branch,
    String? bankAccName,
    String? bankAccNo,
    String? bankSortCode,
    String? insuranceNo,
    String? dbsCode,
    DateTime? dateOfBirth,
    String? nextOfKin,
    String? nextOfKinPhoneNo,
    String? referenceEmail,
    String? referenceEmail2,
    String? nationality,
    DateTime? createdAt,
    String? staffStatus,
    List<String>? roles,
    List<String>? permissions,
    bool? archivedAccount,
    bool? suspendedAccount,
    String? status,
    String? complianceStatus,
    StaffProfile? profile,
    StaffCompliance? compliance,
    StaffEmploymentPay? employmentPay,
    StaffEmergencyContact? emergencyContact,
    List<StaffQualification>? qualifications,
    List<StaffCertificate>? certificates,
    List<StaffCompetency>? competencies,
    List<StaffDocument>? documents,
    StaffAppointmentLetter? appointmentLetter,
  }) {
    return RegisterResponseModel(
      id: id ?? this.id,
      adminType: adminType ?? this.adminType,
      email: email ?? this.email,
      surName: surName ?? this.surName,
      firstName: firstName ?? this.firstName,
      staffCode: staffCode ?? this.staffCode,
      phoneNo: phoneNo ?? this.phoneNo,
      imagePath: imagePath ?? this.imagePath,
      sex: sex ?? this.sex,
      state: state ?? this.state,
      locality: locality ?? this.locality,
      address: address ?? this.address,
      branch: branch ?? this.branch,
      bankAccName: bankAccName ?? this.bankAccName,
      bankAccNo: bankAccNo ?? this.bankAccNo,
      bankSortCode: bankSortCode ?? this.bankSortCode,
      insuranceNo: insuranceNo ?? this.insuranceNo,
      dbsCode: dbsCode ?? this.dbsCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nextOfKin: nextOfKin ?? this.nextOfKin,
      nextOfKinPhoneNo: nextOfKinPhoneNo ?? this.nextOfKinPhoneNo,
      referenceEmail: referenceEmail ?? this.referenceEmail,
      referenceEmail2: referenceEmail2 ?? this.referenceEmail2,
      nationality: nationality ?? this.nationality,
      createdAt: createdAt ?? this.createdAt,
      staffStatus: staffStatus ?? this.staffStatus,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      archivedAccount: archivedAccount ?? this.archivedAccount,
      suspendedAccount: suspendedAccount ?? this.suspendedAccount,
      status: status ?? this.status,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      profile: profile ?? this.profile,
      compliance: compliance ?? this.compliance,
      employmentPay: employmentPay ?? this.employmentPay,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      qualifications: qualifications ?? this.qualifications,
      certificates: certificates ?? this.certificates,
      competencies: competencies ?? this.competencies,
      documents: documents ?? this.documents,
      appointmentLetter: appointmentLetter ?? this.appointmentLetter,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminType": adminType,
    "email": email,
    "surName": surName,
    "firstName": firstName,
    "staffCode": staffCode,
    "phoneNo": phoneNo,
    "imagePath": imagePath,
    "sex": sex,
    "state": state,
    "locality": locality,
    "address": address,
    "branch": branch,
    "bankAccName": bankAccName,
    "bankAccNo": bankAccNo,
    "bankSortCode": bankSortCode,
    "insuranceNo": insuranceNo,
    "dbsCode": dbsCode,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "nextOfKin": nextOfKin,
    "nextOfKinPhoneNo": nextOfKinPhoneNo,
    "referenceEmail": referenceEmail,
    "referenceEmail2": referenceEmail2,
    "nationality": nationality,
    "createdAt": createdAt?.toIso8601String(),
    "staffStatus": staffStatus,
    "roles": roles,
    "permissions": permissions,
    "archivedAccount": archivedAccount,
    "suspendedAccount": suspendedAccount,
    "status": status,
    "complianceStatus": complianceStatus,
    "profile": profile?.toJson(),
    "compliance": compliance?.toJson(),
    "employmentPay": employmentPay?.toJson(),
    "emergencyContact": emergencyContact?.toJson(),
    "qualifications": [for (final x in qualifications) x.toJson()],
    "certificates": [for (final x in certificates) x.toJson()],
    "competencies": [for (final x in competencies) x.toJson()],
    "documents": [for (final x in documents) x.toJson()],
    "appointmentLetter": appointmentLetter?.toJson(),
  };
}

/// Job and address details.
class StaffProfile {
  final String? id;
  final String? adminStaffId;
  final String? jobTitle;
  final String? employmentType;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? county;
  final String? postCode;
  final String? country;
  final String? shiftPattern;
  final String? availabilityNotes;
  final String? wingArea;
  final String? keyWorkerFor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffProfile({
    this.id,
    this.adminStaffId,
    this.jobTitle,
    this.employmentType,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.county,
    this.postCode,
    this.country,
    this.shiftPattern,
    this.availabilityNotes,
    this.wingArea,
    this.keyWorkerFor,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) => StaffProfile(
    id: json["id"],
    adminStaffId: json["adminStaffId"],
    jobTitle: json["jobTitle"],
    employmentType: json["employmentType"],
    dateOfBirth: _date(json["dateOfBirth"]),
    gender: json["gender"],
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
    city: json["city"],
    county: json["county"],
    postCode: json["postCode"],
    country: json["country"],
    shiftPattern: json["shiftPattern"],
    availabilityNotes: json["availabilityNotes"],
    wingArea: json["wingArea"],
    keyWorkerFor: json["keyWorkerFor"],
    createdAt: _date(json["createdAt"]),
    updatedAt: _date(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "jobTitle": jobTitle,
    "employmentType": employmentType,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "gender": gender,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "city": city,
    "county": county,
    "postCode": postCode,
    "country": country,
    "shiftPattern": shiftPattern,
    "availabilityNotes": availabilityNotes,
    "wingArea": wingArea,
    "keyWorkerFor": keyWorkerFor,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// DBS, right to work and registration checks, read only for staff. A field that
/// does not apply comes back as null. Dates are also null if the API sends text
/// such as "N/A - reason", so treat both the same: not applicable.
class StaffCompliance {
  final String? id;
  final String? adminStaffId;
  final String? niNumber;
  final String? dbsStatus;
  final String? dbsCertificateUrl;
  final DateTime? dbsCheckDate;
  final DateTime? dbsExpiryDate;
  final String? dbsType;
  final String? dbsDisclosureNumber;
  final String? dbsUpdateServiceStatus;
  final String? rightToWorkStatus;
  final String? rightToWorkDocumentUrl;
  final DateTime? rightToWorkExpiryDate;
  final DateTime? rightToWorkCheckDate;
  final String? rightToWorkShareCode;
  final String? ukVisaType;
  final String? visaNumber;
  final DateTime? visaExpiryDate;
  final String? passportNumber;
  final DateTime? passportExpiryDate;
  final String? registrationNumber;
  final String? registrationBody;
  final DateTime? registrationDate;
  final DateTime? registrationExpiryDate;
  final String? checkedBy;
  final String? rightToWorkDocumentType;
  final String? rightToWorkDocumentReference;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffCompliance({
    this.id,
    this.adminStaffId,
    this.niNumber,
    this.dbsStatus,
    this.dbsCertificateUrl,
    this.dbsCheckDate,
    this.dbsExpiryDate,
    this.dbsType,
    this.dbsDisclosureNumber,
    this.dbsUpdateServiceStatus,
    this.rightToWorkStatus,
    this.rightToWorkDocumentUrl,
    this.rightToWorkExpiryDate,
    this.rightToWorkCheckDate,
    this.rightToWorkShareCode,
    this.ukVisaType,
    this.visaNumber,
    this.visaExpiryDate,
    this.passportNumber,
    this.passportExpiryDate,
    this.registrationNumber,
    this.registrationBody,
    this.registrationDate,
    this.registrationExpiryDate,
    this.checkedBy,
    this.rightToWorkDocumentType,
    this.rightToWorkDocumentReference,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffCompliance.fromJson(Map<String, dynamic> json) =>
      StaffCompliance(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        niNumber: json["niNumber"],
        dbsStatus: json["dbsStatus"],
        dbsCertificateUrl: json["dbsCertificateUrl"],
        dbsCheckDate: _date(json["dbsCheckDate"]),
        dbsExpiryDate: _date(json["dbsExpiryDate"]),
        dbsType: json["dbsType"],
        dbsDisclosureNumber: json["dbsDisclosureNumber"],
        dbsUpdateServiceStatus: json["dbsUpdateServiceStatus"],
        rightToWorkStatus: json["rightToWorkStatus"],
        rightToWorkDocumentUrl: json["rightToWorkDocumentUrl"],
        rightToWorkExpiryDate: _date(json["rightToWorkExpiryDate"]),
        rightToWorkCheckDate: _date(json["rightToWorkCheckDate"]),
        rightToWorkShareCode: json["rightToWorkShareCode"],
        ukVisaType: json["ukVisaType"],
        visaNumber: json["visaNumber"],
        visaExpiryDate: _date(json["visaExpiryDate"]),
        passportNumber: json["passportNumber"],
        passportExpiryDate: _date(json["passportExpiryDate"]),
        registrationNumber: json["registrationNumber"],
        registrationBody: json["registrationBody"],
        registrationDate: _date(json["registrationDate"]),
        registrationExpiryDate: _date(json["registrationExpiryDate"]),
        checkedBy: json["checkedBy"],
        rightToWorkDocumentType: json["rightToWorkDocumentType"],
        rightToWorkDocumentReference: json["rightToWorkDocumentReference"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "niNumber": niNumber,
    "dbsStatus": dbsStatus,
    "dbsCertificateUrl": dbsCertificateUrl,
    "dbsCheckDate": dbsCheckDate?.toIso8601String(),
    "dbsExpiryDate": dbsExpiryDate?.toIso8601String(),
    "dbsType": dbsType,
    "dbsDisclosureNumber": dbsDisclosureNumber,
    "dbsUpdateServiceStatus": dbsUpdateServiceStatus,
    "rightToWorkStatus": rightToWorkStatus,
    "rightToWorkDocumentUrl": rightToWorkDocumentUrl,
    "rightToWorkExpiryDate": rightToWorkExpiryDate?.toIso8601String(),
    "rightToWorkCheckDate": rightToWorkCheckDate?.toIso8601String(),
    "rightToWorkShareCode": rightToWorkShareCode,
    "ukVisaType": ukVisaType,
    "visaNumber": visaNumber,
    "visaExpiryDate": visaExpiryDate?.toIso8601String(),
    "passportNumber": passportNumber,
    "passportExpiryDate": passportExpiryDate?.toIso8601String(),
    "registrationNumber": registrationNumber,
    "registrationBody": registrationBody,
    "registrationDate": registrationDate?.toIso8601String(),
    "registrationExpiryDate": registrationExpiryDate?.toIso8601String(),
    "checkedBy": checkedBy,
    "rightToWorkDocumentType": rightToWorkDocumentType,
    "rightToWorkDocumentReference": rightToWorkDocumentReference,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// Contract dates and pay, read only for staff. [employmentEndDate] is null for a
/// permanent contract.
class StaffEmploymentPay {
  final String? id;
  final String? adminStaffId;
  final DateTime? employmentStartDate;
  final DateTime? employmentEndDate;
  final num? hourlyRate;
  final num? annualSalary;
  final String? currency;
  final num? hoursPerWeek;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffEmploymentPay({
    this.id,
    this.adminStaffId,
    this.employmentStartDate,
    this.employmentEndDate,
    this.hourlyRate,
    this.annualSalary,
    this.currency,
    this.hoursPerWeek,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffEmploymentPay.fromJson(Map<String, dynamic> json) =>
      StaffEmploymentPay(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        employmentStartDate: _date(json["employmentStartDate"]),
        employmentEndDate: _date(json["employmentEndDate"]),
        hourlyRate: json["hourlyRate"],
        annualSalary: json["annualSalary"],
        currency: json["currency"],
        hoursPerWeek: json["hoursPerWeek"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "employmentStartDate": employmentStartDate?.toIso8601String(),
    "employmentEndDate": employmentEndDate?.toIso8601String(),
    "hourlyRate": hourlyRate,
    "annualSalary": annualSalary,
    "currency": currency,
    "hoursPerWeek": hoursPerWeek,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// Who to call in an emergency.
class StaffEmergencyContact {
  final String? id;
  final String? adminStaffId;
  final String? emergencyContactName;
  final String? emergencyContactRelationship;
  final String? emergencyContactPhone;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffEmergencyContact({
    this.id,
    this.adminStaffId,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactPhone,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffEmergencyContact.fromJson(Map<String, dynamic> json) =>
      StaffEmergencyContact(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        emergencyContactName: json["emergencyContactName"],
        emergencyContactRelationship: json["emergencyContactRelationship"],
        emergencyContactPhone: json["emergencyContactPhone"],
        notes: json["notes"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "emergencyContactName": emergencyContactName,
    "emergencyContactRelationship": emergencyContactRelationship,
    "emergencyContactPhone": emergencyContactPhone,
    "notes": notes,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A qualification. [expiryDate] is null when it does not expire.
class StaffQualification {
  final String? id;
  final String? adminStaffId;
  final String? title;
  final String? awardingBody;
  final DateTime? dateAchieved;
  final DateTime? expiryDate;
  final String? documentUrl;
  final String? notes;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffQualification({
    this.id,
    this.adminStaffId,
    this.title,
    this.awardingBody,
    this.dateAchieved,
    this.expiryDate,
    this.documentUrl,
    this.notes,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffQualification.fromJson(Map<String, dynamic> json) =>
      StaffQualification(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        title: json["title"],
        awardingBody: json["awardingBody"],
        dateAchieved: _date(json["dateAchieved"]),
        expiryDate: _date(json["expiryDate"]),
        documentUrl: json["documentUrl"],
        notes: json["notes"],
        category: json["category"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "title": title,
    "awardingBody": awardingBody,
    "dateAchieved": dateAchieved?.toIso8601String(),
    "expiryDate": expiryDate?.toIso8601String(),
    "documentUrl": documentUrl,
    "notes": notes,
    "category": category,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A training certificate.
class StaffCertificate {
  final String? id;
  final String? adminStaffId;
  final String? name;
  final String? issuingBody;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? certificateUrl;
  final String? notes;
  final String? type;
  final String? referenceNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffCertificate({
    this.id,
    this.adminStaffId,
    this.name,
    this.issuingBody,
    this.issueDate,
    this.expiryDate,
    this.certificateUrl,
    this.notes,
    this.type,
    this.referenceNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffCertificate.fromJson(Map<String, dynamic> json) =>
      StaffCertificate(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        name: json["name"],
        issuingBody: json["issuingBody"],
        issueDate: _date(json["issueDate"]),
        expiryDate: _date(json["expiryDate"]),
        certificateUrl: json["certificateUrl"],
        notes: json["notes"],
        type: json["type"],
        referenceNumber: json["referenceNumber"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "name": name,
    "issuingBody": issuingBody,
    "issueDate": issueDate?.toIso8601String(),
    "expiryDate": expiryDate?.toIso8601String(),
    "certificateUrl": certificateUrl,
    "notes": notes,
    "type": type,
    "referenceNumber": referenceNumber,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A competency assessment.
class StaffCompetency {
  final String? id;
  final String? adminStaffId;
  final String? name;
  final DateTime? assessedDate;
  final String? notes;
  final String? category;
  final String? status;
  final String? assessor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffCompetency({
    this.id,
    this.adminStaffId,
    this.name,
    this.assessedDate,
    this.notes,
    this.category,
    this.status,
    this.assessor,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffCompetency.fromJson(Map<String, dynamic> json) =>
      StaffCompetency(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        name: json["name"],
        assessedDate: _date(json["assessedDate"]),
        notes: json["notes"],
        category: json["category"],
        status: json["status"],
        assessor: json["assessor"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "name": name,
    "assessedDate": assessedDate?.toIso8601String(),
    "notes": notes,
    "category": category,
    "status": status,
    "assessor": assessor,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A document on the staff record.
class StaffDocument {
  final String? id;
  final String? adminStaffId;
  final String? name;
  final String? url;
  final String? category;
  final DateTime? uploadedAt;
  final String? notes;
  final String? confidentiality;
  final DateTime? documentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffDocument({
    this.id,
    this.adminStaffId,
    this.name,
    this.url,
    this.category,
    this.uploadedAt,
    this.notes,
    this.confidentiality,
    this.documentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffDocument.fromJson(Map<String, dynamic> json) => StaffDocument(
    id: json["id"],
    adminStaffId: json["adminStaffId"],
    name: json["name"],
    url: json["url"],
    category: json["category"],
    uploadedAt: _date(json["uploadedAt"]),
    notes: json["notes"],
    confidentiality: json["confidentiality"],
    documentDate: _date(json["documentDate"]),
    createdAt: _date(json["createdAt"]),
    updatedAt: _date(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "name": name,
    "url": url,
    "category": category,
    "uploadedAt": uploadedAt?.toIso8601String(),
    "notes": notes,
    "confidentiality": confidentiality,
    "documentDate": documentDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// The appointment letter and contract terms.
class StaffAppointmentLetter {
  final String? id;
  final String? adminStaffId;
  final String? referenceNumber;
  final DateTime? issueDate;
  final int? probationPeriodMonths;
  final String? noticePeriod;
  final String? reportsTo;
  final String? workBase;
  final String? additionalTerms;
  final String? signatoryName;
  final String? signatoryTitle;
  final String? status;
  final String? contractType;
  final String? purposeOfRole;
  final String? keyDuties;
  final String? responsibleFor;
  final bool? workingTimeOptOut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffAppointmentLetter({
    this.id,
    this.adminStaffId,
    this.referenceNumber,
    this.issueDate,
    this.probationPeriodMonths,
    this.noticePeriod,
    this.reportsTo,
    this.workBase,
    this.additionalTerms,
    this.signatoryName,
    this.signatoryTitle,
    this.status,
    this.contractType,
    this.purposeOfRole,
    this.keyDuties,
    this.responsibleFor,
    this.workingTimeOptOut,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffAppointmentLetter.fromJson(Map<String, dynamic> json) =>
      StaffAppointmentLetter(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        referenceNumber: json["referenceNumber"],
        issueDate: _date(json["issueDate"]),
        probationPeriodMonths: _int(json["probationPeriodMonths"]),
        noticePeriod: json["noticePeriod"],
        reportsTo: json["reportsTo"],
        workBase: json["workBase"],
        additionalTerms: json["additionalTerms"],
        signatoryName: json["signatoryName"],
        signatoryTitle: json["signatoryTitle"],
        status: json["status"],
        contractType: json["contractType"],
        purposeOfRole: json["purposeOfRole"],
        keyDuties: json["keyDuties"],
        responsibleFor: json["responsibleFor"],
        workingTimeOptOut: json["workingTimeOptOut"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "referenceNumber": referenceNumber,
    "issueDate": issueDate?.toIso8601String(),
    "probationPeriodMonths": probationPeriodMonths,
    "noticePeriod": noticePeriod,
    "reportsTo": reportsTo,
    "workBase": workBase,
    "additionalTerms": additionalTerms,
    "signatoryName": signatoryName,
    "signatoryTitle": signatoryTitle,
    "status": status,
    "contractType": contractType,
    "purposeOfRole": purposeOfRole,
    "keyDuties": keyDuties,
    "responsibleFor": responsibleFor,
    "workingTimeOptOut": workingTimeOptOut,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A referee the carer has given. The referee's own submitted reference is not
/// included, staff never see it.
class StaffReference {
  final String? id;
  final String? adminStaffId;
  final String? referenceType;
  final String? refereeName;
  final String? organisationName;
  final String? jobTitle;
  final String? email;
  final String? phoneNumber;
  final String? relationshipToStaff;
  final DateTime? employmentStartDate;
  final DateTime? employmentEndDate;
  final String? status;
  final DateTime? requestedAt;
  final DateTime? receivedAt;
  final String? notes;
  final String? jobDescriptionUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffReference({
    this.id,
    this.adminStaffId,
    this.referenceType,
    this.refereeName,
    this.organisationName,
    this.jobTitle,
    this.email,
    this.phoneNumber,
    this.relationshipToStaff,
    this.employmentStartDate,
    this.employmentEndDate,
    this.status,
    this.requestedAt,
    this.receivedAt,
    this.notes,
    this.jobDescriptionUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffReference.fromJson(Map<String, dynamic> json) => StaffReference(
    id: json["id"],
    adminStaffId: json["adminStaffId"],
    referenceType: json["referenceType"],
    refereeName: json["refereeName"],
    organisationName: json["organisationName"],
    jobTitle: json["jobTitle"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    relationshipToStaff: json["relationshipToStaff"],
    employmentStartDate: _date(json["employmentStartDate"]),
    employmentEndDate: _date(json["employmentEndDate"]),
    status: json["status"],
    requestedAt: _date(json["requestedAt"]),
    receivedAt: _date(json["receivedAt"]),
    notes: json["notes"],
    jobDescriptionUrl: json["jobDescriptionUrl"],
    createdAt: _date(json["createdAt"]),
    updatedAt: _date(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "referenceType": referenceType,
    "refereeName": refereeName,
    "organisationName": organisationName,
    "jobTitle": jobTitle,
    "email": email,
    "phoneNumber": phoneNumber,
    "relationshipToStaff": relationshipToStaff,
    "employmentStartDate": employmentStartDate?.toIso8601String(),
    "employmentEndDate": employmentEndDate?.toIso8601String(),
    "status": status,
    "requestedAt": requestedAt?.toIso8601String(),
    "receivedAt": receivedAt?.toIso8601String(),
    "notes": notes,
    "jobDescriptionUrl": jobDescriptionUrl,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A supervision or appraisal write-up about the carer, read only for staff.
class StaffSupervision {
  final String? id;
  final String? adminStaffId;
  final String? supervisorName;
  final String? supervisionType;
  final DateTime? supervisionDate;
  final String? previousActionsResolved;
  final String? howAreYou;
  final String? whatHasGoneWell;
  final String? whatHasNotGoneWell;
  final String? mainAreasForImprovement;
  final String? trainingAndDevelopmentProgress;
  final String? actionsToBeTaken;
  final String? staffComments;
  final String? supervisorComments;
  final DateTime? nextSupervisionDueDate;
  final String? status;
  final String? outcome;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffSupervision({
    this.id,
    this.adminStaffId,
    this.supervisorName,
    this.supervisionType,
    this.supervisionDate,
    this.previousActionsResolved,
    this.howAreYou,
    this.whatHasGoneWell,
    this.whatHasNotGoneWell,
    this.mainAreasForImprovement,
    this.trainingAndDevelopmentProgress,
    this.actionsToBeTaken,
    this.staffComments,
    this.supervisorComments,
    this.nextSupervisionDueDate,
    this.status,
    this.outcome,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffSupervision.fromJson(Map<String, dynamic> json) =>
      StaffSupervision(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        supervisorName: json["supervisorName"],
        supervisionType: json["supervisionType"],
        supervisionDate: _date(json["supervisionDate"]),
        previousActionsResolved: json["previousActionsResolved"],
        howAreYou: json["howAreYou"],
        whatHasGoneWell: json["whatHasGoneWell"],
        whatHasNotGoneWell: json["whatHasNotGoneWell"],
        mainAreasForImprovement: json["mainAreasForImprovement"],
        trainingAndDevelopmentProgress: json["trainingAndDevelopmentProgress"],
        actionsToBeTaken: json["actionsToBeTaken"],
        staffComments: json["staffComments"],
        supervisorComments: json["supervisorComments"],
        nextSupervisionDueDate: _date(json["nextSupervisionDueDate"]),
        status: json["status"],
        outcome: json["outcome"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "supervisorName": supervisorName,
    "supervisionType": supervisionType,
    "supervisionDate": supervisionDate?.toIso8601String(),
    "previousActionsResolved": previousActionsResolved,
    "howAreYou": howAreYou,
    "whatHasGoneWell": whatHasGoneWell,
    "whatHasNotGoneWell": whatHasNotGoneWell,
    "mainAreasForImprovement": mainAreasForImprovement,
    "trainingAndDevelopmentProgress": trainingAndDevelopmentProgress,
    "actionsToBeTaken": actionsToBeTaken,
    "staffComments": staffComments,
    "supervisorComments": supervisorComments,
    "nextSupervisionDueDate": nextSupervisionDueDate?.toIso8601String(),
    "status": status,
    "outcome": outcome,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A probation sign-off, read only for staff.
class StaffProbation {
  final String? id;
  final String? adminStaffId;
  final String? status;
  final DateTime? startDate;
  final DateTime? signOffDate;
  final String? duration;
  final String? signedOffBy;
  final String? finalReviewNotes;
  final List<String> milestones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffProbation({
    this.id,
    this.adminStaffId,
    this.status,
    this.startDate,
    this.signOffDate,
    this.duration,
    this.signedOffBy,
    this.finalReviewNotes,
    this.milestones = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory StaffProbation.fromJson(Map<String, dynamic> json) => StaffProbation(
    id: json["id"],
    adminStaffId: json["adminStaffId"],
    status: json["status"],
    startDate: _date(json["startDate"]),
    signOffDate: _date(json["signOffDate"]),
    duration: json["duration"],
    signedOffBy: json["signedOffBy"],
    finalReviewNotes: json["finalReviewNotes"],
    milestones: _strings(json["milestones"]),
    createdAt: _date(json["createdAt"]),
    updatedAt: _date(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "status": status,
    "startDate": startDate?.toIso8601String(),
    "signOffDate": signOffDate?.toIso8601String(),
    "duration": duration,
    "signedOffBy": signedOffBy,
    "finalReviewNotes": finalReviewNotes,
    "milestones": milestones,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// A declaration the carer has confirmed, read only for staff.
class StaffDeclaration {
  final String? id;
  final String? adminStaffId;
  final String? declarationType;
  final String? declarationText;
  final String? response;
  final bool? declaredValue;
  final DateTime? dateDeclared;
  final DateTime? reviewDate;
  final String? status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffDeclaration({
    this.id,
    this.adminStaffId,
    this.declarationType,
    this.declarationText,
    this.response,
    this.declaredValue,
    this.dateDeclared,
    this.reviewDate,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffDeclaration.fromJson(Map<String, dynamic> json) =>
      StaffDeclaration(
        id: json["id"],
        adminStaffId: json["adminStaffId"],
        declarationType: json["declarationType"],
        declarationText: json["declarationText"],
        response: json["response"],
        declaredValue: json["declaredValue"],
        dateDeclared: _date(json["dateDeclared"]),
        reviewDate: _date(json["reviewDate"]),
        status: json["status"],
        notes: json["notes"],
        createdAt: _date(json["createdAt"]),
        updatedAt: _date(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "adminStaffId": adminStaffId,
    "declarationType": declarationType,
    "declarationText": declarationText,
    "response": response,
    "declaredValue": declaredValue,
    "dateDeclared": dateDeclared?.toIso8601String(),
    "reviewDate": reviewDate?.toIso8601String(),
    "status": status,
    "notes": notes,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

/// The person-centred profile — the differentiator described in the source.
class SuProfile {
  final String preferredName;
  final String aboutMe;
  final String important;
  final List<String> likes;
  final List<String> dislikes;
  final String communication;
  final String family;
  final String spiritual;
  final String food;
  final String lastReviewedBy;
  final String lastReviewedNote;

  const SuProfile({
    required this.preferredName,
    required this.aboutMe,
    required this.important,
    required this.likes,
    required this.dislikes,
    required this.communication,
    required this.family,
    required this.spiritual,
    required this.food,
    required this.lastReviewedBy,
    required this.lastReviewedNote,
  });
}
