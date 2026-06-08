import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/data/repository/home_repository_impl.dart';
import 'package:well_trust_mobile_app/features/home/data/services/home_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/advert_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/logistic_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/notification_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/riders_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/advert_state.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/logistic_state.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/rider_state.dart';

final homeRemoteServiceProvider = Provider<HomeRemoteService>((ref) {
  return HomeRemoteService();
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.read(homeRemoteServiceProvider));
});

//! Logistic Provider

final logisticsControllerProvider =
    AsyncNotifierProvider<LogisticController, LogisticState>(
      LogisticController.new,
    );

//!ADVERT Provider

final advertControllerProvider =
    AsyncNotifierProvider<AdvertController, AdvertStateModel>(
      AdvertController.new,
    );

//!NOTIFICATION Provider

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationStateModel>(
      NotificationController.new,
    );

//!RIDERS Provider

final ridersControllerProvider =
    AsyncNotifierProvider<RidersController, RidersState>(RidersController.new);
