import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/screen/notes_screen.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/providers/care_note_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/client_provider.dart';
import 'support/mobile_fixtures.dart';

void main() {
  Future<void> pumpNotes(
    WidgetTester tester, {
    ProviderContainer? container,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final app = MaterialApp(
      home: Builder(
        builder: (context) {
          SizeConfig.init(context);
          return const NotesScreen();
        },
      ),
    );

    await tester.pumpWidget(
      container == null
          ? ProviderScope(
              overrides: [
                assignedClientsProvider.overrideWith(
                  FixtureAssignedClientsController.new,
                ),
                careNotesProvider.overrideWith(FixtureCareNotesNotifier.new),
              ],
              child: app,
            )
          : UncontrolledProviderScope(container: container, child: app),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty Notes tab follows the design and opens the add page', (
    tester,
  ) async {
    await pumpNotes(tester);

    expect(
      find.text(
        'Care notes you have written. Notes from a visit are added when you finish it.',
      ),
      findsOneWidget,
    );
    expect(find.text('No care notes yet'), findsOneWidget);

    await tester.tap(find.text('Add a care note'));
    await tester.pumpAndSettle();

    expect(find.text('New care note'), findsOneWidget);
    expect(find.text('Who is it about?'), findsOneWidget);
    expect(find.text('How were they?'), findsOneWidget);
    expect(find.text('Save care note'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'person dropdown opens and explains when no clients are assigned',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          assignedClientsProvider.overrideWith(
            EmptyAssignedClientsController.new,
          ),
          careNotesProvider.overrideWith(FixtureCareNotesNotifier.new),
        ],
      );
      addTearDown(container.dispose);
      await pumpNotes(tester, container: container);

      await tester.tap(find.text('Add a care note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a person'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomDropdownBottomSheet), findsOneWidget);
      expect(
        find.text('No residents or clients are currently assigned to you.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('saved care notes expand to show their designed detail', (
    tester,
  ) async {
    final note = CareNoteEntry(
      id: 'N1',
      clientId: 'U1',
      clientName: 'Harold',
      at: DateTime(2026, 9, 24, 4, 40),
      mood: 'Low',
      intake: 'Little',
      skin: 'No concerns',
      text: 'Harold was more tired than usual.',
      flagged: true,
    );
    final container = ProviderContainer(
      overrides: [
        assignedClientsProvider.overrideWith(
          FixtureAssignedClientsController.new,
        ),
        careNotesProvider.overrideWith(() => FixtureCareNotesNotifier([note])),
      ],
    );
    addTearDown(container.dispose);

    await pumpNotes(tester, container: container);

    expect(find.text('Harold'), findsOneWidget);
    expect(find.text('Flagged'), findsOneWidget);
    await tester.tap(find.text('Harold'));
    await tester.pumpAndSettle();

    expect(find.text('Food and drink'), findsOneWidget);
    expect(find.text('Little'), findsOneWidget);
    expect(find.text('Skin and comfort'), findsOneWidget);
    expect(find.text('Harold was more tired than usual.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('person search shows names and saves the selected id', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        assignedClientsProvider.overrideWith(
          FixtureAssignedClientsController.new,
        ),
        careNotesProvider.overrideWith(FixtureCareNotesNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    await pumpNotes(tester, container: container);

    await tester.tap(find.text('Add a care note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a person'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byType(CustomDropdownBottomSheet),
        matching: find.byType(GlobalTextField),
      ),
      'Dorothy',
    );
    await tester.pump();
    expect(find.text('Mrs Dorothy Bell'), findsOneWidget);
    expect(find.text('Mr Harold Fisher'), findsNothing);

    await tester.tap(find.text('Mrs Dorothy Bell'));
    await tester.pumpAndSettle();
    expect(find.text('Mrs Dorothy Bell'), findsOneWidget);

    await tester.tap(find.text('Settled'));
    await tester.tap(find.text('Good'));
    await tester.tap(find.text('No concerns'));
    await tester.enterText(
      find.byType(GlobalTextField),
      'Dorothy was comfortable after the family phone call.',
    );
    await tester.scrollUntilVisible(
      find.text('Save care note'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save care note'));
    await tester.pumpAndSettle();

    final saved = container.read(careNotesProvider).notes.single;
    expect(saved.clientId, 'U3');
    expect(find.text('Dorothy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
