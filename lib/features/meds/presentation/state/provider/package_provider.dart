import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/meds/data/repository/package_repository_impl.dart';
import 'package:well_trust_mobile_app/features/meds/data/services/package_order_remote_service.dart';
import 'package:well_trust_mobile_app/features/meds/domain/controller/package_order_controller.dart';
import 'package:well_trust_mobile_app/features/meds/domain/usercases/package_repository.dart';
import 'package:well_trust_mobile_app/features/meds/presentation/state/state_model/package_order_state.dart';

final packageOrderRemoteServiceProvider = Provider<PackageOrderRemoteService>((
  ref,
) {
  return PackageOrderRemoteService();
});

final packageOrderRepositoryProvider = Provider<PackageOrderRepository>((ref) {
  return PackageOrderRepositoryImpl(
    ref.read(packageOrderRemoteServiceProvider),
  );
});

//!Package Order Provider

final packageOrderControllerProvider =
    AsyncNotifierProvider<PackageOrderController, PackageOrderState>(
      PackageOrderController.new,
    );
