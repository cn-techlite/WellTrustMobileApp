import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/domain/usercases/visit_repository.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/visit_state.dart';

class VisitController extends AsyncNotifier<VisitState> {
  late final VisitRepository _repository;

  @override
  FutureOr<VisitState> build() async {
    _repository = ref.read(visitRepositoryProvider);
    if (!hasActiveSession) return const VisitState();

    final now = DateTime.now();
    return _loadRange(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day + 1),
    );
  }

  VisitState get _current => state.value ?? const VisitState();

  Future<VisitState> _loadRange(DateTime from, DateTime to) async {
    final visits = await _repository.getVisits(from: from, to: to);
    ref.read(todayRunProvider.notifier).syncVisits(visits);
    return VisitState(visits: visits, rangeStart: from, rangeEnd: to);
  }

  Future<void> refresh({DateTime? from, DateTime? to}) async {
    final now = DateTime.now();
    final start =
        from ?? _current.rangeStart ?? DateTime(now.year, now.month, now.day);
    final end = to ?? _current.rangeEnd ?? start.add(const Duration(days: 1));
    state = const AsyncLoading<VisitState>();
    state = await AsyncValue.guard(() => _loadRange(start, end));
  }

  Future<TodayVisit> getVisit(String id) async {
    final visit = await _repository.getVisit(id: id);
    _replace(visit, selectedVisit: visit);
    return visit;
  }

  Future<bool> clockIn(TodayVisit visit, ClockInDetails details) async {
    final previous = _current;
    try {
      final updated = await _repository.clockIn(
        visitId: visit.id,
        details: details,
      );
      _replace(updated);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> setTask(TodayVisit visit, int index, bool completed) async {
    if (index < 0 || index >= visit.tasks.length) return;
    final task = visit.tasks[index];
    if (task.id.isEmpty) return;
    final updated = await _repository.updateTask(
      visitId: visit.id,
      taskId: task.id,
      completed: completed,
    );
    _replace(updated);
  }

  Future<void> reportIssue(
    String visitId, {
    required String issueType,
    required String details,
  }) => _repository.reportIssue(
    visitId: visitId,
    issueType: issueType,
    details: details,
  );

  Future<bool> clockOut(TodayVisit visit, Set<int> completed) async {
    final previous = _current;
    try {
      final updated = await _repository.clockOut(
        visitId: visit.id,
        completedTasks: [
          for (var i = 0; i < visit.tasks.length; i++)
            if (completed.contains(i)) visit.tasks[i].label,
        ],
        outstandingTasks: [
          for (var i = 0; i < visit.tasks.length; i++)
            if (!completed.contains(i)) visit.tasks[i].label,
        ],
      );
      _replace(updated);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  void _replace(TodayVisit visit, {TodayVisit? selectedVisit}) {
    final current = _current;
    final visits = [...current.visits];
    final index = visits.indexWhere((item) => item.id == visit.id);
    if (index < 0) {
      visits.add(visit);
    } else {
      visits[index] = visit;
    }
    visits.sort((a, b) => a.start.compareTo(b.start));
    ref.read(todayRunProvider.notifier).syncVisits(visits);
    state = AsyncData(
      current.copyWith(visits: visits, selectedVisit: selectedVisit),
    );
  }
}
