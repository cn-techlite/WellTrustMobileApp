import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/domain/usercases/visit_repository.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';

TodayVisit _visit({String status = 'Scheduled'}) => TodayVisit(
  id: 'visit-1',
  clientId: 'client-1',
  name: 'Test Client',
  preferred: 'Client',
  address: '',
  phone: '',
  start: DateTime(2026, 10, 1, 9),
  minutes: 30,
  travelMins: 0,
  type: 'Care',
  accessType: '',
  accessCode: '',
  accessNote: '',
  thingsToKnow: const [],
  tasks: const [
    VisitTask('Breakfast', id: 'task-1'),
    VisitTask('Medication', id: 'task-2', medication: true),
  ],
  status: status,
);

class _FakeVisitRepository implements VisitRepository {
  DateTime? requestedFrom;
  DateTime? requestedTo;
  List<String> completedTasks = const [];
  List<String> outstandingTasks = const [];

  @override
  Future<List<TodayVisit>> getVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    requestedFrom = from;
    requestedTo = to;
    return [_visit()];
  }

  @override
  Future<TodayVisit> getVisit({required String id}) async => _visit();

  @override
  Future<TodayVisit> clockIn({
    required String visitId,
    required ClockInDetails details,
  }) async => _visit(status: 'InProgress');

  @override
  Future<TodayVisit> updateTask({
    required String visitId,
    required String taskId,
    required bool completed,
  }) async => _visit();

  @override
  Future<void> reportIssue({
    required String visitId,
    required String issueType,
    required String details,
  }) async {}

  @override
  Future<TodayVisit> clockOut({
    required String visitId,
    required List<String> completedTasks,
    required List<String> outstandingTasks,
  }) async {
    this.completedTasks = completedTasks;
    this.outstandingTasks = outstandingTasks;
    return _visit(status: 'Completed');
  }
}

void main() {
  test('visit controller loads ranges through the repository', () async {
    final repository = _FakeVisitRepository();
    final container = ProviderContainer(
      overrides: [visitRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(visitControllerProvider.future);
    final from = DateTime(2026, 10, 1);
    final to = DateTime(2026, 10, 8);
    await container
        .read(visitControllerProvider.notifier)
        .refresh(from: from, to: to);

    final state = container.read(visitControllerProvider).requireValue;
    expect(repository.requestedFrom, from);
    expect(repository.requestedTo, to);
    expect(state.visits.single.id, 'visit-1');
    expect(state.rangeStart, from);
    expect(state.rangeEnd, to);
  });

  test('clock out separates completed and outstanding task labels', () async {
    final repository = _FakeVisitRepository();
    final container = ProviderContainer(
      overrides: [visitRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(visitControllerProvider.future);
    await container.read(visitControllerProvider.notifier).clockOut(_visit(), {
      0,
    });

    expect(repository.completedTasks, ['Breakfast']);
    expect(repository.outstandingTasks, ['Medication']);
    expect(
      container
          .read(visitControllerProvider)
          .requireValue
          .visits
          .single
          .isCompleted,
      isTrue,
    );
  });
}
