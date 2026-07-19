import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/visit_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/visit_state_model.dart';

List<VisitResponseModel> seedVisits() {
  return [
    VisitResponseModel(
      id: "1",
      suId: "su_1",
      start: "12:00",
      end: "13:00",
      duration: 60,
      type: "Lunch",
      travelMin: 10,
      status: VisitStatus.scheduled,
      tasks: [
        "Lunch prep",
        "Eating support",
        "Lunch meds",
        "Toilet",
        "Bin out",
      ],
    ),
  ];
}

class VisitController extends AsyncNotifier<VisitState> {
  @override
  Future<VisitState> build() async {
    return VisitState(visits: seedVisits());
  }

  String nowHM() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  int minsBetween(String hm1, String hm2) {
    final first = hm1.split(':').map(int.parse).toList();
    final second = hm2.split(':').map(int.parse).toList();

    return (second[0] * 60 + second[1]) - (first[0] * 60 + first[1]);
  }

  int minsUntil(String hm) {
    return minsBetween(nowHM(), hm);
  }

  String liveElapsed(VisitResponseModel visit) {
    if (visit.actualStart == null) return '00:00';

    final start = visit.actualStart!.split(':').map(int.parse).toList();
    final now = DateTime.now();

    final startToday = DateTime(
      now.year,
      now.month,
      now.day,
      start[0],
      start[1],
    );

    var seconds = now.difference(startToday).inSeconds;
    if (seconds < 0) seconds = 0;

    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  VisitResponseModel? visitById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;

    for (final visit in currentState.visits) {
      if (visit.id == id) return visit;
    }

    return null;
  }

  String? startVisit(String visitId) {
    final currentState = state.value;
    if (currentState == null) return 'Visits not loaded';

    final visits = [...currentState.visits];

    final index = visits.indexWhere((visit) => visit.id == visitId);
    if (index == -1) return 'Visit not found';

    final visit = visits[index];

    if (minsUntil(visit.start) > 15) {
      return 'Too early — start becomes available 15 min before scheduled time';
    }

    visit.actualStart = nowHM();
    visit.status = VisitStatus.inProgress;

    state = AsyncData(currentState.copyWith(visits: visits));

    return null;
  }

  int prepareEndVisit(VisitResponseModel visit) {
    visit.actualEnd = nowHM();

    final actualDuration = minsBetween(visit.actualStart!, visit.actualEnd!);

    final currentState = state.value;

    if (currentState != null) {
      state = AsyncData(
        currentState.copyWith(visits: [...currentState.visits]),
      );
    }

    return visit.duration - actualDuration;
  }

  void completeVisit(VisitResponseModel visit, {String? gapReason}) {
    final currentState = state.value;
    if (currentState == null) return;

    visit.status = VisitStatus.complete;

    if (gapReason != null && gapReason.isNotEmpty) {
      visit.gapReason = gapReason;
    }

    state = AsyncData(currentState.copyWith(visits: [...currentState.visits]));
  }

  void cancelEndVisit(VisitResponseModel visit) {
    final currentState = state.value;
    if (currentState == null) return;

    visit.actualEnd = null;

    state = AsyncData(currentState.copyWith(visits: [...currentState.visits]));
  }

  void toggleVisitTask(VisitResponseModel visit, int index) {
    final currentState = state.value;
    if (currentState == null) return;

    if (visit.completedTaskIdx.contains(index)) {
      visit.completedTaskIdx.remove(index);
    } else {
      visit.completedTaskIdx.add(index);
    }

    state = AsyncData(currentState.copyWith(visits: [...currentState.visits]));
  }

  void updateVisitNotes(String visitId, String notes) {
    final currentState = state.value;
    if (currentState == null) return;

    final visits = [...currentState.visits];
    final index = visits.indexWhere((visit) => visit.id == visitId);

    if (index == -1) return;

    visits[index].visitNotes = notes;

    state = AsyncData(currentState.copyWith(visits: visits));
  }

  void toggleClock() {
    final currentState = state.value;
    if (currentState == null) return;

    final newValue = !currentState.isClockedIn;

    state = AsyncData(
      currentState.copyWith(
        isClockedIn: newValue,
        clockedInAt: newValue ? DateTime.now() : null,
        clearClockedInAt: !newValue,
      ),
    );
  }

  void endOfDay() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(isClockedIn: false, clearClockedInAt: true),
    );
  }
}
