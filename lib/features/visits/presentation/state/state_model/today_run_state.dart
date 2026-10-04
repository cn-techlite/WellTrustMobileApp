import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';

/// Local UI state derived from visit records returned by the backend.
class TodayRun {
  final Map<String, DateTime> clockedIn;
  final Map<String, DateTime> clockedOut;
  final Set<String> finished;
  final Map<String, ClockInDetails> details;
  final Map<String, Set<int>> completedTasks;

  const TodayRun({
    this.clockedIn = const {},
    this.clockedOut = const {},
    this.finished = const {},
    this.details = const {},
    this.completedTasks = const {},
  });

  int completedTaskCount(String id) => completedTasks[id]?.length ?? 0;

  String? get activeVisitId {
    for (final id in clockedIn.keys) {
      if (!finished.contains(id)) return id;
    }
    return null;
  }

  TodayVisitState stateOf(TodayVisit visit, DateTime now) {
    if (finished.contains(visit.id)) return TodayVisitState.done;
    if (clockedIn.containsKey(visit.id)) return TodayVisitState.active;
    if (now.isAfter(visit.end)) return TodayVisitState.overdue;
    if (!now.isBefore(visit.start.subtract(const Duration(minutes: 15)))) {
      return TodayVisitState.due;
    }
    return TodayVisitState.upcoming;
  }

  TodayVisit? focus(List<TodayVisit> visits, DateTime now) {
    for (final visit in visits) {
      if (stateOf(visit, now) == TodayVisitState.active) return visit;
    }
    for (final visit in visits) {
      final visitState = stateOf(visit, now);
      if (visitState == TodayVisitState.overdue &&
          now.difference(visit.end) < const Duration(hours: 12)) {
        return visit;
      }
      if (visitState == TodayVisitState.due ||
          visitState == TodayVisitState.upcoming) {
        return visit;
      }
    }
    return null;
  }
}
