// ignore_for_file: use_build_context_synchronously

import 'package:well_trust_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:well_trust_mobile_app/shared/state/connectivity_state.dart';
import 'package:well_trust_mobile_app/shared/state/theme_state.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'core/helpers/globals.dart';
import 'core/routes/routers.dart';
import 'core/utils/package_export.dart';
import 'core/routes/routers.dart' as router;

//Store this globally
// Global RouteObserver instance
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

//final _pushMessagingNotification = getIt<PushNotificationService>();

Future myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("onBackgroundMessage: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Upgrader.clearSavedSettings(); // REMOVE this for release builds
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // await Firebase.initializeApp();
  getIt.registerLazySingleton<AppGlobals>(() => AppGlobals());
  await setupLocator();
  // await FirebaseMessaging.instance.getInitialMessage();
  //  await _pushMessagingNotification.initialize();

  //!Handle Push Notification when app is in background and when app is terminated
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  await globals.init();
  await _refreshSessionOnAppOpen();

  final navigatorKey = GlobalKey<NavigatorState>();
  String? route = await initialRoute();

  runApp(
    ProviderScope(
      child: MyApp(route: route, navigatorKey: navigatorKey),
    ),
  );
}

Future<void> _refreshSessionOnAppOpen() async {
  final hasAnySavedSession =
      globals.userId.isNotEmpty ||
      globals.token.isNotEmpty ||
      globals.refreshToken.isNotEmpty;

  if (!hasAnySavedSession) return;

  final canRefresh =
      globals.username.trim().isNotEmpty &&
      globals.refreshToken.trim().isNotEmpty;

  final localStorageService = getIt<AuthLocalStorageService>();

  if (!canRefresh) {
    await localStorageService.clearAuthSession();
    await globals.init();
    return;
  }

  final repository = getIt<AuthRepository>();

  final result = await repository.refreshTokens();

  if (result.isSuccess) return;

  final message = (result.message ?? '').toLowerCase();
  final shouldKeepOfflineSession =
      message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('connection') ||
      message.contains('network') ||
      message.contains('internet');

  if (shouldKeepOfflineSession) {
    debugPrint("Session refresh skipped: ${result.message}");
    return;
  }

  await localStorageService.clearAuthSession();
  await globals.init();
}

/// Source Sans 3 for body text, Playfair Display for headings.
TextTheme _designTextTheme(TextTheme t) {
  final body = t.apply(
    fontFamily: 'Source Sans 3',
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  TextStyle? serif(TextStyle? s) =>
      s?.copyWith(fontFamily: 'Playfair Display', fontWeight: FontWeight.w700);
  return body.copyWith(
    displayLarge: serif(body.displayLarge),
    displayMedium: serif(body.displayMedium),
    displaySmall: serif(body.displaySmall),
    headlineLarge: serif(body.headlineLarge),
    headlineMedium: serif(body.headlineMedium),
    headlineSmall: serif(body.headlineSmall),
    titleLarge: serif(body.titleLarge),
    titleMedium: serif(body.titleMedium),
  );
}

ThemeData _welltrustTheme(bool dark) {
  final brightness = dark ? Brightness.dark : Brightness.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.gold,
          onSecondary: AppColors.navy,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          error: AppColors.rose,
          outline: AppColors.line2,
          outlineVariant: AppColors.line,
        ),
    textTheme: _designTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: AppColors.line,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.navy),
  );
}

void _rebuildAll() {
  void visit(Element e) {
    e.markNeedsBuild();
    e.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.route, required this.navigatorKey});
  final String? route;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  String? route;

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    route = widget.route;
    WidgetsBinding.instance.addObserver(this);
    // Load theme on app startup
    Future.delayed(Duration.zero, () {
      ref.read(themeNotifierProvider.notifier).loadTheme();
      ref.read(textSizeProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final textSize = ref.watch(textSizeProvider);
    ref.watch(connectivityStatusProviders);

    // Resolve the brightness ourselves so AppColors matches the theme.
    final dark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final paletteChanged = AppColors.dark != dark;
    AppColors.dark = dark;
    if (paletteChanged) {
      // Colours are read at build time, so rebuild every element (state and
      // routes are kept).
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig.init(context);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'WellTrust Staff',
                themeMode: ThemeMode.light,
                theme: _welltrustTheme(dark),
                navigatorObservers: [
                  routeObserver,
                ], // 👈 Enables route lifecycle listening
                onGenerateRoute: router.generateRoute,
                initialRoute: route,
                navigatorKey: widget.navigatorKey,
                builder: (BuildContext context, Widget? child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(textSize.scale)),
                    child: Stack(
                      children: [
                        /// ✅ Wrap the content with UpgradeAlert
                        UpgradeAlert(
                          showReleaseNotes: false,
                          dialogStyle: UpgradeDialogStyle.cupertino,
                          upgrader: Upgrader(),
                          child: child!,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
