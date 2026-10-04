import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/domain/controller/account_controller.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/account.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/account_state_model.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/providers/client_provider.dart';
import 'support/mobile_fixtures.dart';

class _FakeAccountController extends AccountController {
  @override
  FutureOr<AccountStateModel> build() =>
      const AccountStateModel(hasFetchedAccount: true);

  @override
  Future<void> getAccount({bool forceRefresh = false}) async {}
}

void main() {
  setUpAll(() {
    if (!getIt.isRegistered<AppGlobals>()) {
      getIt.registerLazySingleton<AppGlobals>(AppGlobals.new);
    }
  });

  Future<void> pumpMore(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountControllerProvider.overrideWith(_FakeAccountController.new),
          assignedClientsProvider.overrideWith(
            FixtureAssignedClientsController.new,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              SizeConfig.init(context);
              return const AccountPage();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTile(WidgetTester tester, String title) async {
    final tile = find.text(title);
    await tester.scrollUntilVisible(
      tile,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('My hours opens the clock-in based hours page', (tester) async {
    await pumpMore(tester);
    await openTile(tester, 'My hours');

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Last week'), findsOneWidget);
    expect(find.text('Care time'), findsOneWidget);
    expect(find.text('Planned travel'), findsOneWidget);
    expect(find.text('No finished visits'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Assessments opens its list and full review form', (
    tester,
  ) async {
    await pumpMore(tester);
    await openTile(tester, 'Assessments');

    expect(find.text('Home risk review'), findsNWidgets(fixtureClients.length));
    expect(find.text('Open assessment'), findsNWidgets(fixtureClients.length));

    await tester.tap(find.text('Open assessment').first);
    await tester.pumpAndSettle();

    expect(find.text('Date of review'), findsOneWidget);
    expect(find.text('Personal care'), findsOneWidget);
    expect(find.text('Medication support'), findsOneWidget);
    expect(find.text('Overall summary'), findsOneWidget);
    expect(find.text('Save draft'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Incident report opens the designed full report page', (
    tester,
  ) async {
    await pumpMore(tester);
    await openTile(tester, 'Incident report');

    expect(find.text('New report'), findsOneWidget);
    expect(find.text('Submitted (0)'), findsOneWidget);
    expect(
      find.text(
        'If anyone is in immediate danger, call 999 first, then the office.',
      ),
      findsOneWidget,
    );
    expect(find.text('What kind of incident?'), findsOneWidget);
    expect(find.text('Submit incident report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Complaints opens the designed complaint record page', (
    tester,
  ) async {
    await pumpMore(tester);
    await openTile(tester, 'Complaints');

    expect(find.text('New complaint'), findsOneWidget);
    expect(find.text('Submitted (0)'), findsOneWidget);
    expect(find.text('Who raised it?'), findsOneWidget);
    expect(find.text('Who is it about?'), findsOneWidget);
    expect(find.text('Complaint details'), findsOneWidget);
    expect(find.text('Submit complaint'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
