import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/messages/presentation/state/providers/message_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';
import 'support/mobile_fixtures.dart';

void main() {
  testWidgets('app-bar message icon opens the designed inbox and thread', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [messagesProvider.overrideWith(FixtureMessageController.new)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              SizeConfig.init(context);
              return const Scaffold(
                body: Column(
                  children: [
                    WellTrustAppBar(title: 'Today'),
                    Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(unreadMessageCountProvider), 3);
    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    expect(find.text('New message to the office'), findsOneWidget);
    expect(find.text('Your rota for next week'), findsOneWidget);
    expect(find.text('Medication Training certificate'), findsOneWidget);
    expect(find.text('Key safe reminder'), findsOneWidget);

    await tester.tap(find.text('Your rota for next week'));
    await tester.pumpAndSettle();

    expect(find.text('Message'), findsOneWidget);
    expect(find.text('With Management'), findsOneWidget);
    expect(
      find.textContaining('Next week\'s rota is now live.'),
      findsOneWidget,
    );
    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Send reply'), findsOneWidget);
    expect(container.read(unreadMessageCountProvider), 2);
    expect(tester.takeException(), isNull);
  });
}
