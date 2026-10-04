import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';

void main() {
  test('the API base URL has no double slash', () {
    expect(
      Endpoints.baseUrl,
      'https://new-api-connection.welltrustcare.co.uk/api/',
    );
    expect(
      Endpoints.baseUrl.replaceFirst('https://', ''),
      isNot(contains('//')),
    );
  });

  test('endpoints built from it match the API docs', () {
    expect(
      '${Endpoints.baseUrl}${Endpoints.kioskLoginUrl}',
      'https://new-api-connection.welltrustcare.co.uk/api/welltrust-kiosk/login',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.uploadUrl}',
      'https://new-api-connection.welltrustcare.co.uk/api/upload-files/upload-web-server',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.usersUrl}/profile',
      'https://new-api-connection.welltrustcare.co.uk/api/admin-users/profile',
    );
    expect(
      '${Endpoints.baseUrl}${Endpoints.userUpdate}',
      'https://new-api-connection.welltrustcare.co.uk/api/admin-users/update',
    );
    expect(
      Endpoints.webSocketUrl,
      Uri.parse('wss://new-api-connection.welltrustcare.co.uk/ws'),
    );
  });

  test('mobile care and staff endpoint builders match the API contract', () {
    expect(Endpoints.assignedClientsUrl, 'mobile/assigned-clients');
    expect(Endpoints.rotaUrl, 'mobile/rota');
    expect(Endpoints.visit('visit-id'), 'mobile/visits/visit-id');
    expect(
      Endpoints.visitClockIn('visit-id'),
      'mobile/visits/visit-id/clock-in',
    );
    expect(
      Endpoints.visitClockOut('visit-id'),
      'mobile/visits/visit-id/clock-out',
    );
    expect(Endpoints.visitTasks('visit-id'), 'mobile/visits/visit-id/tasks');
    expect(Endpoints.visitIssues('visit-id'), 'mobile/visits/visit-id/issues');
    expect(Endpoints.careNotesUrl, 'mobile/care-notes');
    expect(Endpoints.handoversUrl, 'mobile/handovers');
    expect(
      Endpoints.resolveHandover('handover-id'),
      'mobile/handovers/handover-id/resolve',
    );
    expect(
      Endpoints.markClientHandoversRead('client-id'),
      'mobile/handovers/client/client-id/read',
    );
    expect(Endpoints.messagesUrl, 'mobile/messages');
    expect(
      Endpoints.markMessageRead('message-id'),
      'mobile/messages/message-id/read',
    );
    expect(Endpoints.assessmentsUrl, 'mobile/care-assessments');
    expect(Endpoints.incidentsUrl, 'mobile/incidents');
    expect(Endpoints.complaintsUrl, 'mobile/complaints');
    expect(Endpoints.meetingsUrl, 'mobile/meetings');
    expect(
      Endpoints.staffDocumentsFor('staff-id'),
      'admin-staff-records/documents/staff/staff-id',
    );
    expect(
      Endpoints.sendReferenceRequest('reference-id'),
      'admin-staff-records/references/reference-id/send-request',
    );
  });
}
