// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:ui';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/account.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/screen/handover_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/provider/handover_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/visit_screen.dart';
import 'package:well_trust_mobile_app/features/home/presentation/screen/home.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/screen/notes_screen.dart';
import 'package:geolocator/geolocator.dart' as positions;
import 'package:geolocator/geolocator.dart';

import '../core/utils/colors.dart';
import '../core/utils/package_export.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class HomeScreenPage extends ConsumerStatefulWidget {
  const HomeScreenPage({super.key, required this.imdex});
  final int imdex;
  @override
  _NavBarfeaturestate createState() => _NavBarfeaturestate();
}

class _NavBarfeaturestate extends ConsumerState<HomeScreenPage> {
  int _currentIndex = 0;
  String? _currentAddress;
  String? _city;
  String? _state;
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    setState(() {
      _currentIndex = widget.imdex;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    final serviceEnabled =
        await positions.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationMessage(
        'Location services are disabled. Please enable the services',
      );
      return false;
    }

    var permission = await positions.Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationMessage('Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showLocationMessage(
        'Location permissions are permanently denied. Enable them in settings.',
      );
      return false;
    }
    return true;
  }

  void _showLocationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _getCurrentPosition() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      await _getAddressFromLatLng(position);
    } catch (error, stackTrace) {
      debugPrint('Unable to get the current location: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showLocationMessage('Unable to access your current location');
    }
  }

  Future<void> _getAddressFromLatLng(positions.Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted || placemarks.isEmpty) return;

      final place = placemarks.first;
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        _city = place.subAdministrativeArea;
        _state = place.administrativeArea;
      });
      await globals.init();
      printData("Location", _currentAddress!);
      printData("Latitude", position.latitude);
      printData("Longitude", position.longitude);
      printData("City", _city);
      printData("State", _state);
    } catch (error, stackTrace) {
      debugPrint('Unable to resolve the current address: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  int tabselected = 0;

  Future<bool> _onPopInvoked(bool isPop, pop) async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return (await showDialog(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AlertDialog(
              title: Text(
                'Exit App',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Do you want to exit the app?',
                style: TextStyle(color: AppColors.primary),
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Yes', style: TextStyle(color: AppColors.ink)),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                ),
                TextButton(
                  child: Text('No', style: TextStyle(color: AppColors.primary)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      HomeScreen(onOpenVisits: () => onTabTapped(1)),
      const VisitsScreen(),
      const HandoverScreen(),
      const NotesScreen(),
      const AccountPage(),
    ];
    return Consumer(
      builder: (context, WidgetRef ref, Widget? child) {
        return PopScope(
          onPopInvokedWithResult: _onPopInvoked,
          canPop: false,
          child: Scaffold(
            backgroundColor: AppColors.bg,
            body: children[_currentIndex],
            bottomNavigationBar: _buildNavBar(),
          ),
        );
      },
    );
  }

  Widget _buildNavBar() {
    const items = [
      (Icons.wb_sunny_outlined, 'Today'),
      (Icons.calendar_today_outlined, 'Visits'),
      (Icons.swap_horiz_rounded, 'Handover'),
      (Icons.edit_outlined, 'Notes'),
      (Icons.more_horiz_rounded, 'More'),
    ];
    final unreadHandover = ref.watch(handoverProvider).unreadTotal;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = _currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => onTabTapped(i),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.goldBg
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Badge(
                            isLabelVisible: i == 2 && unreadHandover > 0,
                            label: Text('$unreadHandover'),
                            backgroundColor: AppColors.rose,
                            child: Icon(
                              items[i].$1,
                              size: 22,
                              color: selected
                                  ? AppColors.goldDeep
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Source Sans 3',
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.ink : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
