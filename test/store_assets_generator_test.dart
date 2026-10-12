import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _navy = Color(0xFF14264A);
const _navyDeep = Color(0xFF0B1322);
const _gold = Color(0xFFC9A24D);
const _goldSoft = Color(0xFFF6EBCF);
const _teal = Color(0xFF4F918C);
const _bg = Color(0xFFF3F5F9);
const _surface = Colors.white;
const _ink = Color(0xFF12203A);
const _muted = Color(0xFF55627C);
const _line = Color(0xFFDBE1EC);
const _green = Color(0xFF17683A);
const _greenSoft = Color(0xFFE1F3E8);
const _rose = Color(0xFFB42318);
const _roseSoft = Color(0xFFFDE8E6);
const _amber = Color(0xFF7F4B00);
const _amberSoft = Color(0xFFFDF0D5);

const _captureKey = Key('store-asset-capture');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final sourceSans = FontLoader('Source Sans 3')
      ..addFont(rootBundle.load('assets/fonts/SourceSans3-Variable.ttf'));
    final playfair = FontLoader('Playfair Display')
      ..addFont(rootBundle.load('assets/fonts/PlayfairDisplay-Variable.ttf'));
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([
      sourceSans.load(),
      playfair.load(),
      materialIcons.load(),
    ]);
  });

  final scenes = <_Scene>[
    _Scene('01-todays-care-run', _todayScene),
    _Scene('02-visit-details', _visitScene),
    _Scene('03-safe-clock-in', _clockInScene),
    _Scene('04-weekly-rota', _rotaScene),
    _Scene('05-care-handover', _handoverScene),
    _Scene('06-care-notes', _notesScene),
    _Scene('07-new-care-note', _newNoteScene),
    _Scene('08-secure-messages', _messagesScene),
    _Scene('09-my-documents', _documentsScene),
    _Scene('10-staff-tools', _moreScene),
  ];

  testWidgets('generate Google Play icon', (tester) async {
    await _capture(
      tester,
      path: 'store_assets/google_play/icon/welltrust-play-icon-512.png',
      physicalSize: const Size(512, 512),
      pixelRatio: 1,
      child: const _StoreIcon(),
    );
  });

  testWidgets('generate App Store icon', (tester) async {
    await _capture(
      tester,
      path: 'store_assets/apple/app_icon/welltrust-app-store-icon-1024.png',
      physicalSize: const Size(1024, 1024),
      pixelRatio: 1,
      child: const _StoreIcon(),
    );
  });

  final targets = <_Target>[
    const _Target('store_assets/google_play/phone', Size(1080, 1920), 3, 8),
    const _Target('store_assets/google_play/tablet_7', Size(1440, 2560), 3, 8),
    const _Target('store_assets/google_play/tablet_10', Size(2160, 3840), 3, 8),
    const _Target('store_assets/apple/iphone_6_9', Size(1320, 2868), 3, 10),
    const _Target('store_assets/apple/iphone_6_3', Size(1206, 2622), 3, 10),
    const _Target('store_assets/apple/ipad_13', Size(2064, 2752), 2, 10),
  ];

  for (final target in targets) {
    for (final scene in scenes.take(target.count)) {
      testWidgets('generate ${target.directory}/${scene.name}', (tester) async {
        await _capture(
          tester,
          path: '${target.directory}/${scene.name}.png',
          physicalSize: target.physicalSize,
          pixelRatio: target.pixelRatio,
          child: _PreviewApp(scene: scene.builder),
        );
      });
    }
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String path,
  required Size physicalSize,
  required double pixelRatio,
  required Widget child,
}) async {
  debugPrint('Rendering $path');
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.physicalSize = physicalSize;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.expand(child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  debugPrint('Pumped $path');

  final file = File(path);
  file.parent.createSync(recursive: true);
  await expectLater(
    find.byKey(_captureKey),
    matchesGoldenFile(file.absolute.uri),
  );
  debugPrint('Saved $path');
}

typedef _SceneBuilder = Widget Function(BuildContext context);

class _Scene {
  const _Scene(this.name, this.builder);
  final String name;
  final _SceneBuilder builder;
}

class _Target {
  const _Target(this.directory, this.physicalSize, this.pixelRatio, this.count);
  final String directory;
  final Size physicalSize;
  final double pixelRatio;
  final int count;
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.scene});
  final _SceneBuilder scene;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _navy, surface: _surface),
        fontFamily: 'Source Sans 3',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: _ink, fontSize: 15),
          bodySmall: TextStyle(color: _ink, fontSize: 13),
          titleMedium: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(
            color: _ink,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: Builder(builder: scene),
    );
  }
}

class _StoreIcon extends StatelessWidget {
  const _StoreIcon();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _navy,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.25, -0.3),
                radius: 1.1,
                colors: [Color(0xFF294872), _navy, _navyDeep],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.78, -0.76),
            child: FractionallySizedBox(
              widthFactor: .27,
              heightFactor: .27,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: .78,
              heightFactor: .78,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(38),
                  child: const _BrandMark(
                    color: _teal,
                    holeColor: Color(0xFFFFFBF0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.color, required this.holeColor});

  final Color color;
  final Color holeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BrandMarkPainter(color: color, holeColor: holeColor),
      size: Size.infinite,
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({required this.color, required this.holeColor});

  final Color color;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final unit = size.shortestSide;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * .075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cross = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .40, h * .35, w * .20, h * .48),
          Radius.circular(unit * .045),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .22, h * .38, w * .56, h * .19),
          Radius.circular(unit * .045),
        ),
      );
    canvas.drawPath(cross, fill);

    final tube = Path()
      ..moveTo(w * .24, h * .18)
      ..cubicTo(w * .05, h * .33, w * .08, h * .66, w * .33, h * .66)
      ..cubicTo(w * .45, h * .66, w * .52, h * .58, w * .52, h * .49)
      ..cubicTo(w * .52, h * .58, w * .58, h * .66, w * .70, h * .66)
      ..cubicTo(w * .92, h * .66, w * .96, h * .36, w * .76, h * .18);
    canvas.drawPath(tube, stroke);

    for (final center in [Offset(w * .24, h * .16), Offset(w * .76, h * .16)]) {
      canvas.drawCircle(center, unit * .105, fill);
      canvas.drawCircle(
        center,
        unit * .027,
        Paint()
          ..color = holeColor
          ..style = PaintingStyle.fill,
      );
    }

    final sweep = Path()
      ..moveTo(w * .40, h * .33)
      ..cubicTo(w * .45, h * .56, w * .62, h * .72, w * .78, h * .72)
      ..cubicTo(w * .58, h * .78, w * .42, h * .62, w * .34, h * .44)
      ..close();
    canvas.drawPath(sweep, fill);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.holeColor != holeColor;
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.title,
    required this.child,
    this.active = 0,
    this.showNav = true,
    this.back = false,
  });

  final String title;
  final Widget child;
  final int active;
  final bool showNav;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          const _StatusBar(),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: _navy,
            child: Row(
              children: [
                if (back) ...[
                  const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                ] else ...[
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFBF0),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: _BrandMark(
                        color: _teal,
                        holeColor: Color(0xFFFFFBF0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Icon(Icons.notifications_outlined, color: Colors.white),
                const SizedBox(width: 10),
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: _gold,
                  child: Text(
                    'AO',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
          if (showNav) _BottomNav(active: active),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      color: _navyDeep,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          Icon(
            Icons.signal_cellular_alt_rounded,
            size: 13,
            color: Colors.white,
          ),
          SizedBox(width: 5),
          Icon(Icons.wifi_rounded, size: 13, color: Colors.white),
          SizedBox(width: 5),
          Icon(Icons.battery_full_rounded, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.active});
  final int active;

  static const items = [
    (Icons.wb_sunny_outlined, 'Today'),
    (Icons.calendar_today_outlined, 'Visits'),
    (Icons.swap_horiz_rounded, 'Handover'),
    (Icons.edit_outlined, 'Notes'),
    (Icons.more_horiz_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == active;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _goldSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    items[index].$1,
                    size: 21,
                    color: selected ? _navy : _muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items[index].$2,
                  style: TextStyle(
                    color: selected ? _navy : _muted,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth >= 850 ? 850 : double.infinity,
              ),
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.color = _surface,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.kind = 0});
  final String text;
  final int kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      1 => (_greenSoft, _green),
      2 => (_roseSoft, _rose),
      3 => (_amberSoft, _amber),
      _ => (_goldSoft, _navy),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(this.text, {this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _todayScene(BuildContext context) {
  return _Shell(
    title: 'WellTrust Carer',
    active: 0,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          color: _navy,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 56),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Amara',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Sunday, 4 October',
                style: TextStyle(color: Color(0xFFB9C4DC), fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -36),
            child: _Page(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              children: [
                _Card(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'NEXT VISIT',
                            style: TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          Spacer(),
                          _Pill('24 min'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Margaret A.',
                        style: TextStyle(
                          color: _ink,
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const Text(
                        '10:00–11:00  •  Personal care',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Expanded(
                            child: _PrimaryButton(
                              'Clock in',
                              icon: Icons.login_rounded,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _PrimaryButton(
                              'View visit',
                              icon: Icons.arrow_forward_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Today's visits",
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '3 visits, 3h 15m of care, 35m travel.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                const _VisitRow(
                  time: '10:00',
                  name: 'Margaret A.',
                  detail: 'Personal care • 1h',
                  pill: 'Next',
                ),
                const SizedBox(height: 8),
                const _VisitRow(
                  time: '12:15',
                  name: 'Arthur B.',
                  detail: 'Lunch support • 45m',
                  pill: 'Later',
                ),
                const SizedBox(height: 8),
                const _VisitRow(
                  time: '15:30',
                  name: 'Evelyn C.',
                  detail: 'Medication • 1h 30m',
                  pill: 'Later',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({
    required this.time,
    required this.name,
    required this.detail,
    required this.pill,
  });
  final String time;
  final String name;
  final String detail;
  final String pill;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _Pill(pill),
        ],
      ),
    );
  }
}

Widget _visitScene(BuildContext context) {
  return _Shell(
    title: 'Visit details',
    back: true,
    showNav: false,
    child: _Page(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Margaret A.',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            _Pill('Due soon'),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Sunday, 4 October  •  10:00–11:00',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _InfoBlock(
          icon: Icons.home_outlined,
          title: 'Visit',
          lines: ['Personal care', '12 Garden Close, London'],
        ),
        const SizedBox(height: 10),
        const _InfoBlock(
          icon: Icons.favorite_outline,
          title: 'What matters today',
          lines: [
            'Support with washing and dressing',
            'Prepare breakfast and morning medication',
          ],
        ),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: _gold),
                  SizedBox(width: 8),
                  Text(
                    'Handover',
                    style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  _Pill('1 new'),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Margaret slept well. Please encourage fluids this morning.',
                style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _PrimaryButton(
          'Clock in safely',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 9),
        const Center(
          child: Text(
            'Clock-in records time and location for this visit only.',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.lines,
  });
  final IconData icon;
  final String title;
  final List<String> lines;
  @override
  Widget build(BuildContext context) => _Card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _goldSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _navy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line,
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _clockInScene(BuildContext context) {
  return _Shell(
    title: 'Clock in',
    back: true,
    showNav: false,
    child: Container(
      color: const Color(0xFFDCE2EC),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ready to start this visit?',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Margaret A.  •  10:00–11:00',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const _InfoBlock(
                icon: Icons.location_on_outlined,
                title: 'Location confirmed',
                lines: [
                  'You are at the expected visit address.',
                  'Location is read only when you clock in or out.',
                ],
              ),
              const SizedBox(height: 16),
              const _PrimaryButton(
                'Confirm clock in',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Not at the address? Tell the office before continuing.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _rotaScene(BuildContext context) {
  return _Shell(
    title: 'Visits (Rota)',
    active: 1,
    child: _Page(
      children: [
        const Row(
          children: [
            Icon(Icons.arrow_back_rounded, color: _navy),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '29 Sep to 5 Oct 2026',
                    style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'This week',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: _navy),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            final selected = i == 6;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _navy : _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? _navy : _line),
                ),
                child: Column(
                  children: [
                    Text(
                      days[i],
                      style: TextStyle(
                        color: selected ? Colors.white : _muted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${29 + i > 30 ? i - 1 : 29 + i}',
                      style: TextStyle(
                        color: selected ? Colors.white : _ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ([0, 2, 4, 6].contains(i))
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: const BoxDecoration(
                          color: _gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        const _Card(
          child: Row(
            children: [
              Expanded(
                child: _Metric(label: 'Care', value: '11h 45m'),
              ),
              SizedBox(width: 1, height: 36, child: ColoredBox(color: _line)),
              Expanded(
                child: _Metric(label: 'Travel', value: '2h 10m'),
              ),
              SizedBox(width: 1, height: 36, child: ColoredBox(color: _line)),
              Expanded(
                child: _Metric(label: 'Visits', value: '14'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Sunday, 4 October',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const _VisitRow(
          time: '10:00',
          name: 'Margaret A.',
          detail: 'Personal care • 1h',
          pill: 'Due soon',
        ),
        const SizedBox(height: 8),
        const _VisitRow(
          time: '12:15',
          name: 'Arthur B.',
          detail: 'Lunch support • 45m',
          pill: 'Later',
        ),
        const SizedBox(height: 8),
        const _VisitRow(
          time: '15:30',
          name: 'Evelyn C.',
          detail: 'Medication • 1h 30m',
          pill: 'Later',
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: _navy,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
    ],
  );
}

Widget _handoverScene(BuildContext context) {
  return _Shell(
    title: 'Care handover',
    active: 2,
    child: _Page(
      children: [
        const Text(
          'Read what matters before each visit, then leave a clear update for the next carer.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 12),
        const _PrimaryButton('Add handover', icon: Icons.edit_outlined),
        const SizedBox(height: 12),
        Row(
          children: ['Today (3)', 'All (8)', 'Flagged (2)']
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: entry.key < 2 ? 5 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: entry.key == 0 ? _navy : _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: entry.key == 0 ? _navy : _line),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: entry.key == 0 ? Colors.white : _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        const _HandoverRow(
          name: 'Margaret A.',
          time: 'Next visit 10:00',
          note: 'Slept well. Encourage fluids this morning.',
          pill: '1 new',
          kind: 0,
        ),
        const SizedBox(height: 9),
        const _HandoverRow(
          name: 'Arthur B.',
          time: 'Next visit 12:15',
          note: 'Low appetite yesterday. Please monitor lunch.',
          pill: 'Concern',
          kind: 2,
        ),
        const SizedBox(height: 9),
        const _HandoverRow(
          name: 'Evelyn C.',
          time: 'Next visit 15:30',
          note: 'Prescription collected and stored safely.',
          pill: 'To do',
          kind: 3,
        ),
      ],
    ),
  );
}

class _HandoverRow extends StatelessWidget {
  const _HandoverRow({
    required this.name,
    required this.time,
    required this.note,
    required this.pill,
    required this.kind,
  });
  final String name;
  final String time;
  final String note;
  final String pill;
  final int kind;
  @override
  Widget build(BuildContext context) => _Card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(time, style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 6),
              Text(
                note,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _Pill(pill, kind: kind),
      ],
    ),
  );
}

Widget _notesScene(BuildContext context) {
  return _Shell(
    title: 'Notes',
    active: 3,
    child: _Page(
      children: [
        const Text(
          'Care notes you have written. Notes from a visit are added when you finish it.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        const _PrimaryButton('Add a care note', icon: Icons.add_rounded),
        const SizedBox(height: 13),
        const _NoteRow(
          name: 'Margaret A.',
          time: '4 Oct, 11:02',
          summary: 'Personal care completed. Ate breakfast and drank tea.',
          pill: 'Settled',
          kind: 1,
        ),
        const SizedBox(height: 9),
        const _NoteRow(
          name: 'Arthur B.',
          time: '3 Oct, 13:10',
          summary: 'Lunch prepared. Reduced appetite reported to the office.',
          pill: 'Concern raised',
          kind: 2,
        ),
        const SizedBox(height: 9),
        const _NoteRow(
          name: 'Evelyn C.',
          time: '3 Oct, 16:45',
          summary: 'Medication prompted and wellbeing checked.',
          pill: 'No concerns',
          kind: 1,
        ),
      ],
    ),
  );
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.name,
    required this.time,
    required this.summary,
    required this.pill,
    required this.kind,
  });
  final String name;
  final String time;
  final String summary;
  final String pill;
  final int kind;
  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            _Pill(pill, kind: kind),
          ],
        ),
        const Divider(height: 18, color: _line),
        Text(
          summary,
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.35),
        ),
      ],
    ),
  );
}

Widget _newNoteScene(BuildContext context) {
  return _Shell(
    title: 'New care note',
    back: true,
    showNav: false,
    child: _Page(
      children: [
        const Text(
          'Record care clearly',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 23,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Keep notes factual, respectful and relevant to the visit.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _Field(
          label: 'Person supported',
          value: 'Margaret A.',
          icon: Icons.keyboard_arrow_down_rounded,
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _Field(label: 'Visit date', value: '4 Oct 2026'),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _Field(label: 'Support type', value: 'Personal care'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'How were they?',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(child: _Choice('Settled', selected: true)),
            SizedBox(width: 6),
            Expanded(child: _Choice('Anxious')),
            SizedBox(width: 6),
            Expanded(child: _Choice('Unwell')),
          ],
        ),
        const SizedBox(height: 10),
        const _Field(
          label: 'Care note',
          value:
              'Personal care completed. Margaret ate breakfast and drank a full cup of tea.',
          tall: true,
        ),
        const SizedBox(height: 13),
        const _PrimaryButton('Save care note', icon: Icons.check_rounded),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.icon,
    this.tall = false,
  });
  final String label;
  final String value;
  final IconData? icon;
  final bool tall;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _ink,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 5),
      Container(
        constraints: BoxConstraints(minHeight: tall ? 86 : 45),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8592AB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: _ink, fontSize: 13),
              ),
            ),
            if (icon != null) Icon(icon, color: _muted, size: 18),
          ],
        ),
      ),
    ],
  );
}

class _Choice extends StatelessWidget {
  const _Choice(this.text, {this.selected = false});
  final String text;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: selected ? _goldSoft : _surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: selected ? _gold : _line),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: selected ? _navy : _muted,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}

Widget _messagesScene(BuildContext context) {
  return _Shell(
    title: 'Messages',
    child: _Page(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Secure conversations',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                ),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Keep in touch with the office and your care team.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 13),
        const _MessageRow(
          initials: 'OC',
          name: 'Office care team',
          message: 'Thanks, the rota change is confirmed.',
          time: '09:26',
          unread: 2,
        ),
        const SizedBox(height: 8),
        const _MessageRow(
          initials: 'SM',
          name: 'Sarah M.',
          message: 'I have added the handover update.',
          time: 'Yesterday',
        ),
        const SizedBox(height: 8),
        const _MessageRow(
          initials: 'TR',
          name: 'Training team',
          message: 'Your moving and handling refresher is booked.',
          time: 'Fri',
        ),
        const SizedBox(height: 8),
        const _MessageRow(
          initials: 'PL',
          name: 'Payroll',
          message: 'Your approved hours are now available.',
          time: 'Thu',
        ),
      ],
    ),
  );
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.initials,
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
  });
  final String initials;
  final String name;
  final String message;
  final String time;
  final int unread;
  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _goldSoft,
          child: Text(
            initials,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(color: _muted, fontSize: 10)),
            if (unread > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _documentsScene(BuildContext context) {
  return _Shell(
    title: 'My documents',
    back: true,
    showNav: false,
    child: _Page(
      children: [
        const Text(
          'Compliance at a glance',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 23,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Keep your documents, training and checks current.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 13),
        const _Card(
          color: _goldSoft,
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _navy, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6 of 7 up to date',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'One certificate needs attention',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _Pill('Action needed', kind: 3),
            ],
          ),
        ),
        const SizedBox(height: 13),
        const _DocumentRow(
          icon: Icons.badge_outlined,
          title: 'Right to work',
          subtitle: 'Checked 12 Mar 2026',
          pill: 'Current',
          kind: 1,
        ),
        const SizedBox(height: 8),
        const _DocumentRow(
          icon: Icons.health_and_safety_outlined,
          title: 'DBS check',
          subtitle: 'Enhanced check on file',
          pill: 'Current',
          kind: 1,
        ),
        const SizedBox(height: 8),
        const _DocumentRow(
          icon: Icons.school_outlined,
          title: 'Moving & handling',
          subtitle: 'Expires 18 Oct 2026',
          pill: 'Due soon',
          kind: 3,
        ),
        const SizedBox(height: 8),
        const _DocumentRow(
          icon: Icons.medical_services_outlined,
          title: 'Medication competency',
          subtitle: 'Completed 9 Aug 2026',
          pill: 'Current',
          kind: 1,
        ),
      ],
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pill,
    required this.kind,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String pill;
  final int kind;
  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _goldSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _navy, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        _Pill(pill, kind: kind),
      ],
    ),
  );
}

Widget _moreScene(BuildContext context) {
  return _Shell(
    title: 'More',
    active: 4,
    child: Column(
      children: [
        Container(
          color: _navy,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 52),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: _gold,
                child: Text(
                  'AO',
                  style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amara Okafor',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Staff carer • London team',
                      style: TextStyle(color: Color(0xFFB9C4DC), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -32),
            child: _Page(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              children: const [
                _MenuRow(
                  icon: Icons.add_circle_outline,
                  title: 'Open shifts',
                  subtitle: '3 shifts available',
                  badge: '3',
                ),
                SizedBox(height: 8),
                _MenuRow(
                  icon: Icons.access_time,
                  title: 'My hours',
                  subtitle: 'Care time and travel',
                ),
                SizedBox(height: 8),
                _MenuRow(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Assessments',
                  subtitle: '2 to complete',
                  badge: '2',
                ),
                SizedBox(height: 8),
                _MenuRow(
                  icon: Icons.warning_amber_rounded,
                  title: 'Incident report',
                  subtitle: 'Report something that happened',
                ),
                SizedBox(height: 8),
                _MenuRow(
                  icon: Icons.folder_open_outlined,
                  title: 'My documents',
                  subtitle: 'Certificates and qualifications',
                ),
                SizedBox(height: 8),
                _MenuRow(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Text size and appearance',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.all(11),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _goldSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: _navy, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (badge != null) _Pill(badge!),
        const SizedBox(width: 5),
        const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
      ],
    ),
  );
}
