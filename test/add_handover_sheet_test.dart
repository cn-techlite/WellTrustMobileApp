import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/add_handover_sheet.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/providers/client_provider.dart';
import 'support/mobile_fixtures.dart';

void main() {
  testWidgets('complete handover form paints the follow-up tile correctly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assignedClientsProvider.overrideWith(
            FixtureAssignedClientsController.new,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              SizeConfig.init(context);
              return const AddHandoverPage(clientId: 'U1');
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('More detail (optional)'), findsOneWidget);
    expect(
      find.text('Someone needs to do something about this.'),
      findsOneWidget,
    );
    expect(find.text('Needed by (optional)'), findsOneWidget);
  });
}
