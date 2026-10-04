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

  testWidgets('Open shifts does not display local demonstration records', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountControllerProvider.overrideWith(_FakeAccountController.new),
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

    await tester.drag(find.byType(ListView).first, const Offset(0, -90));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open shifts'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Open shifts are not published through the mobile API. Your assigned work appears in Visits (Rota).',
      ),
      findsOneWidget,
    );
    expect(find.text('No open shifts available'), findsOneWidget);
    expect(find.textContaining('07:30 to 14:30'), findsNothing);
    expect(find.text('Ask for this shift'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
