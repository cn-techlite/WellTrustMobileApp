import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/order_history/data/repository/package_repository_impl.dart';
import 'package:ginilog_customer_app/features/order_history/data/services/package_order_remote_service.dart';
import 'package:ginilog_customer_app/features/order_history/domain/controller/package_order_controller.dart';
import 'package:ginilog_customer_app/features/order_history/domain/usercases/package_repository.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/state_model/package_order_state.dart';

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
