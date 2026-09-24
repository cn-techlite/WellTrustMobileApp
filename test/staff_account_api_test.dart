import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/repository/account_repository_impl.dart';
import 'package:well_trust_mobile_app/features/account/data/services/account_remote_services.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

/// Runs [body] with every http call answered by [handler], and returns the
/// requests that were made.
Future<List<http.Request>> _record(
  http.Response Function(http.Request) handler,
  Future<void> Function() body,
) async {
  final seen = <http.Request>[];
  final client = MockClient((request) async {
    seen.add(request);
    return handler(request);
  });
  await http.runWithClient(body, () => client);
  return seen;
}

http.Response _ok(Object body) => http.Response(jsonEncode(body), 200);

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
    globals.token = 'test-token';
  });

  group('request bodies', () {
    test(
      'update sends only what was set, and only the bank sort code that saves',
      () {
        final json = const UpdateStaffRequest(
          firstName: 'Jane',
          bankSortCode: '20-30-40',
        ).toJson();
        expect(json, {'firstName': 'Jane', 'bankSortCode': '20-30-40'});
      },
    );

    test('update writes the date of birth as a plain date', () {
      final json = UpdateStaffRequest(
        dateOfBirth: DateTime(1990, 4, 12),
      ).toJson();
      expect(json['dateOfBirth'], '1990-04-12');
    });

    test('a qualification that does not expire sends a null expiry', () {
      final json = const QualificationRequest(
        title: 'NVQ',
        awardingBody: 'City & Guilds',
        dateAchieved: null,
        expiryDate: null,
        documentUrl: '',
        notes: '',
        category: 'Care Qualification',
      ).toJson();
      expect(json.containsKey('expiryDate'), isTrue);
      expect(json['expiryDate'], isNull);
      expect(json.containsKey('adminStaffId'), isFalse);
    });

    test('a document carries the URL the upload service returned', () {
      final json = DocumentRequest(
        name: 'Proof of Address',
        url: 'https://host/uploads/documents/abc.jpg',
        category: 'Identity',
        uploadedAt: DateTime.utc(2026, 3, 5, 13, 20),
        notes: '',
        confidentiality: 'Standard',
        documentDate: DateTime.utc(2026, 2, 20),
      ).toJson();
      expect(json['url'], 'https://host/uploads/documents/abc.jpg');
      expect(json['uploadedAt'], '2026-03-05T13:20:00.000Z');
      expect(json['documentDate'], '2026-02-20T00:00:00.000Z');
    });
  });

  group('service', () {
    test(
      'update profile is a PUT to admin-users/update with the token',
      () async {
        final seen = await _record((_) => _ok({}), () async {
          await AccountRemoteService().updateProfile(
            const UpdateStaffRequest(phoneNo: '07123456789'),
          );
        });
        final r = seen.single;
        expect(r.method, 'PUT');
        expect(r.url.path, endsWith('api/admin-users/update'));
        expect(r.headers['Authorization'], 'Bearer test-token');
        expect(jsonDecode(r.body), {'phoneNo': '07123456789'});
      },
    );

    test('adding a record POSTs it with the caller\'s adminStaffId', () async {
      final seen = await _record((_) => _ok({}), () async {
        await AccountRemoteService().saveStaffRecord(
          const CompetencyRequest(
            name: 'Medication Administration',
            assessedDate: null,
            notes: '',
            category: 'Clinical',
            status: 'Competent',
            assessor: 'Ujunwa Ezeama (RI)',
          ),
          adminStaffId: 'staff-1',
        );
      });
      final r = seen.single;
      expect(r.method, 'POST');
      expect(r.url.path, endsWith('api/admin-staff-records/competencies'));
      final body = jsonDecode(r.body) as Map;
      expect(body['adminStaffId'], 'staff-1');
      expect(body['status'], 'Competent');
    });

    test(
      'job details and emergency contact use their own POST route',
      () async {
        final seen = await _record((_) => _ok({}), () async {
          final s = AccountRemoteService();
          await s.saveStaffRecord(
            const EmergencyContactRequest(
              name: 'John Doe',
              relationship: 'Husband',
              phone: '07987654321',
              notes: '',
            ),
            adminStaffId: 'staff-1',
          );
        });
        expect(
          seen.single.url.path,
          endsWith('api/admin-staff-records/emergency-contact'),
        );
        expect(
          (jsonDecode(seen.single.body) as Map)['emergencyContactName'],
          'John Doe',
        );
      },
    );

    test('editing is a PUT to the record id with no adminStaffId', () async {
      final seen = await _record((_) => _ok({}), () async {
        await AccountRemoteService().updateStaffRecord(
          'cert-9',
          const CertificateRequest(
            name: 'Moving and Handling',
            issuingBody: 'WellTrust Training Team',
            issueDate: null,
            expiryDate: null,
            certificateUrl: '',
            notes: '',
            type: 'Mandatory Training',
            referenceNumber: 'MH-1',
          ),
        );
      });
      final r = seen.single;
      expect(r.method, 'PUT');
      expect(
        r.url.path,
        endsWith('api/admin-staff-records/certificates/cert-9'),
      );
      expect((jsonDecode(r.body) as Map).containsKey('adminStaffId'), isFalse);
    });

    test('deleting is a DELETE to the record id', () async {
      final seen = await _record((_) => _ok({}), () async {
        await AccountRemoteService().deleteStaffRecord(
          StaffRecordKind.documents,
          'doc-3',
        );
      });
      expect(seen.single.method, 'DELETE');
      expect(
        seen.single.url.path,
        endsWith('api/admin-staff-records/documents/doc-3'),
      );
    });
  });

  group('repository', () {
    final repo = AccountRepositoryImpl(AccountRemoteService());

    test('a saved record comes back as a success with its data', () async {
      late final GeneralResultModel result;
      await _record((_) => _ok({'id': 'q1', 'title': 'NVQ'}), () async {
        result = await repo.updateStaffRecord(
          'q1',
          const QualificationRequest(
            title: 'NVQ',
            awardingBody: '',
            dateAchieved: null,
            expiryDate: null,
            documentUrl: '',
            notes: '',
            category: '',
          ),
        );
      });
      expect(result.isSuccess, isTrue);
      expect(result.message, 'Qualification updated successfully');
      expect(result.data?['id'], 'q1');
    });

    test('an empty success body is still a success', () async {
      late final GeneralResultModel result;
      await _record((_) => http.Response('', 200), () async {
        result = await repo.deleteStaffRecord(StaffRecordKind.documents, 'd1');
      });
      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });

    test('someone else\'s record gives a clear message on 403', () async {
      late final GeneralResultModel result;
      await _record((_) => http.Response('', 403), () async {
        result = await repo.deleteStaffRecord(StaffRecordKind.documents, 'd1');
      });
      expect(result.isSuccess, isFalse);
      expect(result.message, 'You can only change your own record.');
    });

    test('a plain text 404 is shown as the error', () async {
      late final GeneralResultModel result;
      await _record(
        (_) => http.Response('Document record does not exist.', 404),
        () async {
          result = await repo.deleteStaffRecord(
            StaffRecordKind.documents,
            'd1',
          );
        },
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Document record does not exist.');
    });
  });

  group('references and the office records', () {
    const reference = ReferenceRequest(
      referenceType: 'Employment',
      refereeName: 'Sarah Whitfield',
      organisationName: 'Kettering General Hospital NHS Trust',
      jobTitle: 'Ward Manager',
      email: 's.whitfield@kgh-trust.nhs.uk',
      phoneNumber: '+44 1536 492000',
      relationshipToStaff: 'Direct line manager, 2022-2025',
      employmentStartDate: null,
      employmentEndDate: null,
      status: 'NotRequested',
      notes: '',
      jobDescriptionUrl: '',
    );

    test('a reference is added with POST and the carer\'s own id', () async {
      final seen = await _record((_) => _ok({}), () async {
        await AccountRemoteService().saveStaffRecord(
          reference,
          adminStaffId: 'staff-1',
        );
      });
      expect(seen.single.method, 'POST');
      expect(
        seen.single.url.path,
        endsWith('api/admin-staff-records/references'),
      );
      final body = jsonDecode(seen.single.body) as Map;
      expect(body['adminStaffId'], 'staff-1');
      expect(body['referenceType'], 'Employment');
      expect(body['status'], 'NotRequested');
    });

    test('an edit leaves the owner out and keeps the status', () {
      final json = reference.toJson();
      expect(json.containsKey('adminStaffId'), isFalse);
      expect(json['status'], 'NotRequested');
    });

    test('send-request is a POST to the reference with no body', () async {
      final seen = await _record((_) => _ok({}), () async {
        await AccountRemoteService().sendReferenceRequest('ref-7');
      });
      expect(seen.single.method, 'POST');
      expect(
        seen.single.url.path,
        endsWith('api/admin-staff-records/references/ref-7/send-request'),
      );
      expect(seen.single.body, isEmpty);
    });

    test('a list, a single object and a 404 all come back as a list', () async {
      final service = AccountRemoteService();
      late List<Map<String, dynamic>> many, one, none;
      await _record(
        (_) => _ok([
          {'id': 'a'},
          {'id': 'b'},
        ]),
        () async {
          many = await service.getStaffRecords('supervisions', 'staff-1');
        },
      );
      await _record((_) => _ok({'id': 'p'}), () async {
        one = await service.getStaffRecords('probation', 'staff-1');
      });
      await _record((_) => http.Response('', 404), () async {
        none = await service.getStaffRecords('declarations', 'staff-1');
      });
      expect(many.map((e) => e['id']), ['a', 'b']);
      expect(one.single['id'], 'p');
      expect(none, isEmpty);
    });

    test('the records are fetched by the carer\'s own id', () async {
      final seen = await _record((_) => _ok([]), () async {
        await AccountRemoteService().getStaffRecords('supervisions', 'staff-1');
      });
      expect(seen.single.method, 'GET');
      expect(
        seen.single.url.path,
        endsWith('api/admin-staff-records/supervisions/staff/staff-1'),
      );
    });

    test(
      'a server error is raised rather than shown as an empty list',
      () async {
        Object? error;
        await _record((_) => http.Response('', 500), () async {
          try {
            await AccountRemoteService().getStaffRecords('supervisions', 's');
          } catch (e) {
            error = e;
          }
        });
        expect(error, 'Server error. Please try again later.');
      },
    );

    test(
      'probation tries the plural route when the singular has nothing',
      () async {
        final repo = AccountRepositoryImpl(AccountRemoteService());
        late final List probation;
        final seen = await _record(
          (r) => r.url.path.endsWith('/probations/staff/staff-1')
              ? _ok([
                  {
                    'id': 'p1',
                    'status': 'Passed',
                    'milestones': ['Induction'],
                  },
                ])
              : http.Response('', 404),
          () async {
            probation = await repo.getProbation('staff-1');
          },
        );
        expect(seen.length, 2);
        expect(probation.single.status, 'Passed');
        expect(probation.single.milestones, ['Induction']);
      },
    );

    test('a 204 means nothing on file, not an error', () async {
      final repo = AccountRepositoryImpl(AccountRemoteService());
      late final List probation;
      final seen = await _record((_) => http.Response('', 204), () async {
        probation = await repo.getProbation('staff-1');
      });
      expect(probation, isEmpty);
      // The singular route exists, so the plural one is not tried.
      expect(seen.length, 1);
    });

    test('an email that could not be sent gets a plain message', () async {
      final repo = AccountRepositoryImpl(AccountRemoteService());
      late final GeneralResultModel result;
      await _record((_) => http.Response('', 502), () async {
        result = await repo.sendReferenceRequest('ref-7');
      });
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('email could not be sent'));
    });
  });
}
