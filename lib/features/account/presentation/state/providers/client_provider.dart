import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/account/data/repository/client_repository_impl.dart';
import 'package:well_trust_mobile_app/features/account/data/service/client_remote_service.dart';
import 'package:well_trust_mobile_app/features/account/domain/controller/client_controller.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/client_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/client_state.dart';

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
