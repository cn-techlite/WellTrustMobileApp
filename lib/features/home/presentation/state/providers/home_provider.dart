import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:well_trust_mobile_app/features/home/data/repository/home_repository_impl.dart';
import 'package:well_trust_mobile_app/features/home/data/service/home_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/notification_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';

final homeRemoteServiceProvider = riverpod.Provider<HomeRemoteService>(
  (riverpod.Ref ref) => HomeRemoteService(),
);

final homeRepositoryProvider = riverpod.Provider<HomeRepository>((
  riverpod.Ref ref,
) {
  final remoteService = ref.read<HomeRemoteService>(homeRemoteServiceProvider);
  return HomeRepositoryImpl(remoteService);
});

final notificationControllerProvider =
    riverpod.AsyncNotifierProvider<
      NotificationController,
      NotificationStateModel
    >(NotificationController.new);
