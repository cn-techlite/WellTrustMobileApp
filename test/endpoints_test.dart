import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';

void main() {
  test('the API base URL has no double slash', () {
    expect(
      Endpoints.baseUrl,
      'https://new-api-connection.welltrusthealthstaff.co.uk/api/',
    );
    expect(
      Endpoints.baseUrl.replaceFirst('https://', ''),
      isNot(contains('//')),
    );
  });

  test('endpoints built from it match the API docs', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.kioskLoginUrl}',
      'https://new-api-connection.welltrusthealthstaff.co.uk/api/welltrust-kiosk/login',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.uploadUrl}',
      'https://new-api-connection.welltrusthealthstaff.co.uk/api/upload-files/upload-web-server',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.usersUrl}/profile',
      'https://new-api-connection.welltrusthealthstaff.co.uk/api/admin-users/profile',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.userUpdate}',
      'https://new-api-connection.welltrusthealthstaff.co.uk/api/admin-users/update',
    );
  });
}
