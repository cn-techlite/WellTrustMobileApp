import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_clock_in_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_clock_out_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_issue_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_range_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/visit_task_request.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';

/// Performs only visit-related network requests and response parsing.
class VisitRemoteService {
  final MobileApiClient _api;

  VisitRemoteService({MobileApiClient? api}) : _api = api ?? MobileApiClient();

  Future<List<TodayVisit>> getVisits(VisitRangeRequest request) async => [
    for (final row in _rows(
      await _api.get(Endpoints.rotaUrl, query: request.toQuery()),
    ))
      TodayVisit.fromJson(row),
  ];

  Future<TodayVisit> getVisit(String id) async =>
      TodayVisit.fromJson(_object(await _api.get(Endpoints.visit(id))));

  Future<TodayVisit> clockIn(String id, VisitClockInRequest request) async =>
      TodayVisit.fromJson(
        _object(
          await _api.post(Endpoints.visitClockIn(id), body: request.toJson()),
        ),
      );

  Future<TodayVisit> updateTask(
    String visitId,
    VisitTaskRequest request,
  ) async => TodayVisit.fromJson(
    _object(
      await _api.put(Endpoints.visitTasks(visitId), body: request.toJson()),
    ),
  );

  Future<void> reportIssue(String visitId, VisitIssueRequest request) async {
    await _api.post(Endpoints.visitIssues(visitId), body: request.toJson());
  }

  Future<TodayVisit> clockOut(
    String visitId,
    VisitClockOutRequest request,
  ) async => TodayVisit.fromJson(
    _object(
      await _api.post(Endpoints.visitClockOut(visitId), body: request.toJson()),
    ),
  );

  List<Map<String, dynamic>> _rows(dynamic value) => [
    for (final item in (value is List ? value : const []))
      if (item is Map) Map<String, dynamic>.from(item),
  ];

  Map<String, dynamic> _object(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const MobileApiException(500, 'The server returned invalid data.');
  }
}
