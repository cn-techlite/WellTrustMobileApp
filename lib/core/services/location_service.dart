import 'package:geolocator/geolocator.dart';

/// Where the phone was when it was asked.
class LocationFix {
  final double latitude;
  final double longitude;

  /// How far off the fix could be, in metres.
  final double accuracy;
  final DateTime capturedAt;

  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
  });
}

enum LocationProblem { serviceOff, denied, deniedForever, unavailable }

/// Why a location could not be read, in words a carer can act on.
class LocationException implements Exception {
  final LocationProblem problem;

  const LocationException(this.problem);

  String get message => switch (problem) {
    LocationProblem.serviceOff =>
      'Location is switched off on this phone. Turn it on, then try again.',
    LocationProblem.denied =>
      'WellTrust needs your location to clock you in. Allow it, then try again.',
    LocationProblem.deniedForever =>
      'Location is blocked for WellTrust. Allow it in Settings, then try again.',
    LocationProblem.unavailable =>
      'We could not find your location. Move near a window or outside, then try again.',
  };

  /// True when only the carer can fix it, in the phone's Settings.
  bool get needsSettings =>
      problem == LocationProblem.serviceOff ||
      problem == LocationProblem.deniedForever;

  @override
  String toString() => message;
}

/// Reads the phone's location for a clock-in.
///
/// Anything that needs a position takes a [LocationService] so tests can swap
/// in a fake one.
class LocationService {
  const LocationService();

  /// Asks for permission if needed, then reads the position once.
  /// Throws a [LocationException] when that is not possible.
  Future<LocationFix> currentFix() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceOff);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied);
    }

    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return LocationFix(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracy: p.accuracy,
        capturedAt: p.timestamp,
      );
    } catch (_) {
      throw const LocationException(LocationProblem.unavailable);
    }
  }

  /// Opens this app's page in the phone's Settings.
  Future<void> openSettings(LocationException e) async {
    if (e.problem == LocationProblem.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  /// Straight-line distance between two points, in metres.
  static double distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) => Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
}

/// "62 m" or "1.3 km".
String formatDistance(double metres) {
  if (metres < 1000) return '${metres.round()} m';
  return '${(metres / 1000).toStringAsFixed(1)} km';
}
