import 'package:well_trust_mobile_app/core/services/location_service.dart';

/// Information captured by the clock-in form before it becomes an API body.
class ClockInDetails {
  final DateTime at;
  final bool? atClientHome;
  final String? earlyReason;
  final LocationFix? location;
  final double? distanceFromClientMetres;
  final bool flaggedTooFarFromClient;

  const ClockInDetails({
    required this.at,
    this.atClientHome,
    this.earlyReason,
    this.location,
    this.distanceFromClientMetres,
    this.flaggedTooFarFromClient = false,
  });

  String? get timingReason => earlyReason;
  bool get hasLocation => location != null;
}
