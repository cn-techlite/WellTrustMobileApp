import 'package:well_trust_mobile_app/features/notes/data/dto/create_order.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/package_orders_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class PackageOrderRepository {
  Future<PackageOrderPaginatedModel> getAllPackageOrderData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  });

  Future<PackageOrderResponseModel> getPackageOrderData({required String id});

  Future<GeneralResultModel> createOrderWithAddress(
    CreatePackageOrderRequest request,
  );

  Future<GeneralResultModel> makePayment({
    required String orderId,
    required bool paymentStatus,
    required String paymentChannel,
    required String trnxReference,
    required String paymentType,
  });
  Future<GeneralResultModel> updateOrder({required String orderId});
}
