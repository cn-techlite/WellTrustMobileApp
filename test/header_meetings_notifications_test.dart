import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/data/service/home_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/notification_controller.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';
import 'package:well_trust_mobile_app/shared/state/header_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/meeting_provider.dart';
import 'support/mobile_fixtures.dart';

class _FakeNotifications extends NotificationController {
  @override
  FutureOr<NotificationStateModel> build() => NotificationStateModel(
    hasFetched: true,
    allNotification: [
      NotificationResponseModel(
        id: 'n1',
        userId: 'staff-1',
        title: 'Management changed your rota',
        body: 'One changed visit. Open the rota and confirm you have seen it.',
        notificationType: 'rota',
        createdAt: DateTime.now(),
      ),
      NotificationResponseModel(
        id: 'n2',
        userId: 'staff-1',
        title: 'Medication Training certificate has expired',
        body: 'Upload a current copy so the office can approve it.',
        notificationType: 'document',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  );

  @override
  Future<void> getAllNotificationExploreData({
    bool forceRefresh = false,
  }) async {}
}

class _FailingNotificationService extends HomeRemoteService {
  @override
  Future<List<NotificationResponseModel>> getNotifications() {
    return Future.error('Server error. Please try again later.');
  }
}

void main() {
  setUpAll(() {
    if (!getIt.isRegistered<AppGlobals>()) {
      getIt.registerLazySingleton<AppGlobals>(AppGlobals.new);
    }
  });

  Future<ProviderContainer> pumpHeader(
    WidgetTester tester, {
    bool fakeNotifications = false,
    bool failingNotifications = false,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        meetingsProvider.overrideWith(FixtureMeetingsController.new),
        if (fakeNotifications)
          notificationControllerProvider.overrideWith(_FakeNotifications.new),
        if (failingNotifications)
          homeRemoteServiceProvider.overrideWithValue(
            _FailingNotificationService(),
          ),
      ],
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
    return container;
  }

  testWidgets('team icon opens the designed meetings and saved minutes', (
    tester,
  ) async {
    await pumpHeader(tester);

    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Saved meetings'), findsOneWidget);
    expect(find.text('Monthly team meeting (last month)'), findsOneWidget);

    await tester.tap(find.text('Monthly team meeting (last month)'));
    await tester.pumpAndSettle();

    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Minutes'), findsWidgets);
    expect(find.text('Decisions'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bell opens the designed notification inbox and read controls', (
    tester,
  ) async {
    globals.userId = 'staff-1';
    final container = await pumpHeader(tester, fakeNotifications: true);

    expect(container.read(unreadNotificationsProvider), 2);
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Unread (2)'), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);
    expect(find.text('Notification settings'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    await tester.tap(find.text('Mark all as read'));
    await tester.pump();
    expect(container.read(unreadNotificationsProvider), 0);
    expect(find.text('Unread (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notification server failure is handled with a retry state', (
    tester,
  ) async {
    await pumpHeader(tester, failingNotifications: true);

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.text('Could not load notifications'), findsOneWidget);
    expect(find.text('Server error. Please try again later.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
