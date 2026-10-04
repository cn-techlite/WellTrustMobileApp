import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';

abstract class VisitRepository {
  Future<List<TodayVisit>> getVisits({
    required DateTime from,
    required DateTime to,
  });

  Future<TodayVisit> getVisit({required String id});

  Future<TodayVisit> clockIn({
    required String visitId,
    required ClockInDetails details,
  });

  Future<TodayVisit> updateTask({
    required String visitId,
    required String taskId,
    required bool completed,
  });

  Future<void> reportIssue({
    required String visitId,
    required String issueType,
    required String details,
  });

  Future<TodayVisit> clockOut({
    required String visitId,
    required List<String> completedTasks,
    required List<String> outstandingTasks,
  });
}
