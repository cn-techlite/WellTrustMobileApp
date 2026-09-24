import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';

const _json = r'''
{
  "id": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
  "adminType": "AdminStaff",
  "email": "jane.doe@welltrusthealthstaff.co.uk",
  "surName": "Doe",
  "firstName": "Jane",
  "staffCode": "WT-0042",
  "phoneNo": "07123456789",
  "imagePath": "/uploads/staff-photos/7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55.jpg",
  "sex": "Female",
  "state": "Northamptonshire",
  "locality": "Kettering",
  "address": "14 Rockingham Road, Kettering, NN16 8JJ",
  "branch": "Kettering Branch",
  "bankAccName": "Jane Doe",
  "bankAccNo": "12345678",
  "bankSortCode": "20-30-40",
  "insuranceNo": "QQ123456C",
  "dbsCode": "001234567890",
  "dateOfBirth": "1990-04-12",
  "nextOfKin": "John Doe (Husband)",
  "nextOfKinPhoneNo": "07987654321",
  "referenceEmail": "referee1@example.com",
  "referenceEmail2": "referee2@example.com",
  "nationality": "British",
  "createdAt": "2025-11-03T09:15:00Z",
  "staffStatus": "Active",
  "roles": ["AdminStaff", "StaffCarer"],
  "permissions": ["CanViewOwnProfile", "CanViewOwnStaffRecords", "CanUpdateOwnStaffRecords"],
  "archivedAccount": false,
  "suspendedAccount": false,
  "status": "Active",
  "complianceStatus": "Compliant",
  "profile": {
    "id": "b2f1e6a0-1234-4a2e-9c31-8e2b6f0a1d56",
    "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
    "jobTitle": "Senior Care Assistant",
    "employmentType": "PartTime",
    "dateOfBirth": "1990-04-12",
    "gender": "Female",
    "addressLine1": "14 Rockingham Road",
    "addressLine2": "Flat 2",
    "city": "Kettering",
    "county": "Northamptonshire",
    "postCode": "NN16 8JJ",
    "country": "United Kingdom",
    "shiftPattern": "Mon/Wed/Fri, 08:00–16:00",
    "availabilityNotes": "Not available Sunday mornings",
    "wingArea": "Willow Wing",
    "keyWorkerFor": "Room 4 residents",
    "createdAt": "2025-11-03T09:20:00Z",
    "updatedAt": "2026-06-14T11:05:00Z"
  },
  "compliance": {
    "id": "c3e2d7b1-2345-4a2e-9c31-8e2b6f0a1d57",
    "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
    "niNumber": "QQ123456C",
    "dbsStatus": "Clear",
    "dbsCertificateUrl": "https://.../documents/dbs-certificate.pdf",
    "dbsCheckDate": "2025-10-01T00:00:00Z",
    "dbsExpiryDate": "2028-10-01T00:00:00Z",
    "dbsType": "Enhanced",
    "dbsDisclosureNumber": "001234567890",
    "dbsUpdateServiceStatus": "Subscribed",
    "rightToWorkStatus": "Verified",
    "rightToWorkDocumentUrl": "https://.../documents/right-to-work.pdf",
    "rightToWorkExpiryDate": "N/A - settled right to work, does not expire",
    "rightToWorkCheckDate": "2025-10-15T00:00:00Z",
    "rightToWorkShareCode": "N/A - verified via UK passport, not a share code",
    "ukVisaType": "N/A - British citizen, no visa required",
    "visaNumber": "N/A - British citizen, no visa required",
    "visaExpiryDate": "N/A - British citizen, no visa required",
    "passportNumber": "123456789",
    "passportExpiryDate": "2030-05-20T00:00:00Z",
    "registrationNumber": "N/A - role does not require professional body registration",
    "registrationBody": "N/A - role does not require professional body registration",
    "registrationDate": "N/A - role does not require professional body registration",
    "registrationExpiryDate": "N/A - role does not require professional body registration",
    "checkedBy": "HR Team",
    "rightToWorkDocumentType": "UK Passport",
    "rightToWorkDocumentReference": "123456789",
    "createdAt": "2025-11-03T09:25:00Z",
    "updatedAt": "2025-11-03T09:25:00Z"
  },
  "employmentPay": {
    "id": "d4f3e8c2-3456-4a2e-9c31-8e2b6f0a1d58",
    "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
    "employmentStartDate": "2025-11-10T00:00:00Z",
    "employmentEndDate": "N/A - permanent, ongoing contract with no end date",
    "hourlyRate": 12.75,
    "annualSalary": 15912.00,
    "currency": "GBP",
    "hoursPerWeek": 24,
    "createdAt": "2025-11-03T09:30:00Z",
    "updatedAt": "2025-11-03T09:30:00Z"
  },
  "emergencyContact": {
    "id": "e5a4f9d3-4567-4a2e-9c31-8e2b6f0a1d59",
    "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
    "emergencyContactName": "John Doe",
    "emergencyContactRelationship": "Husband",
    "emergencyContactPhone": "07987654321",
    "notes": "Prefers to be called, not texted",
    "createdAt": "2025-11-03T09:35:00Z",
    "updatedAt": "2025-11-03T09:35:00Z"
  },
  "qualifications": [
    {
      "id": "f6b5a0e4-5678-4a2e-9c31-8e2b6f0a1d60",
      "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
      "title": "NVQ Level 3 Health and Social Care",
      "awardingBody": "City & Guilds",
      "dateAchieved": "2022-06-15T00:00:00Z",
      "expiryDate": "N/A - qualification does not expire",
      "documentUrl": "https://.../documents/nvq-level-3.pdf",
      "notes": "Distinction",
      "category": "Care Qualification",
      "createdAt": "2025-11-03T09:40:00Z",
      "updatedAt": "2025-11-03T09:40:00Z"
    }
  ],
  "certificates": [
    {
      "id": "07c6b1f5-6789-4a2e-9c31-8e2b6f0a1d61",
      "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
      "name": "Moving and Handling",
      "issuingBody": "WellTrust Training Team",
      "issueDate": "2026-01-10T00:00:00Z",
      "expiryDate": "2027-01-10T00:00:00Z",
      "certificateUrl": "https://.../documents/moving-and-handling.pdf",
      "notes": "Annual refresher required; next due 10 Jan 2027",
      "type": "Mandatory Training",
      "referenceNumber": "MH-2026-0042",
      "createdAt": "2026-01-10T10:00:00Z",
      "updatedAt": "2026-01-10T10:00:00Z"
    }
  ],
  "competencies": [
    {
      "id": "18d7c2a6-7890-4a2e-9c31-8e2b6f0a1d62",
      "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
      "name": "Medication Administration",
      "assessedDate": "2026-02-01T00:00:00Z",
      "notes": "Observed administering morning medication round unsupervised",
      "category": "Clinical",
      "status": "Competent",
      "assessor": "Ujunwa Ezeama (RI)",
      "createdAt": "2026-02-01T14:00:00Z",
      "updatedAt": "2026-02-01T14:00:00Z"
    }
  ],
  "documents": [
    {
      "id": "29e8d3b7-8901-4a2e-9c31-8e2b6f0a1d63",
      "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
      "name": "Proof of Address",
      "url": "https://.../documents/proof-of-address.pdf",
      "category": "Identity",
      "uploadedAt": "2026-03-05T13:20:00Z",
      "notes": "Utility bill dated within the last 3 months",
      "confidentiality": "Standard",
      "documentDate": "2026-02-20T00:00:00Z",
      "createdAt": "2026-03-05T13:20:00Z",
      "updatedAt": "2026-03-05T13:20:00Z"
    }
  ],
  "appointmentLetter": {
    "id": "3af9e4c8-9012-4a2e-9c31-8e2b6f0a1d64",
    "adminStaffId": "7c1e2b3a-4f6d-4a2e-9c31-8e2b6f0a1d55",
    "referenceNumber": "WT-AL-2025-0042",
    "issueDate": "2025-11-05T00:00:00Z",
    "probationPeriodMonths": 6,
    "noticePeriod": "1 week during probation, 4 weeks after",
    "reportsTo": "Registered Manager",
    "workBase": "Kettering Branch and client homes within the surrounding area",
    "additionalTerms": "None beyond the standard terms and conditions set out in the Contract of Employment",
    "signatoryName": "Emmanuel Odoh",
    "signatoryTitle": "Registered Manager",
    "status": "Issued",
    "contractType": "Permanent",
    "purposeOfRole": "To provide high-quality, person-centred domiciliary care",
    "keyDuties": "Personal care, medication support, companionship, light domestic duties",
    "responsibleFor": "N/A",
    "workingTimeOptOut": false,
    "createdAt": "2025-11-05T09:00:00Z",
    "updatedAt": "2025-11-05T09:00:00Z"
  }
}
''';

void main() {
  test('parses references, supervisions, probation and declarations', () {
    final ref = StaffReference.fromJson(
      jsonDecode(
            '{"id":"r1","referenceType":"Employment","refereeName":"Sarah Whitfield",'
            '"status":"NotRequested","requestedAt":null,"employmentStartDate":"2022-03-01T00:00:00Z",'
            '"jobDescriptionUrl":"https://host/x.pdf","response":{"anything":1}}',
          )
          as Map<String, dynamic>,
    );
    expect(ref.refereeName, 'Sarah Whitfield');
    expect(ref.requestedAt, isNull);
    expect(ref.employmentStartDate, DateTime.parse('2022-03-01T00:00:00Z'));

    final sup = StaffSupervision.fromJson({
      'supervisionType': 'ProbationReview',
      'supervisionDate': '2026-03-10T10:00:00Z',
      'status': 'Completed',
      'outcome': null,
    });
    expect(sup.supervisionType, 'ProbationReview');
    expect(sup.outcome, isNull);

    final prob = StaffProbation.fromJson({
      'status': 'Passed',
      'milestones': ['Induction complete', 'Final review passed'],
    });
    expect(prob.milestones, hasLength(2));

    final decl = StaffDeclaration.fromJson({
      'declarationType': 'Health',
      'declaredValue': true,
      'reviewDate': '2027-01-15T00:00:00Z',
    });
    expect(decl.declaredValue, isTrue);
    expect(decl.reviewDate, DateTime.parse('2027-01-15T00:00:00Z'));
  });

  test('parses the staff profile response', () {
    final m = registerResponseModelFromJson(_json);

    expect(m.firstName, 'Jane');
    expect(m.surName, 'Doe');
    expect(m.staffCode, 'WT-0042');
    expect(m.imagePath, startsWith('/uploads/staff-photos/'));
    expect(m.dateOfBirth, DateTime.parse('1990-04-12'));
    expect(m.createdAt, DateTime.parse('2025-11-03T09:15:00Z'));
    expect(m.roles, ['AdminStaff', 'StaffCarer']);
    expect(m.permissions, hasLength(3));
    expect(m.archivedAccount, false);
    expect(m.complianceStatus, 'Compliant');

    expect(m.profile?.jobTitle, 'Senior Care Assistant');
    expect(m.profile?.updatedAt, DateTime.parse('2026-06-14T11:05:00Z'));

    // "N/A - ..." text in a date field means not applicable, same as null.
    final c = m.compliance!;
    expect(c.rightToWorkExpiryDate, isNull);
    expect(c.visaExpiryDate, isNull);
    expect(c.registrationDate, isNull);
    expect(c.ukVisaType, startsWith('N/A'));
    expect(c.dbsExpiryDate, DateTime.parse('2028-10-01T00:00:00Z'));
    expect(c.passportExpiryDate, DateTime.parse('2030-05-20T00:00:00Z'));

    final pay = m.employmentPay!;
    expect(pay.hourlyRate, 12.75);
    expect(pay.annualSalary, 15912);
    expect(pay.hoursPerWeek, 24);
    expect(pay.employmentEndDate, isNull);

    expect(m.emergencyContact?.emergencyContactName, 'John Doe');
    expect(m.qualifications.single.expiryDate, isNull);
    expect(
      m.certificates.single.expiryDate,
      DateTime.parse('2027-01-10T00:00:00Z'),
    );
    expect(m.competencies.single.status, 'Competent');
    expect(m.documents.single.name, 'Proof of Address');
    expect(m.appointmentLetter?.probationPeriodMonths, 6);
    expect(m.appointmentLetter?.workingTimeOptOut, false);
    expect(m.appointmentLetter?.status, 'Issued');
  });

  test(
    'reads real dates and nulls in the fields that can be not applicable',
    () {
      final m = registerResponseModelFromJson('''
      {"compliance": {"rightToWorkExpiryDate": "2030-01-01T00:00:00Z", "visaExpiryDate": null},
       "employmentPay": {"employmentEndDate": "2027-03-31T00:00:00Z"}}
    ''');
      expect(
        m.compliance?.rightToWorkExpiryDate,
        DateTime.parse('2030-01-01T00:00:00Z'),
      );
      expect(m.compliance?.visaExpiryDate, isNull);
      expect(
        m.employmentPay?.employmentEndDate,
        DateTime.parse('2027-03-31T00:00:00Z'),
      );
    },
  );

  test('survives a round trip and a nearly empty response', () {
    final m = registerResponseModelFromJson(_json);
    final again = registerResponseModelFromJson(registerResponseModelToJson(m));
    expect(jsonEncode(again.toJson()), jsonEncode(m.toJson()));

    final empty = registerResponseModelFromJson('{"id":"x"}');
    expect(empty.id, 'x');
    expect(empty.roles, isEmpty);
    expect(empty.qualifications, isEmpty);
    expect(empty.profile, isNull);
  });
}
