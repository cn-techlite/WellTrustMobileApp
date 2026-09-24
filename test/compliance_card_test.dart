import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/compliance_card.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';

/// The compliance record from the API docs (all 25 fields).
const _sample = <String, dynamic>{
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
  "registrationNumber":
      "N/A - role does not require professional body registration",
  "registrationBody":
      "N/A - role does not require professional body registration",
  "registrationDate":
      "N/A - role does not require professional body registration",
  "registrationExpiryDate":
      "N/A - role does not require professional body registration",
  "checkedBy": "HR Team",
  "rightToWorkDocumentType": "UK Passport",
  "rightToWorkDocumentReference": "123456789",
  "createdAt": "2025-11-03T09:25:00Z",
  "updatedAt": "2025-11-03T09:25:00Z",
};

Future<void> _show(WidgetTester tester, StaffCompliance? c) async {
  tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: ComplianceCard(compliance: c)),
      ),
    ),
  );
}

void main() {
  testWidgets('shows every one of the 25 fields', (tester) async {
    await _show(tester, StaffCompliance.fromJson(_sample));

    for (final label in [
      'National Insurance number',
      'Checked by',
      'Type',
      'Disclosure number',
      'Update service',
      'Certificate',
      'Document type',
      'Document reference',
      'Share code',
      'Document',
      'Passport number',
      'Passport expires',
      'UK visa type',
      'Visa number',
      'Visa expires',
      'Professional body',
      'Registration number',
      'Registered on',
      'Registration expires',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Both DBS and right to work have a status, a check date and an expiry.
    expect(find.text('Status'), findsNWidgets(2));
    expect(find.text('Checked on'), findsNWidgets(2));
    expect(find.text('Expires on'), findsNWidgets(2));

    // Values from the record.
    for (final value in [
      'QQ123456C',
      'HR Team',
      'Enhanced',
      '001234567890',
      'Subscribed',
      '1 Oct 2025',
      '1 Oct 2028',
      'Clear',
      'Verified',
      'UK Passport',
      '123456789',
      '15 Oct 2025',
      '20 May 2030',
      'Recorded 3 Nov 2025',
    ]) {
      expect(find.text(value), findsWidgets, reason: value);
    }
    expect(find.text('Uploaded'), findsNWidgets(2));
    expect(find.text('View'), findsNWidgets(2));
  });

  testWidgets('"N/A - reason" and null both read as not applicable', (
    tester,
  ) async {
    await _show(tester, StaffCompliance.fromJson(_sample));

    // Share code, visa type, visa number, visa expiry, registration body,
    // registration number and expiry, and right to work expiry.
    expect(find.text('Not applicable'), findsNWidgets(9));
    expect(find.textContaining('N/A'), findsNothing);
  });

  testWidgets('flags an expired and a soon-to-expire date', (tester) async {
    final now = DateTime.now().toUtc();
    await _show(
      tester,
      StaffCompliance.fromJson({
        ..._sample,
        'dbsExpiryDate': now
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'passportExpiryDate': now
            .add(const Duration(days: 10))
            .toIso8601String(),
      }),
    );
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Expires soon'), findsOneWidget);
  });

  testWidgets('a record with nothing in it says so', (tester) async {
    await _show(tester, null);
    expect(find.text('Nothing recorded yet'), findsOneWidget);
  });

  testWidgets('a mostly empty record shows Not set, not blanks', (
    tester,
  ) async {
    await _show(tester, StaffCompliance.fromJson({'niNumber': 'QQ1'}));
    expect(find.text('QQ1'), findsOneWidget);
    expect(find.text('Not set'), findsWidgets);
    expect(find.text('Uploaded'), findsNothing);
    expect(find.text('Not uploaded'), findsNWidgets(2));
  });

  test('visa and registration expiry count towards what needs attention', () {
    final soon = DateTime.now()
        .toUtc()
        .add(const Duration(days: 5))
        .toIso8601String();
    final user = RegisterResponseModel(
      compliance: StaffCompliance.fromJson({
        'visaExpiryDate': soon,
        'registrationExpiryDate': soon,
      }),
    );
    expect(staffAttentionCount(user), 2);
  });
}
