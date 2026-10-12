import 'package:well_trust_mobile_app/features/account/data/dto/create_abc_chart_request.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';
import 'package:well_trust_mobile_app/features/account/data/service/abc_chart_remote_service.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/abc_chart_repository.dart';

class AbcChartRepositoryImpl implements AbcChartRepository {
  final AbcChartRemoteService _remoteService;

  const AbcChartRepositoryImpl({required AbcChartRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<AbcChartEntry>> getForClient(String clientId) =>
      _remoteService.getForClient(clientId);

  @override
  Future<AbcChartEntry> create(AbcChartDraft draft) =>
      _remoteService.create(CreateAbcChartRequest(draft));
}
