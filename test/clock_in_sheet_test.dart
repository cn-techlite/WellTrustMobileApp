import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/services/location_service.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';

/// The fake fix's position, used by every test unless it sets a client
/// address of its own.
const _fixLat = 52.4;
const _fixLng = -0.72;

class _FakeLocation extends LocationService {
  final LocationException? failure;

  /// When set, `currentFix` waits for this to complete before returning, so
  /// tests can inspect the sheet mid-fetch.
  final Completer<void>? gate;
  int calls = 0;
  int settingsOpened = 0;

  _FakeLocation({this.failure, this.gate});

  @override
  Future<LocationFix> currentFix() async {
    calls++;
    if (gate != null) await gate!.future;
    if (failure != null) throw failure!;
    return LocationFix(
      latitude: _fixLat,
      longitude: _fixLng,
      accuracy: 8,
      capturedAt: DateTime(2026, 9, 21, 20, 50),
    );
  }

  @override
  Future<void> openSettings(LocationException e) async => settingsOpened++;
}

Future<ClockInDetails?> _open(
  WidgetTester tester, {
  required _FakeLocation location,
  DateTime? start,
  double? clientLatitude,
  double? clientLongitude,
  required Future<void> Function() interact,
}) async {
  ClockInDetails? result;
  var closed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await showClockInSheet(
                context,
                preferred: 'Harold',
                start: start,
                clientLatitude: clientLatitude,
                clientLongitude: clientLongitude,
                locationService: location,
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await interact();
  await _afterLocate(tester);
  expect(tester.takeException(), isNull);
  // Whatever happened, the sheet either returned or is still showing.
  if (!closed) expect(find.text('Clock in to Harold'), findsOneWidget);
  return result;
}

/// Pumps past the sheet's brief "found it" pause once a fix comes back, since
/// that pause is a plain timer rather than a scheduled frame and
/// `pumpAndSettle` alone will not wait for it.
Future<void> _afterLocate(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

DateTime _in(int mins) =>
    DateTime.now().add(Duration(minutes: mins, seconds: 30));

void main() {
  testWidgets('early: says how early and asks why', (tester) async {
    final start = _in(26);
    await _open(
      tester,
      location: _FakeLocation(),
      start: start,
      interact: () async {
        expect(find.text('Clock in to Harold'), findsOneWidget);
        expect(
          find.textContaining(
            'You are 26 min early for the ${hhmm(start)} start',
          ),
          findsOneWidget,
        );
        expect(find.text('Why are you starting early?'), findsOneWidget);
        expect(find.text('Where are you now?'), findsOneWidget);
        expect(find.text("I am at Harold's home"), findsOneWidget);
        expect(find.text('I am somewhere else'), findsOneWidget);
      },
    );
  });

  testWidgets('early: needs a reason before it reads the location', (
    tester,
  ) async {
    final location = _FakeLocation();
    final result = await _open(
      tester,
      location: location,
      start: _in(20),
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await tester.pumpAndSettle();
        expect(
          find.text('Please tell the office why you are early.'),
          findsOneWidget,
        );
        expect(location.calls, 0);
      },
    );
    expect(result, isNull);
  });

  testWidgets('early: saves the reason and the location', (tester) async {
    final location = _FakeLocation();
    final result = await _open(
      tester,
      location: location,
      start: _in(20),
      interact: () async {
        await tester.enterText(
          find.byType(TextField),
          '  Last visit ended early ',
        );
        await tester.tap(find.text("I am at Harold's home"));
      },
    );
    expect(location.calls, 1);
    expect(result, isNotNull);
    expect(result!.earlyReason, 'Last visit ended early');
    expect(result.atClientHome, isTrue);
    expect(result.location!.latitude, 52.4);
    expect(result.location!.accuracy, 8);
  });

  testWidgets('on time: no reason box, somewhere else is recorded', (
    tester,
  ) async {
    final location = _FakeLocation();
    final result = await _open(
      tester,
      location: location,
      start: _in(3),
      interact: () async {
        expect(find.byType(TextField), findsNothing);
        expect(find.textContaining('min early'), findsNothing);
        await tester.tap(find.text('I am somewhere else'));
      },
    );
    expect(result!.atClientHome, isFalse);
    expect(result.earlyReason, isNull);
    expect(result.location, isNotNull);
  });

  testWidgets('with no planned start it never asks for a reason', (
    tester,
  ) async {
    final result = await _open(
      tester,
      location: _FakeLocation(),
      interact: () async {
        expect(find.byType(TextField), findsNothing);
        await tester.tap(find.text("I am at Harold's home"));
      },
    );
    expect(result!.atClientHome, isTrue);
  });

  testWidgets('cancel returns nothing and reads no location', (tester) async {
    final location = _FakeLocation();
    final result = await _open(
      tester,
      location: location,
      start: _in(3),
      interact: () async => tester.tap(find.text('Cancel')),
    );
    expect(result, isNull);
    expect(location.calls, 0);
  });

  testWidgets('location off: explains, and can clock in without it', (
    tester,
  ) async {
    final location = _FakeLocation(
      failure: const LocationException(LocationProblem.serviceOff),
    );
    final result = await _open(
      tester,
      location: location,
      start: _in(3),
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Location is switched off on this phone'),
          findsOneWidget,
        );
        await tester.tap(find.text('Open Settings'));
        await tester.pumpAndSettle();
        expect(location.settingsOpened, 1);
        await tester.tap(find.text('Clock in without location'));
      },
    );
    expect(result!.location, isNull);
    expect(result.atClientHome, isNull);
    expect(result.hasLocation, isFalse);
  });

  testWidgets('a temporary failure can be retried without Settings', (
    tester,
  ) async {
    final location = _FakeLocation(
      failure: const LocationException(LocationProblem.unavailable),
    );
    await _open(
      tester,
      location: location,
      start: _in(3),
      interact: () async {
        await tester.tap(find.text('I am somewhere else'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('could not find your location'),
          findsOneWidget,
        );
        expect(find.text('Open Settings'), findsNothing);
        await tester.tap(find.text('I am somewhere else'));
        await tester.pumpAndSettle();
        expect(location.calls, 2);
      },
    );
  });

  testWidgets('without location an early start still needs a reason', (
    tester,
  ) async {
    final location = _FakeLocation(
      failure: const LocationException(LocationProblem.deniedForever),
    );
    final result = await _open(
      tester,
      location: location,
      start: _in(20),
      interact: () async {
        await tester.enterText(find.byType(TextField), 'Early finish');
        await tester.tap(find.text('I am somewhere else'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '');
        await tester.ensureVisible(find.text('Clock in without location'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clock in without location'));
        await tester.pumpAndSettle();
        expect(
          find.text('Please tell the office why you are early.'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), 'Early finish');
        await tester.ensureVisible(find.text('Clock in without location'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clock in without location'));
      },
    );
    expect(result!.earlyReason, 'Early finish');
    expect(result.location, isNull);
  });

  testWidgets('fits a small phone with the keyboard up', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _open(
      tester,
      location: _FakeLocation(),
      start: _in(26),
      interact: () async {
        await tester.enterText(find.byType(TextField), 'Because');
      },
    );
  });

  testWidgets('locating: shows a progress panel, then the accuracy', (
    tester,
  ) async {
    final gate = Completer<void>();
    final location = _FakeLocation(gate: gate);
    await _open(
      tester,
      location: location,
      start: _in(3),
      interact: () async {
        await tester.tap(find.text('I am somewhere else'));
        await tester.pump();
        expect(find.text('Finding your exact location'), findsOneWidget);
        expect(find.textContaining('Accurate to about'), findsNothing);
        expect(find.text('Cancel'), findsOneWidget);

        gate.complete();
        await tester.pump();
        expect(find.text('Accurate to about 8 m'), findsOneWidget);
      },
    );
  });

  testWidgets('too far: warns, and can clock in anyway', (tester) async {
    const clientLat = 52.3975;
    const clientLng = -0.7395;
    final expectedDistance = LocationService.distanceBetween(
      _fixLat,
      _fixLng,
      clientLat,
      clientLng,
    );
    final expectedText = formatDistance(expectedDistance);
    final location = _FakeLocation();
    final result = await _open(
      tester,
      location: location,
      start: _in(3),
      clientLatitude: clientLat,
      clientLongitude: clientLng,
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await _afterLocate(tester);
        expect(
          find.textContaining(
            'You look to be about $expectedText from '
            "Harold's address",
          ),
          findsOneWidget,
        );
        expect(find.text('Clock in anyway'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('I am somewhere else'), findsOneWidget);
        await tester.tap(find.text('Clock in anyway'));
      },
    );
    expect(result!.atClientHome, isTrue);
    expect(result.flaggedTooFarFromClient, isTrue);
    expect(result.distanceFromClientMetres, closeTo(expectedDistance, 0.01));
  });

  testWidgets('too far: somewhere else records it without the flag', (
    tester,
  ) async {
    final result = await _open(
      tester,
      location: _FakeLocation(),
      start: _in(3),
      clientLatitude: 52.3975,
      clientLongitude: -0.7395,
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await _afterLocate(tester);
        await tester.tap(find.text('I am somewhere else'));
      },
    );
    expect(result!.atClientHome, isFalse);
    expect(result.flaggedTooFarFromClient, isFalse);
    expect(result.distanceFromClientMetres, isNotNull);
  });

  testWidgets('too far: try again reads the location again', (tester) async {
    final location = _FakeLocation();
    await _open(
      tester,
      location: location,
      start: _in(3),
      clientLatitude: 52.3975,
      clientLongitude: -0.7395,
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await _afterLocate(tester);
        expect(location.calls, 1);
        await tester.tap(find.text('Try again'));
        await tester.pump();
        expect(find.text('Finding your exact location'), findsOneWidget);
        await _afterLocate(tester);
        expect(location.calls, 2);
        expect(find.text('Clock in anyway'), findsOneWidget);
      },
    );
  });

  testWidgets('too far: cancel aborts the whole clock-in', (tester) async {
    final result = await _open(
      tester,
      location: _FakeLocation(),
      start: _in(3),
      clientLatitude: 52.3975,
      clientLongitude: -0.7395,
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
        await _afterLocate(tester);
        await tester.tap(find.text('Cancel'));
      },
    );
    expect(result, isNull);
  });

  testWidgets('close enough: finishes without a warning', (tester) async {
    final result = await _open(
      tester,
      location: _FakeLocation(),
      start: _in(3),
      // Right where the fake fix says the phone is.
      clientLatitude: _fixLat,
      clientLongitude: _fixLng,
      interact: () async {
        await tester.tap(find.text("I am at Harold's home"));
      },
    );
    expect(result!.atClientHome, isTrue);
    expect(result.flaggedTooFarFromClient, isFalse);
    expect(result.distanceFromClientMetres, lessThan(1));
  });
}
