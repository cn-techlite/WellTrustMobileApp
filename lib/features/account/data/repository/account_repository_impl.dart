import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/data/services/account_remote_services.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteService remoteService;

  AccountRepositoryImpl(this.remoteService);

  @override
  Future<RegisterResponseModel> getUserData() {
    return remoteService.getUserData();
  }

  /// The API answers with the saved record. Some errors are plain text, so a
  /// body that is not a JSON object is not treated as a failure.
  Map<String, dynamic>? _decodeMap(String body) {
    try {
      final decoded = json.decode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  GeneralResultModel _result(
    http.Response response, {
    required String successMessage,
  }) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return GeneralResultModel.success(
        rawData: response.body,
        message: successMessage,
        data: _decodeMap(response.body),
      );
    }
    if (response.statusCode == 403) {
      return GeneralResultModel.failure("You can only change your own record.");
    }
    return GeneralResultModel.failure(
      getErrorMessageFromResponse(response.statusCode, response.body),
    );
  }

  @override
  Future<GeneralResultModel> updateProfile(UpdateStaffRequest request) async {
    final response = await remoteService.updateProfile(request);
    return _result(response, successMessage: "Details updated successfully");
  }

  @override
  Future<GeneralResultModel> saveStaffRecord(
    StaffRecordRequest request, {
    required String adminStaffId,
  }) async {
    final response = await remoteService.saveStaffRecord(
      request,
      adminStaffId: adminStaffId,
    );
    // A carer can add their right to work record once. After that the API
    // refuses any change from them, whoever the record is for.
    if (response.statusCode == 403 &&
        request.kind == StaffRecordKind.compliance) {
      return GeneralResultModel.failure(
        "Your right to work record is already on file. Only the office can change it now.",
      );
    }
    return _result(
      response,
      successMessage: "${request.kind.label} saved successfully",
    );
  }

  @override
  Future<GeneralResultModel> updateStaffRecord(
    String id,
    StaffRecordRequest request,
  ) async {
    final response = await remoteService.updateStaffRecord(id, request);
    return _result(
      response,
      successMessage: "${request.kind.label} updated successfully",
    );
  }

  @override
  Future<GeneralResultModel> deleteStaffRecord(
    StaffRecordKind kind,
    String id,
  ) async {
    final response = await remoteService.deleteStaffRecord(kind, id);
    return _result(
      response,
      successMessage: "${kind.label} deleted successfully",
    );
  }

  @override
  Future<GeneralResultModel> sendReferenceRequest(String id) async {
    final response = await remoteService.sendReferenceRequest(id);
    if (response.statusCode == 502) {
      return GeneralResultModel.failure(
        "The email could not be sent. Please try again later.",
      );
    }
    return _result(response, successMessage: "Request sent to the referee");
  }

  @override
  Future<List<StaffReference>> getReferences(String staffId) async => [
    for (final j in await remoteService.getStaffRecords(
      StaffRecordKind.references.segment,
      staffId,
    ))
      StaffReference.fromJson(j),
  ];

  @override
  Future<List<StaffSupervision>> getSupervisions(String staffId) async => [
    for (final j in await remoteService.getStaffRecords(
      'supervisions',
      staffId,
    ))
      StaffSupervision.fromJson(j),
  ];

  @override
  Future<List<StaffProbation>> getProbation(String staffId) async {
    // The docs list this route as both probation and probations.
    final rows = await remoteService.getStaffRecords(
      'probation',
      staffId,
      fallbackSegment: 'probations',
    );
    return [for (final j in rows) StaffProbation.fromJson(j)];
  }

  @override
  Future<List<StaffDeclaration>> getDeclarations(String staffId) async => [
    for (final j in await remoteService.getStaffRecords(
      'declarations',
      staffId,
    ))
      StaffDeclaration.fromJson(j),
  ];

  @override
  Future<GeneralResultModel> sendFeedBack({
    required String feedback,
    required String phoneNo,
  }) async {
    final response = await remoteService.sendFeedBack(
      feedback: feedback,
      phoneNo: phoneNo,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Feedback sent successfully",
        data: data,
      );
    }
    return GeneralResultModel.failure(errorMessage);
  }
}
