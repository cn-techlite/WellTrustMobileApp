import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/visits/data/repository/visit_repository_impl.dart';
import 'package:well_trust_mobile_app/features/visits/data/service/visit_remote_service.dart';
import 'package:well_trust_mobile_app/features/visits/domain/controller/visit_controller.dart';
import 'package:well_trust_mobile_app/features/visits/domain/usercases/visit_repository.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/visit_state.dart';

final visitRemoteServiceProvider = Provider<VisitRemoteService>((ref) {
  return VisitRemoteService();
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return VisitRepositoryImpl(
    remoteService: ref.read(visitRemoteServiceProvider),
  );
});

final visitControllerProvider =
    AsyncNotifierProvider<VisitController, VisitState>(VisitController.new);
