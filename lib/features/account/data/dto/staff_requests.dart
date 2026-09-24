/// Request bodies for the staff self-service API (staff-carer-own-profile-access).
library;

import 'package:intl/intl.dart';

/// Values the API accepts for the enum-backed fields. Anything else is rejected.
const staffEmploymentTypes = [
  'FullTime',
  'PartTime',
  'Bank',
  'Agency',
  'Contract',
  'Volunteer',
];
const staffGenders = ['Male', 'Female', 'Other', 'PreferNotToSay'];

/// Values the API accepts for the two compliance status fields.
const staffDbsStatuses = [
  'NotProvided',
  'Clear',
  'Pending',
  'Enhanced',
  'Barred',
  'Refused',
  'Expired',
];
const staffRightToWorkStatuses = [
  'NotProvided',
  'NotVerified',
  'Verified',
  'Pending',
  'Expired',
];

/// The document types the office's own form offers. The API takes any text.
const staffRightToWorkDocumentTypes = [
  'Passport',
  'Biometric Residence Permit',
  'Share Code',
  'Visa',
  'Other',
];
const staffReferenceTypes = [
  'Employment',
  'Professional',
  'Character',
  'Academic',
  'Other',
];

String? _iso(DateTime? d) => d?.toUtc().toIso8601String();

/// Empty text is sent as null: a field that does not apply is null on the API.
String? _orNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
String? _day(DateTime? d) =>
    d == null ? null : DateFormat('yyyy-MM-dd').format(d);

/// Body for PUT /api/admin-users/update. It always edits the caller's own
/// record and every field is optional: fields left null are not sent, so the
/// server keeps their current value.
class UpdateStaffRequest {
  final String? firstName;
  final String? surName;
  final String? staffCode;
  final String? phoneNo;
  final String? state;
  final String? locality;
  final String? address;
  final String? branch;
  final String? imagePath;
  final String? sex;
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

  const UpdateStaffRequest({
    this.firstName,
    this.surName,
    this.staffCode,
    this.phoneNo,
    this.state,
    this.locality,
    this.address,
    this.branch,
    this.imagePath,
    this.sex,
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
  });

  Map<String, dynamic> toJson() => {
    "firstName": ?firstName,
    "surName": ?surName,
    "staffCode": ?staffCode,
    "phoneNo": ?phoneNo,
    "state": ?state,
    "locality": ?locality,
    "address": ?address,
    "branch": ?branch,
    "imagePath": ?imagePath,
    "sex": ?sex,
    "bankAccName": ?bankAccName,
    "bankAccNo": ?bankAccNo,
    // The API also accepts a "bankCode" but silently throws it away. Only
    // bankSortCode is saved.
    "bankSortCode": ?bankSortCode,
    "insuranceNo": ?insuranceNo,
    "dbsCode": ?dbsCode,
    "dateOfBirth": ?_day(dateOfBirth),
    "nextOfKin": ?nextOfKin,
    "nextOfKinPhoneNo": ?nextOfKinPhoneNo,
    "referenceEmail": ?referenceEmail,
    "referenceEmail2": ?referenceEmail2,
    "nationality": ?nationality,
  };
}

/// The record areas under /api/admin-staff-records that staff can write to.
enum StaffRecordKind {
  profile('profile', 'Job details'),
  emergencyContact('emergency-contact', 'Emergency contact'),
  documents('documents', 'Document'),
  qualifications('qualifications', 'Qualification'),
  certificates('certificates', 'Certificate'),
  competencies('competencies', 'Competency'),
  references('references', 'Reference'),
  compliance('compliance', 'Right to work record');

  /// Path segment after /api/admin-staff-records/.
  final String segment;
  final String label;

  const StaffRecordKind(this.segment, this.label);

  /// Profile and emergency contact are one per person: the same POST adds or
  /// edits them. The others are lists with add, edit and delete.
  bool get isSingleton =>
      this == StaffRecordKind.profile ||
      this == StaffRecordKind.emergencyContact ||
      this == StaffRecordKind.compliance;
}

/// Body of an add (POST) or edit (PUT) on one of the record areas. The service
/// adds the caller's `adminStaffId` to a POST.
abstract class StaffRecordRequest {
  const StaffRecordRequest();

  StaffRecordKind get kind;

  Map<String, dynamic> toJson();
}

class ProfileRecordRequest extends StaffRecordRequest {
  final String jobTitle;
  final String employmentType;
  final DateTime? dateOfBirth;
  final String gender;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String county;
  final String postCode;
  final String country;
  final String shiftPattern;
  final String availabilityNotes;
  final String wingArea;
  final String keyWorkerFor;

  const ProfileRecordRequest({
    required this.jobTitle,
    required this.employmentType,
    required this.dateOfBirth,
    required this.gender,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.county,
    required this.postCode,
    required this.country,
    required this.shiftPattern,
    required this.availabilityNotes,
    required this.wingArea,
    required this.keyWorkerFor,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.profile;

  @override
  Map<String, dynamic> toJson() => {
    "jobTitle": jobTitle,
    "employmentType": employmentType,
    "dateOfBirth": _day(dateOfBirth),
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
  };
}

class EmergencyContactRequest extends StaffRecordRequest {
  final String name;
  final String relationship;
  final String phone;
  final String notes;

  const EmergencyContactRequest({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.notes,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.emergencyContact;

  @override
  Map<String, dynamic> toJson() => {
    "emergencyContactName": name,
    "emergencyContactRelationship": relationship,
    "emergencyContactPhone": phone,
    "notes": notes,
  };
}

class DocumentRequest extends StaffRecordRequest {
  final String name;

  /// The `imageUrl` that the upload service returned for the file.
  final String url;
  final String category;
  final DateTime uploadedAt;
  final String notes;
  final String confidentiality;
  final DateTime? documentDate;

  const DocumentRequest({
    required this.name,
    required this.url,
    required this.category,
    required this.uploadedAt,
    required this.notes,
    required this.confidentiality,
    required this.documentDate,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.documents;

  @override
  Map<String, dynamic> toJson() => {
    "name": name,
    "url": url,
    "category": category,
    "uploadedAt": _iso(uploadedAt),
    "notes": notes,
    "confidentiality": confidentiality,
    "documentDate": _iso(documentDate),
  };
}

class QualificationRequest extends StaffRecordRequest {
  final String title;
  final String awardingBody;
  final DateTime? dateAchieved;

  /// Null when the qualification does not expire.
  final DateTime? expiryDate;
  final String documentUrl;
  final String notes;
  final String category;

  const QualificationRequest({
    required this.title,
    required this.awardingBody,
    required this.dateAchieved,
    required this.expiryDate,
    required this.documentUrl,
    required this.notes,
    required this.category,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.qualifications;

  @override
  Map<String, dynamic> toJson() => {
    "title": title,
    "awardingBody": awardingBody,
    "dateAchieved": _iso(dateAchieved),
    "expiryDate": _iso(expiryDate),
    "documentUrl": documentUrl,
    "notes": notes,
    "category": category,
  };
}

class CertificateRequest extends StaffRecordRequest {
  final String name;
  final String issuingBody;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String certificateUrl;
  final String notes;
  final String type;
  final String referenceNumber;

  const CertificateRequest({
    required this.name,
    required this.issuingBody,
    required this.issueDate,
    required this.expiryDate,
    required this.certificateUrl,
    required this.notes,
    required this.type,
    required this.referenceNumber,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.certificates;

  @override
  Map<String, dynamic> toJson() => {
    "name": name,
    "issuingBody": issuingBody,
    "issueDate": _iso(issueDate),
    "expiryDate": _iso(expiryDate),
    "certificateUrl": certificateUrl,
    "notes": notes,
    "type": type,
    "referenceNumber": referenceNumber,
  };
}

class CompetencyRequest extends StaffRecordRequest {
  final String name;
  final DateTime? assessedDate;
  final String notes;
  final String category;

  /// Free text on the API, for example "Competent" or "In Progress".
  final String status;
  final String assessor;

  const CompetencyRequest({
    required this.name,
    required this.assessedDate,
    required this.notes,
    required this.category,
    required this.status,
    required this.assessor,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.competencies;

  @override
  Map<String, dynamic> toJson() => {
    "name": name,
    "assessedDate": _iso(assessedDate),
    "notes": notes,
    "category": category,
    "status": status,
    "assessor": assessor,
  };
}

/// A referee. Adding one does not email them: that is the separate
/// send-request action.
class ReferenceRequest extends StaffRecordRequest {
  final String referenceType;
  final String refereeName;
  final String organisationName;
  final String jobTitle;
  final String email;
  final String phoneNumber;
  final String relationshipToStaff;
  final DateTime? employmentStartDate;
  final DateTime? employmentEndDate;

  /// NotRequested, Requested, Received or Declined. Set by the office and by
  /// send-request, so an edit passes back what the record already has.
  final String status;
  final String notes;

  /// The `imageUrl` that the upload service returned for the job description.
  final String jobDescriptionUrl;

  const ReferenceRequest({
    required this.referenceType,
    required this.refereeName,
    required this.organisationName,
    required this.jobTitle,
    required this.email,
    required this.phoneNumber,
    required this.relationshipToStaff,
    required this.employmentStartDate,
    required this.employmentEndDate,
    required this.status,
    required this.notes,
    required this.jobDescriptionUrl,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.references;

  @override
  Map<String, dynamic> toJson() => {
    "referenceType": referenceType,
    "refereeName": refereeName,
    "organisationName": organisationName,
    "jobTitle": jobTitle,
    "email": email,
    "phoneNumber": phoneNumber,
    "relationshipToStaff": relationshipToStaff,
    "employmentStartDate": _iso(employmentStartDate),
    "employmentEndDate": _iso(employmentEndDate),
    "status": status,
    "notes": notes,
    "jobDescriptionUrl": jobDescriptionUrl,
  };
}

/// The carer's own Right to Work / Compliance record. A carer can add this
/// once, when there is none on file. After that only the office can change it.
/// The API replaces the whole record, so every field is sent.
class ComplianceRequest extends StaffRecordRequest {
  final String? niNumber;
  final String? checkedBy;
  final String dbsStatus;
  final String? dbsCertificateUrl;
  final DateTime? dbsCheckDate;
  final DateTime? dbsExpiryDate;
  final String? dbsType;
  final String? dbsDisclosureNumber;
  final String? dbsUpdateServiceStatus;
  final String rightToWorkStatus;
  final String? rightToWorkDocumentUrl;
  final DateTime? rightToWorkExpiryDate;
  final DateTime? rightToWorkCheckDate;
  final String? rightToWorkShareCode;
  final String? rightToWorkDocumentType;
  final String? rightToWorkDocumentReference;
  final String? ukVisaType;
  final String? visaNumber;
  final DateTime? visaExpiryDate;
  final String? passportNumber;
  final DateTime? passportExpiryDate;
  final String? registrationBody;
  final String? registrationNumber;
  final DateTime? registrationDate;
  final DateTime? registrationExpiryDate;

  const ComplianceRequest({
    this.niNumber,
    this.checkedBy,
    this.dbsStatus = 'NotProvided',
    this.dbsCertificateUrl,
    this.dbsCheckDate,
    this.dbsExpiryDate,
    this.dbsType,
    this.dbsDisclosureNumber,
    this.dbsUpdateServiceStatus,
    this.rightToWorkStatus = 'NotProvided',
    this.rightToWorkDocumentUrl,
    this.rightToWorkExpiryDate,
    this.rightToWorkCheckDate,
    this.rightToWorkShareCode,
    this.rightToWorkDocumentType,
    this.rightToWorkDocumentReference,
    this.ukVisaType,
    this.visaNumber,
    this.visaExpiryDate,
    this.passportNumber,
    this.passportExpiryDate,
    this.registrationBody,
    this.registrationNumber,
    this.registrationDate,
    this.registrationExpiryDate,
  });

  @override
  StaffRecordKind get kind => StaffRecordKind.compliance;

  @override
  Map<String, dynamic> toJson() => {
    "niNumber": _orNull(niNumber),
    "checkedBy": _orNull(checkedBy),
    "dbsStatus": dbsStatus,
    "dbsCertificateUrl": _orNull(dbsCertificateUrl),
    "dbsCheckDate": _iso(dbsCheckDate),
    "dbsExpiryDate": _iso(dbsExpiryDate),
    "dbsType": _orNull(dbsType),
    "dbsDisclosureNumber": _orNull(dbsDisclosureNumber),
    "dbsUpdateServiceStatus": _orNull(dbsUpdateServiceStatus),
    "rightToWorkStatus": rightToWorkStatus,
    "rightToWorkDocumentUrl": _orNull(rightToWorkDocumentUrl),
    "rightToWorkExpiryDate": _iso(rightToWorkExpiryDate),
    "rightToWorkCheckDate": _iso(rightToWorkCheckDate),
    "rightToWorkShareCode": _orNull(rightToWorkShareCode),
    "rightToWorkDocumentType": _orNull(rightToWorkDocumentType),
    "rightToWorkDocumentReference": _orNull(rightToWorkDocumentReference),
    "ukVisaType": _orNull(ukVisaType),
    "visaNumber": _orNull(visaNumber),
    "visaExpiryDate": _iso(visaExpiryDate),
    "passportNumber": _orNull(passportNumber),
    "passportExpiryDate": _iso(passportExpiryDate),
    "registrationBody": _orNull(registrationBody),
    "registrationNumber": _orNull(registrationNumber),
    "registrationDate": _iso(registrationDate),
    "registrationExpiryDate": _iso(registrationExpiryDate),
  };
}
