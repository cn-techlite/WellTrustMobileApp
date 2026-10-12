import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/create_abc_chart_request.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';
import 'package:well_trust_mobile_app/features/account/data/service/abc_chart_remote_service.dart';

const _recordJson = <String, dynamic>{
  'id': 'abc-1',
  'residentId': 'resident-1',
  'companyId': 'company-1',
  'episodeDate': '2026-10-11',
  'episodeTime': '14:30:00',
  'location': 'Living room',
  'antecedent': 'The television was switched off.',
  'behaviour': 'The client pushed the care bag away.',
  'duration': 'About 5 minutes',
  'consequence': 'The carer paused and gave space.',
  'possibleFunction': 'Escape / Avoidance',
  'staffInvolved': 'Example Carer',
  'recordedBy': 'Example Carer',
  'recordedByStaffId': 'staff-1',
  'createdAt': '2026-10-11T13:39:00+00:00',
  'updatedAt': '2026-10-11T13:39:00+00:00',
};

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
    globals.token = 'test-token';
  });

  test('maps an ABC record from the mobile API', () {
    final entry = AbcChartEntry.fromJson(_recordJson);

    expect(entry.id, 'abc-1');
    expect(entry.residentId, 'resident-1');
    expect(entry.episodeDate, DateTime(2026, 10, 11));
    expect(entry.episodeTime, '14:30:00');
    expect(entry.possibleFunction, 'Escape / Avoidance');
    expect(entry.recordedBy, 'Example Carer');
  });

  test('create request sends the documented field names and formats', () {
    final request = CreateAbcChartRequest(
      AbcChartDraft(
        residentId: 'resident-1',
        episodeDate: DateTime(2026, 10, 11),
        episodeTime: '14:30:00',
        location: ' Living room ',
        antecedent: ' Before ',
        behaviour: ' During ',
        consequence: ' After ',
      ),
    ).toJson();

    expect(request, {
      'residentId': 'resident-1',
      'episodeDate': '2026-10-11',
      'episodeTime': '14:30:00',
      'location': 'Living room',
      'antecedent': 'Before',
      'behaviour': 'During',
      'duration': null,
      'consequence': 'After',
      'possibleFunction': null,
      'staffInvolved': null,
    });
  });

  test('loads records from the assigned-client endpoint', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(jsonEncode([_recordJson]), 200);
    });
    final service = AbcChartRemoteService(api: MobileApiClient(client: client));

    final records = await service.getForClient('resident-1');

    expect(sent.method, 'GET');
    expect(
      sent.url.path,
      endsWith('/api/mobile/abc-charts/clients/resident-1'),
    );
    expect(sent.headers['Authorization'], 'Bearer test-token');
    expect(records.single.id, 'abc-1');
  });

  test('posts a new ABC entry to the mobile collection endpoint', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(jsonEncode(_recordJson), 200);
    });
    final service = AbcChartRemoteService(api: MobileApiClient(client: client));

    final saved = await service.create(
      CreateAbcChartRequest(
        AbcChartDraft(
          residentId: 'resident-1',
          episodeDate: DateTime(2026, 10, 11),
          antecedent: 'Before',
          behaviour: 'During',
          consequence: 'After',
        ),
      ),
    );

    expect(sent.method, 'POST');
    expect(sent.url.path, endsWith('/api/mobile/abc-charts'));
    expect(jsonDecode(sent.body)['residentId'], 'resident-1');
    expect(saved.id, 'abc-1');
  });
}
