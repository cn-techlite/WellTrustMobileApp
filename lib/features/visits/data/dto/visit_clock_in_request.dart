import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';

/// Body for POST /api/mobile/visits/{id}/clock-in.
class VisitClockInRequest {
  final ClockInDetails details;

  const VisitClockInRequest({required this.details});

  Map<String, dynamic> toJson() => {
    'at': details.at.toIso8601String(),
    'atClientHome': details.atClientHome,
    'timingReason': details.timingReason,
    'latitude': details.location?.latitude,
    'longitude': details.location?.longitude,
    'accuracyMetres': details.location?.accuracy,
    'distanceFromClientMetres': details.distanceFromClientMetres,
  };
}
