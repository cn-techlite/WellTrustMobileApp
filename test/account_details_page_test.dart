import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/personal_detail.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';

class _Repo implements AccountRepository {
  @override
  Future<RegisterResponseModel> getUserData() async => RegisterResponseModel(
    id: 'staff-1',
    firstName: 'Jane',
    surName: 'Doe',
    address: '14 Rockingham Road, Kettering, NN16 8JJ',
    locality: 'Kettering',
    state: 'Northamptonshire',
    roles: const ['AdminStaff', 'StaffCarer'],
    permissions: const ['CanViewOwnProfile', 'CanUpdateOwnStaffRecords'],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accountRepositoryProvider.overrideWithValue(_Repo())],
        child: const MaterialApp(home: AccountDetailsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the carer\'s roles and permissions in plain words', (
    tester,
  ) async {
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Access and roles'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Staff carer'), findsOneWidget);
    expect(find.text('Admin staff'), findsOneWidget);
    expect(find.text('Can view own profile'), findsOneWidget);
    expect(find.text('Can update own staff records'), findsOneWidget);
  });

  testWidgets('does not repeat the town when the address already has it', (
    tester,
  ) async {
    await open(tester);
    expect(
      find.text('14 Rockingham Road, Kettering, NN16 8JJ, Northamptonshire'),
      findsOneWidget,
    );
  });

  test('humanize turns API names into readable text', () {
    expect(humanize('CanViewOwnProfile'), 'Can view own profile');
    expect(humanize('OneToOne'), 'One to one');
    expect(humanize('PreferNotToSay'), 'Prefer not to say');
    expect(humanize('Passed'), 'Passed');
    expect(humanize(''), '');
  });
}
