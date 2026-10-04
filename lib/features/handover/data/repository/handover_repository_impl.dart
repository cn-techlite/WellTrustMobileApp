import 'package:well_trust_mobile_app/features/handover/data/dto/handover_requests.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/handover/data/service/handover_remote_service.dart';
import 'package:well_trust_mobile_app/features/handover/domain/usercases/handover_repository.dart';

class HandoverRepositoryImpl implements HandoverRepository {
  final HandoverRemoteService _remoteService;

  const HandoverRepositoryImpl({required HandoverRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<HandoverEntry>> getHandovers({
    String? clientId,
    bool? openOnly,
  }) => _remoteService.getHandovers(clientId: clientId, openOnly: openOnly);

  @override
  Future<HandoverEntry> create(HandoverEntry entry) =>
      _remoteService.create(CreateHandoverRequest(entry));

  @override
  Future<HandoverEntry> resolve(String id, String note) =>
      _remoteService.resolve(id, ResolveHandoverRequest(note));

  @override
  Future<void> markRead(String clientId) => _remoteService.markRead(clientId);
}
