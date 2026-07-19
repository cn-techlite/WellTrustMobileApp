import 'package:well_trust_mobile_app/features/visits/data/model/visit_response_model.dart';

class VisitState {
  final List<VisitResponseModel> visits;
  final bool isClockedIn;
  final DateTime? clockedInAt;

  const VisitState({
    required this.visits,
    this.isClockedIn = false,
    this.clockedInAt,
  });

  VisitState copyWith({
    List<VisitResponseModel>? visits,
    bool? isClockedIn,
    DateTime? clockedInAt,
    bool clearClockedInAt = false,
  }) {
    return VisitState(
      visits: visits ?? this.visits,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      clockedInAt: clearClockedInAt ? null : clockedInAt ?? this.clockedInAt,
    );
  }

  VisitResponseModel? get nextScheduledVisit {
    final scheduled = visits
        .where((v) => v.status == VisitStatus.scheduled)
        .toList();
    return scheduled.isEmpty ? null : scheduled.first;
  }

  VisitResponseModel? get currentVisit {
    for (final visit in visits) {
      if (visit.status == VisitStatus.inProgress) return visit;
    }
    return null;
  }

  int get visitsDone =>
      visits.where((visit) => visit.status == VisitStatus.complete).length;

  int get visitsInProgress =>
      visits.where((visit) => visit.status == VisitStatus.inProgress).length;

  int get visitsToGo => visits.length - visitsDone - visitsInProgress;

  int get totalScheduledMins =>
      visits.fold(0, (total, visit) => total + visit.duration);

  int get totalTravelMins =>
      visits.fold(0, (total, visit) => total + visit.travelMin);
}
