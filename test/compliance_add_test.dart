import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/data/repository/account_repository_impl.dart';
import 'package:well_trust_mobile_app/features/account/data/services/account_remote_services.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/compliance_card.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/compliance_sheet.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class _Repo implements AccountRepository {
  final saved = <StaffRecordRequest>[];
  String? adminStaffId;

  @override
  Future<RegisterResponseModel> getUserData() async =>
      RegisterResponseModel(id: 'staff-1');

  @override
  Future<GeneralResultModel> saveStaffRecord(
    StaffRecordRequest request, {
    required String adminStaffId,
  }) async {
    saved.add(request);
    this.adminStaffId = adminStaffId;
    return GeneralResultModel.success(
      message: 'Right to work record saved successfully',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
    globals.token = 'test-token';
  });

  group('request', () {
    test('sends all 25 fields, empty text as null', () {
      final json = ComplianceRequest(
        niNumber: ' QQ123456C ',
        dbsStatus: 'Clear',
        dbsType: '',
        rightToWorkStatus: 'Verified',
        rightToWorkShareCode: '   ',
        dbsExpiryDate: DateTime.utc(2028, 10, 1),
      ).toJson();

      expect(json.length, 25);
      expect(json['niNumber'], 'QQ123456C');
      expect(json['dbsStatus'], 'Clear');
      expect(json['dbsType'], isNull);
      expect(json['rightToWorkShareCode'], isNull);
      expect(json['dbsExpiryDate'], '2028-10-01T00:00:00.000Z');
      expect(json['visaExpiryDate'], isNull);
      expect(json.containsKey('adminStaffId'), isFalse);
    });

    test('statuses default to NotProvided so the API gets a valid value', () {
      final json = const ComplianceRequest().toJson();
      expect(json['dbsStatus'], 'NotProvided');
      expect(json['rightToWorkStatus'], 'NotProvided');
    });

    test(
      'is added with a POST to the compliance route and the carer\'s id',
      () async {
        late http.Request seen;
        final client = MockClient((r) async {
          seen = r;
          return http.Response('{}', 200);
        });
        await http.runWithClient(
          () => AccountRemoteService().saveStaffRecord(
            const ComplianceRequest(niNumber: 'QQ1'),
            adminStaffId: 'staff-1',
          ),
          () => client,
        );
        expect(seen.method, 'POST');
        expect(seen.url.path, endsWith('api/admin-staff-records/compliance'));
        expect(jsonDecode(seen.body)['adminStaffId'], 'staff-1');
        expect(jsonDecode(seen.body)['niNumber'], 'QQ1');
      },
    );
  });

  group('repository', () {
    Future<GeneralResultModel> save(StaffRecordRequest r, int status) async {
      late GeneralResultModel result;
      final client = MockClient((_) async => http.Response('', status));
      await http.runWithClient(() async {
        result = await AccountRepositoryImpl(
          AccountRemoteService(),
        ).saveStaffRecord(r, adminStaffId: 'staff-1');
      }, () => client);
      return result;
    }

    test('a 403 on a record that is already on file says so', () async {
      final result = await save(const ComplianceRequest(), 403);
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('already on file'));
      expect(result.message, contains('Only the office'));
    });

    test('a 403 on anything else keeps the usual message', () async {
      final result = await save(
        const EmergencyContactRequest(
          name: 'John',
          relationship: '',
          phone: '',
          notes: '',
        ),
        403,
      );
      expect(result.message, 'You can only change your own record.');
    });
  });

  group('the card', () {
    Future<void> show(WidgetTester tester, StaffCompliance? c) async {
      tester.view.physicalSize = const Size(390 * 3, 5000 * 3);
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

    testWidgets('offers Add when there is no record', (tester) async {
      await show(tester, null);
      expect(find.text('Add'), findsOneWidget);
      expect(find.textContaining('once'), findsOneWidget);
    });

    testWidgets('has no Add or Edit once a record exists', (tester) async {
      await show(tester, StaffCompliance.fromJson({'niNumber': 'QQ1'}));
      expect(find.text('Add'), findsNothing);
      expect(find.text('Edit'), findsNothing);
    });
  });

  group('the form', () {
    Future<_Repo> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final repo = _Repo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [accountRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                SizeConfig.init(context);
                return const Scaffold(body: ComplianceSheet());
              },
            ),
          ),
        ),
      );
      await tester.pump();
      return repo;
    }

    testWidgets('warns it can only be saved once and asks before saving', (
      tester,
    ) async {
      final repo = await open(tester);
      expect(
        find.textContaining('only the office can change it'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).first, 'QQ123456C');
      await tester.tap(find.text('Save my record'));
      await tester.pumpAndSettle();

      expect(find.text('Save your right to work record?'), findsOneWidget);
      expect(
        find.textContaining('cannot change it after you save'),
        findsOneWidget,
      );
      expect(repo.saved, isEmpty, reason: 'nothing is sent until they confirm');

      // Going back sends nothing.
      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();
      expect(repo.saved, isEmpty);
    });

    testWidgets('confirming sends the record for the carer\'s own id', (
      tester,
    ) async {
      final repo = await open(tester);
      await tester.enterText(find.byType(TextFormField).first, 'QQ123456C');
      await tester.tap(find.text('Save my record'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();

      expect(repo.saved, hasLength(1));
      final request = repo.saved.single as ComplianceRequest;
      expect(request.niNumber, 'QQ123456C');
      expect(request.dbsStatus, 'NotProvided');
      expect(request.kind, StaffRecordKind.compliance);
      expect(repo.adminStaffId, isNotNull);
    });
  });
}
