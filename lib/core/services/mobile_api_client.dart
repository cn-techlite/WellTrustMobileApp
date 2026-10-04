import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';

class MobileApiException implements Exception {
  final int statusCode;
  final String message;

  const MobileApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Small authenticated client shared by the mobile-care feature services.
/// Feature models and endpoint-specific payloads remain in their own layers.
class MobileApiClient {
  final http.Client _client;

  MobileApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $activeAccessToken',
  };

  Uri _uri(String path, [Map<String, String?> query = const {}]) {
    final uri = Uri.parse('${Endpoints.baseUrl}$path');
    final values = <String, String>{
      for (final entry in query.entries)
        if ((entry.value ?? '').isNotEmpty) entry.key: entry.value!,
    };
    return values.isEmpty ? uri : uri.replace(queryParameters: values);
  }

  Future<dynamic> get(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    final uri = _uri(path, query);
    return _send('GET', uri, () => _client.get(uri, headers: _headers));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    return _send(
      'POST',
      uri,
      () => _client.post(
        uri,
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = _uri(path);
    return _send(
      'PUT',
      uri,
      () => _client.put(
        uri,
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> _send(
    String method,
    Uri uri,
    Future<http.Response> Function() request,
  ) async {
    final requestLabel = '$method $uri';
    return _decode(await request(), requestLabel: requestLabel);
  }

  dynamic _decode(http.Response response, {String? requestLabel}) {
    final request = response.request;
    final label =
        requestLabel ??
        (request == null ? 'API' : '${request.method} ${request.url}');
    printData('$label Response', response.body);
    printData('$label Status Code', response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MobileApiException(
        response.statusCode,
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    }
    if (response.statusCode == 204 || response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const MobileApiException(500, 'The server returned invalid data.');
    }
  }
}
