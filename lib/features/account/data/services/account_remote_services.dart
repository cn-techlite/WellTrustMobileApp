import 'dart:convert';
import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:http/http.dart' as http;
import '../../../../core/helpers/endpoints.dart';
import '../../../../core/helpers/globals.dart';
import '../../../../core/utils/constants.dart';

import '../dto/staff_requests.dart';
import '../model/user_response_model.dart';

/// The message from an [Exception] this service threw on purpose, without the
/// "Exception: " prefix, or the usual network wording for anything else.
String _readable(Object e) {
  final text = e.toString();
  return e is Exception && text.startsWith('Exception: ')
      ? text.substring('Exception: '.length)
      : handleHttpError(e);
}

class AccountRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<RegisterResponseModel> getUserData() async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.usersUrl}/profile",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = RegisterResponseModel.fromJson(jsonDecode(response.body));

        printData('User Data', response.body);
        return data;
      }

      printData('User Data Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('User Data Catch Error', e.toString());
      return Future.error(_readable(e));
    }
  }

  /// PUT admin-users/update. Edits the caller's own core details.
  Future<http.Response> updateProfile(UpdateStaffRequest request) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.userUpdate}");

      final response = await http.put(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Update Profile Response", response.body);
      printData("Update Profile Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Update Profile Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Uri _recordUrl(StaffRecordKind kind, [String? id]) => Uri.parse(
    "${Endpoints.baseUrl}${Endpoints.staffRecordsUrl}/${kind.segment}${id == null ? '' : '/$id'}",
  );

  /// POST admin-staff-records/{kind}. Adds a list record, or sets a
  /// one-per-person record (job details, emergency contact) for the first time
  /// or again. The API only accepts the caller's own `adminStaffId`.
  Future<http.Response> saveStaffRecord(
    StaffRecordRequest request, {
    required String adminStaffId,
  }) async {
    try {
      final response = await http.post(
        _recordUrl(request.kind),
        body: jsonEncode({"adminStaffId": adminStaffId, ...request.toJson()}),
        headers: _headers,
      );
      printData("Save ${request.kind.label} Response", response.body);
      printData("Save ${request.kind.label} Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Save ${request.kind.label} Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  /// PUT admin-staff-records/{kind}/{id}. The record's own id is all the API
  /// needs, it works out who owns it.
  Future<http.Response> updateStaffRecord(
    String id,
    StaffRecordRequest request,
  ) async {
    try {
      final response = await http.put(
        _recordUrl(request.kind, id),
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Update ${request.kind.label} Response", response.body);
      printData(
        "Update ${request.kind.label} Status Code",
        response.statusCode,
      );
      return response;
    } catch (e) {
      printData('Update ${request.kind.label} Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  /// DELETE admin-staff-records/{kind}/{id}.
  Future<http.Response> deleteStaffRecord(
    StaffRecordKind kind,
    String id,
  ) async {
    try {
      final response = await http.delete(
        _recordUrl(kind, id),
        headers: _headers,
      );
      printData("Delete ${kind.label} Response", response.body);
      printData("Delete ${kind.label} Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Delete ${kind.label} Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  /// GET admin-staff-records/{segment}/staff/{staffId}: the carer's own
  /// records in one area, as a list. Some areas answer with one object and an
  /// area nobody has written to yet answers 404, so both are normalised: a
  /// single object becomes a one-item list and a 404 becomes an empty list.
  Future<List<Map<String, dynamic>>> getStaffRecords(
    String segment,
    String staffId, {
    String? fallbackSegment,
  }) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}${Endpoints.staffRecordsUrl}/$segment/staff/$staffId",
      );
      final response = await http.get(url, headers: _headers);
      printData("Get $segment Status Code", response.statusCode);

      // 204 means the office has nothing on file for this person.
      if (response.statusCode == 204) return const [];
      if (response.statusCode == 404) {
        // Some routes are documented under two names; try the other one.
        if (fallbackSegment != null) {
          return await getStaffRecords(fallbackSegment, staffId);
        }
        return const [];
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) return const [];
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return [
            for (final x in decoded)
              if (x is Map<String, dynamic>) x,
          ];
        }
        return decoded is Map<String, dynamic> ? [decoded] : const [];
      }
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Get $segment Catch Error', e.toString());
      return Future.error(_readable(e));
    }
  }

  /// POST admin-staff-records/references/{id}/send-request. Emails the referee
  /// a link to the reference portal and marks the reference as requested.
  Future<http.Response> sendReferenceRequest(String id) async {
    try {
      final response = await http.post(
        _recordUrl(StaffRecordKind.references, '$id/send-request'),
        headers: _headers,
      );
      printData("Send Reference Request Response", response.body);
      printData("Send Reference Request Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Send Reference Request Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> sendFeedBack({
    required String feedback,
    required String phoneNo,
  }) async {
    try {
      var stingUrl = Uri.parse("${Endpoints.baseUrl}info/feedback");

      final msg = jsonEncode({
        "name": globals.userName,
        "email": globals.userEmail,
        "feedback": feedback,
        "phoneNo": phoneNo,
      });
      http.Response response = await http.post(
        stingUrl,
        body: msg,
        headers: _headers,
      );

      printData("Send Feedback Response", response.body);
      printData("Send Feedback Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Send Feedback Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }
}
