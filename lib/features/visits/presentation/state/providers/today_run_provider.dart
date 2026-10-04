import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/today_run_state.dart';

class TodayRunNotifier extends Notifier<TodayRun> {
  @override
  TodayRun build() => const TodayRun();

  void syncVisits(List<TodayVisit> visits) {
    final clockedIn = <String, DateTime>{};
    final clockedOut = <String, DateTime>{};
    final finished = <String>{};
    final completedTasks = <String, Set<int>>{};
    for (final visit in visits) {
      if (visit.checkInAt != null) clockedIn[visit.id] = visit.checkInAt!;
      if (visit.checkOutAt != null) clockedOut[visit.id] = visit.checkOutAt!;
      if (visit.isCompleted) finished.add(visit.id);
      completedTasks[visit.id] = {
        for (var i = 0; i < visit.tasks.length; i++)
          if (visit.tasks[i].completed) i,
      };
    }
    state = TodayRun(
      clockedIn: clockedIn,
      clockedOut: clockedOut,
      finished: finished,
      details: state.details,
      completedTasks: completedTasks,
    );
  }

  bool clockIn(String id, {ClockInDetails? details}) {
    if (state.clockedIn.containsKey(id)) return true;
    final active = state.activeVisitId;
    if (active != null && active != id) return false;
    state = TodayRun(
      clockedIn: {...state.clockedIn, id: details?.at ?? DateTime.now()},
      clockedOut: state.clockedOut,
      finished: state.finished,
      details: {...state.details, id: ?details},
      completedTasks: state.completedTasks,
    );
    return true;
  }

  void setCompletedTasks(String id, Set<int> tasks) {
    state = TodayRun(
      clockedIn: state.clockedIn,
      clockedOut: state.clockedOut,
      finished: state.finished,
      details: state.details,
      completedTasks: {...state.completedTasks, id: Set.unmodifiable(tasks)},
    );
  }

  void finish(String id) {
    state = TodayRun(
      clockedIn: state.clockedIn,
      clockedOut: {...state.clockedOut, id: DateTime.now()},
      finished: {...state.finished, id},
      details: state.details,
      completedTasks: state.completedTasks,
    );
  }
}

final todayRunProvider = NotifierProvider<TodayRunNotifier, TodayRun>(
  TodayRunNotifier.new,
);
