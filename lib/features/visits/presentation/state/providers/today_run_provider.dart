import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';

/// Which of today's visits the carer has clocked in to, and finished.
class TodayRun {
  final Map<String, DateTime> clockedIn;
  final Set<String> finished;

  /// What was recorded at each clock-in: the reason for an early start and
  /// where the phone was.
  final Map<String, ClockInDetails> details;

  /// Completed care-plan task indexes for each visit.
  final Map<String, Set<int>> completedTasks;

  const TodayRun({
    this.clockedIn = const {},
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

  TodayVisitState stateOf(TodayVisit v, DateTime now) {
    if (finished.contains(v.id)) return TodayVisitState.done;
    if (clockedIn.containsKey(v.id)) return TodayVisitState.active;
    if (now.isAfter(v.end)) return TodayVisitState.overdue;
    if (!now.isBefore(v.start.subtract(const Duration(minutes: 15)))) {
      return TodayVisitState.due;
    }
    return TodayVisitState.upcoming;
  }

  /// The visit to show first: one in progress, else the next one not yet done.
  TodayVisit? focus(List<TodayVisit> visits, DateTime now) {
    for (final v in visits) {
      if (stateOf(v, now) == TodayVisitState.active) return v;
    }
    for (final v in visits) {
      final s = stateOf(v, now);
      if (s == TodayVisitState.overdue &&
          now.difference(v.end) < const Duration(hours: 12)) {
        return v;
      }
      if (s == TodayVisitState.due || s == TodayVisitState.upcoming) return v;
    }
    return null;
  }
}

class TodayRunNotifier extends Notifier<TodayRun> {
  @override
  TodayRun build() => const TodayRun();

  bool clockIn(String id, {ClockInDetails? details}) {
    if (state.clockedIn.containsKey(id)) return true;
    final active = state.activeVisitId;
    if (active != null && active != id) return false;
    state = TodayRun(
      clockedIn: {...state.clockedIn, id: details?.at ?? DateTime.now()},
      finished: state.finished,
      details: {...state.details, id: ?details},
      completedTasks: state.completedTasks,
    );
    return true;
  }

  void setCompletedTasks(String id, Set<int> tasks) {
    state = TodayRun(
      clockedIn: state.clockedIn,
      finished: state.finished,
      details: state.details,
      completedTasks: {...state.completedTasks, id: Set.unmodifiable(tasks)},
    );
  }

  void finish(String id) {
    state = TodayRun(
      clockedIn: state.clockedIn,
      finished: {...state.finished, id},
      details: state.details,
      completedTasks: state.completedTasks,
    );
  }
}

final todayRunProvider = NotifierProvider<TodayRunNotifier, TodayRun>(
  TodayRunNotifier.new,
);
