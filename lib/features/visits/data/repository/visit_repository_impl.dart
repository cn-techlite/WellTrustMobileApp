import 'package:well_trust_mobile_app/features/visits/data/dto/visit_clock_in_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_clock_out_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_issue_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_range_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_task_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/data/service/visit_remote_service.dart';
import 'package:well_trust_mobile_app/features/visits/domain/usercases/visit_repository.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteService _remoteService;

  const VisitRepositoryImpl({required VisitRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<TodayVisit>> getVisits({
    required DateTime from,
    required DateTime to,
  }) => _remoteService.getVisits(VisitRangeRequest(from: from, to: to));

  @override
  Future<TodayVisit> getVisit({required String id}) =>
      _remoteService.getVisit(id);

  @override
  Future<TodayVisit> clockIn({
    required String visitId,
    required ClockInDetails details,
  }) => _remoteService.clockIn(visitId, VisitClockInRequest(details: details));

  @override
  Future<TodayVisit> updateTask({
    required String visitId,
    required String taskId,
    required bool completed,
  }) => _remoteService.updateTask(
    visitId,
    VisitTaskRequest(taskId: taskId, completed: completed),
  );

  @override
  Future<void> reportIssue({
    required String visitId,
    required String issueType,
    required String details,
  }) => _remoteService.reportIssue(
    visitId,
    VisitIssueRequest(issueType: issueType, details: details),
  );

  @override
  Future<TodayVisit> clockOut({
    required String visitId,
    required List<String> completedTasks,
    required List<String> outstandingTasks,
  }) => _remoteService.clockOut(
    visitId,
    VisitClockOutRequest(
      at: DateTime.now(),
      completedTasks: completedTasks,
      outstandingTasks: outstandingTasks,
    ),
  );
}
