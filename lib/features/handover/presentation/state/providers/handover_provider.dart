import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/handover/data/repository/handover_repository_impl.dart';
import 'package:well_trust_mobile_app/features/handover/data/service/handover_remote_service.dart';
import 'package:well_trust_mobile_app/features/handover/domain/controller/handover_controller.dart';
import 'package:well_trust_mobile_app/features/handover/domain/usercases/handover_repository.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/state_model/handover_state.dart';

final handoverRemoteServiceProvider = Provider<HandoverRemoteService>((ref) {
  return HandoverRemoteService();
});

final handoverRepositoryProvider = Provider<HandoverRepository>((ref) {
  return HandoverRepositoryImpl(
    remoteService: ref.read(handoverRemoteServiceProvider),
  );
});

final handoverProvider = NotifierProvider<HandoverController, HandoverState>(
  HandoverController.new,
);
