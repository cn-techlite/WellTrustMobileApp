import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';

class VisitState {
  final List<TodayVisit> visits;
  final TodayVisit? selectedVisit;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const VisitState({
    this.visits = const [],
    this.selectedVisit,
    this.rangeStart,
    this.rangeEnd,
  });

  VisitState copyWith({
    List<TodayVisit>? visits,
    TodayVisit? selectedVisit,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) => VisitState(
    visits: visits ?? this.visits,
    selectedVisit: selectedVisit ?? this.selectedVisit,
    rangeStart: rangeStart ?? this.rangeStart,
    rangeEnd: rangeEnd ?? this.rangeEnd,
  );
}
