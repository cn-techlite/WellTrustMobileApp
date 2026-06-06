// ignore_for_file: use_build_context_synchronously

import 'package:ginilog_customer_app/core/constants/api_constants.dart';
import 'package:ginilog_customer_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:ginilog_customer_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:ginilog_customer_app/shared/state/connectivity_state.dart';
import 'package:ginilog_customer_app/shared/state/theme_state.dart';
import 'package:ginilog_customer_app/core/utils/constants.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:geolocator/geolocator.dart';

import 'core/helpers/globals.dart';
import 'core/routes/routers.dart';
import 'core/utils/package_export.dart';
import 'core/routes/routers.dart' as router;

import 'package:geolocator/geolocator.dart' as positions;

//Store this globally
// Global RouteObserver instance
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final _pushMessagingNotification = getIt<PushNotificationService>();

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
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize();
  getIt.registerLazySingleton<AppGlobals>(() => AppGlobals());
  await setupLocator();
  await FirebaseMessaging.instance.getInitialMessage();
  await _pushMessagingNotification.initialize();
  //Handle Push Notification when app is in background and when app is terminated
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  await globals.init();
  await _refreshSessionOnAppOpen();

  final navigatorKey = GlobalKey<NavigatorState>();
  String? route = await initialRoute();

  runApp(ProviderScope(child: MyApp(route: route, navigatorKey: navigatorKey)));
}

Future<void> _refreshSessionOnAppOpen() async {
  final hasAnySavedSession =
      globals.userId!.isNotEmpty ||
      globals.token!.isNotEmpty ||
      globals.refreshToken.isNotEmpty;

  if (!hasAnySavedSession) return;

  final canRefresh =
      globals.userEmail!.trim().isNotEmpty &&
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.route, required this.navigatorKey});
  final String? route;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String? route;
  positions.Position? _currentPosition;
  String? _currentAddress;
  String? _city;
  String? _state;
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    setState(() {
      route = widget.route;
    });
    // Load theme on app startup
    Future.delayed(Duration.zero, () {
      ref.read(themeNotifierProvider.notifier).loadTheme();
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    positions.LocationPermission permission;

    serviceEnabled = await positions.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location services are disabled. Please enable the services',
          ),
        ),
      );
      return false;
    }
    permission = await positions.Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    // ignore: deprecated_member_use
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((positions.Position position) {
          setState(() => _currentPosition = position);
          _getAddressFromLatLng(_currentPosition!);
        })
        .catchError((e) {
          debugPrint(e);
        });
  }

  Future<void> _getAddressFromLatLng(positions.Position position) async {
    await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        )
        .then((List<Placemark> placemarks) async {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress =
                '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
            _city = "${place.subAdministrativeArea}";
            _state = "${place.administrativeArea}";
          });
          await globals.init();
          printData("Location", _currentAddress!);
          printData("Latitude", _currentPosition!.latitude);
          printData("Longitude", _currentPosition!.longitude);
          printData("City", _city);
          printData("State", _state);
        })
        .catchError((e) {
          debugPrint(e);
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    ref.watch(connectivityStatusProviders);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig.init(context);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Ginilog',
                themeMode: themeMode,
                theme: ThemeData.light(), // Light theme
                darkTheme: ThemeData.dark(), // Dark theme
                navigatorObservers: [
                  routeObserver,
                ], // 👈 Enables route lifecycle listening
                onGenerateRoute: router.generateRoute,
                initialRoute: route,
                navigatorKey: widget.navigatorKey,
                builder: (BuildContext context, Widget? child) {
                  return Stack(
                    children: [
                      /// ✅ Wrap the content with UpgradeAlert
                      UpgradeAlert(
                        showReleaseNotes: false,
                        dialogStyle: UpgradeDialogStyle.cupertino,
                        upgrader: Upgrader(),
                        child: child!,
                      ),
                    ],
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
