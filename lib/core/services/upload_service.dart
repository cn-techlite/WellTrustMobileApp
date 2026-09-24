import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';

/// The folders the server files uploads under. Anything else, or leaving it
/// out, silently lands in `files`, so it is an enum rather than a string.
enum UploadFolder { images, videos, cvs, documents, certificates, files }

/// Why an upload failed, in words that can be shown to the carer.
class UploadException implements Exception {
  final String message;

  const UploadException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  /// POST upload-files/upload-web-server. The file goes in a field called
  /// `Image` whatever its type (a photo, a PDF...); a field called `file` is
  /// ignored by the server. Returns the URL of the stored file.
  ///
  /// Throws [UploadException] when the upload fails.
  static Future<String> upload(
    String file, {
    UploadFolder folder = UploadFolder.images,
  }) async {
    final url = Uri.parse("${Endpoints.baseUrl}${Endpoints.uploadUrl}");
    printData('Upload Url', url.toString());

    try {
      // No Content-Type here: the request adds its own with the boundary.
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.token}',
        })
        ..fields['Folder'] = folder.name
        ..files.add(await http.MultipartFile.fromPath('Image', file));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        printData('Upload Response', data);
        final imageUrl = data is Map ? data['imageUrl']?.toString() : null;
        if (imageUrl == null || imageUrl.isEmpty) {
          throw const UploadException('The server did not return the file.');
        }
        return imageUrl;
      }

      printData('Upload Error', '${response.statusCode} ${response.body}');
      if (response.statusCode == 401) {
        throw const UploadException(
          'Your sign in has expired. Please sign in again.',
        );
      }
      throw UploadException(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } on UploadException {
      rethrow;
    } catch (e) {
      printData('Upload Catch Error', e.toString());
      throw UploadException(handleHttpError(e));
    }
  }
}
