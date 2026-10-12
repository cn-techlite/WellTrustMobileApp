import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/client_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/client_state.dart';

class ClientController extends AsyncNotifier<ClientState> {
  late final ClientRepository _repository;

  @override
  FutureOr<ClientState> build() async {
    _repository = ref.read(clientRepositoryProvider);
    if (!hasActiveSession) return const ClientState();
    return ClientState(assignedClients: await _repository.getAssignedClients());
  }

  Future<void> refresh() async {
    state = const AsyncLoading<ClientState>();
    state = await AsyncValue.guard(
      () async =>
          ClientState(assignedClients: await _repository.getAssignedClients()),
    );
  }
}
