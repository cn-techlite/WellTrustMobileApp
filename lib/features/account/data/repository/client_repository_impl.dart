import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/account/data/service/client_remote_service.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteService _remoteService;

  const ClientRepositoryImpl({required ClientRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<AssignedClient>> getAssignedClients() =>
      _remoteService.getAssignedClients();
}
