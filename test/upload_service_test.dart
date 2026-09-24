import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/services/upload_service.dart';

class _Sent {
  late http.BaseRequest request;
  late String body;
}

/// Runs [body] with the server answering [status] and [reply], and reports
/// what the app sent.
Future<_Sent> _upload(
  int status,
  String reply,
  Future<void> Function() body,
) async {
  final sent = _Sent();
  final client = MockClient.streaming((request, bodyStream) async {
    sent.request = request;
    sent.body = latin1.decode(await bodyStream.toBytes());
    return http.StreamedResponse(
      Stream.value(utf8.encode(reply)),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
  await http.runWithClient(body, () => client);
  return sent;
}

void main() {
  late File file;

  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
    globals.token = 'test-token';
    file = File('${Directory.systemTemp.path}/welltrust_upload_test.jpg')
      ..writeAsBytesSync(utf8.encode('fake image bytes'));
  });

  tearDownAll(() {
    if (file.existsSync()) file.deleteSync();
  });

  test('posts to upload-files with the file as Image and the folder', () async {
    late String url;
    final sent = await _upload(
      200,
      '{"imageUrl":"https://host/uploads/documents/abc.jpg"}',
      () async {
        url = await ApiService.upload(
          file.path,
          folder: UploadFolder.documents,
        );
      },
    );

    expect(url, 'https://host/uploads/documents/abc.jpg');
    expect(sent.request.method, 'POST');
    expect(
      sent.request.url.path,
      endsWith('api/upload-files/upload-web-server'),
    );
    expect(sent.request.url.path, isNot(contains('upload-file/')));
    expect(sent.request.headers['Authorization'], 'Bearer test-token');
    expect(sent.request.headers['content-type'], contains('boundary='));
    expect(sent.body, contains('name="Image"'));
    expect(sent.body, contains('filename="welltrust_upload_test.jpg"'));
    expect(sent.body, contains('fake image bytes'));
    expect(sent.body, contains('name="Folder"'));
    expect(sent.body, contains('documents'));
    expect(sent.body, isNot(contains('name="file"')));
  });

  test('photos go to the images folder unless told otherwise', () async {
    final sent = await _upload(
      200,
      '{"imageUrl":"https://host/x.jpg"}',
      () async {
        await ApiService.upload(file.path);
      },
    );
    expect(RegExp(r'name="Folder"\r\n\r\nimages').hasMatch(sent.body), isTrue);
  });

  test('the server message is passed on when nothing was uploaded', () async {
    Object? error;
    await _upload(
      400,
      '{"status":false,"message":"No file uploaded."}',
      () async {
        try {
          await ApiService.upload(file.path);
        } catch (e) {
          error = e;
        }
      },
    );
    expect(error, isA<UploadException>());
    expect((error as UploadException).message, 'No file uploaded.');
  });

  test('an expired sign in says so', () async {
    Object? error;
    await _upload(401, '', () async {
      try {
        await ApiService.upload(file.path);
      } catch (e) {
        error = e;
      }
    });
    expect((error as UploadException).message, contains('sign in'));
  });

  test('a success with no imageUrl is an error, not an empty URL', () async {
    Object? error;
    await _upload(200, '{}', () async {
      try {
        await ApiService.upload(file.path);
      } catch (e) {
        error = e;
      }
    });
    expect(error, isA<UploadException>());
  });
}
