import 'package:well_trust_mobile_app/core/services/location_service.dart';

/// What the carer told us, and where the phone was, when they clocked in.
class ClockInDetails {
  final DateTime at;

  /// What the carer said about where they are. Null when the phone could not
  /// give a location and they clocked in without one.
  final bool? atClientHome;

  /// Why they started outside the on-time tolerance. The legacy field name is
  /// retained for stored-data compatibility; it can describe an early or late
  /// start.
  final String? earlyReason;

  String? get timingReason => earlyReason;

  /// The phone's position at the moment of clock-in.
  final LocationFix? location;

  /// How far the phone was from the client's address, when both were known.
  final double? distanceFromClientMetres;

  /// True when the carer said they were at the client's home but the phone
  /// was too far away, and they chose to clock in anyway.
  final bool flaggedTooFarFromClient;

  const ClockInDetails({
    required this.at,
    this.atClientHome,
    this.earlyReason,
    this.location,
    this.distanceFromClientMetres,
    this.flaggedTooFarFromClient = false,
  });

  bool get hasLocation => location != null;
}
