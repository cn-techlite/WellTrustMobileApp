import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/clients/data/repository/client_repository_impl.dart';
import 'package:well_trust_mobile_app/features/clients/data/service/client_remote_service.dart';
import 'package:well_trust_mobile_app/features/clients/domain/controller/client_controller.dart';
import 'package:well_trust_mobile_app/features/clients/domain/usercases/client_repository.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/state_model/client_state.dart';

final clientRemoteServiceProvider = Provider<ClientRemoteService>((ref) {
  return ClientRemoteService();
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(
    remoteService: ref.read(clientRemoteServiceProvider),
  );
});

final assignedClientsProvider =
    AsyncNotifierProvider<ClientController, ClientState>(ClientController.new);
