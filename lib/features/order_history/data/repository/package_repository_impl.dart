import 'dart:convert';

import 'package:ginilog_customer_app/core/extension/error_handling.dart';
import 'package:ginilog_customer_app/features/order_history/data/dto/create_order.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/data/services/package_order_remote_service.dart';
import 'package:ginilog_customer_app/features/order_history/domain/usercases/package_repository.dart';
import 'package:ginilog_customer_app/shared/model/response_result_model.dart';

class PackageOrderRepositoryImpl implements PackageOrderRepository {
  final PackageOrderRemoteService remoteService;

  PackageOrderRepositoryImpl(this.remoteService);

  @override
  Future<PackageOrderPaginatedModel> getAllPackageOrderData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) {
    return remoteService.getAllPackageOrderData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
    );
  }

  @override
  Future<PackageOrderResponseModel> getPackageOrderData({required String id}) {
    return remoteService.getPackageOrderData(id: id);
  }

  @override
  Future<GeneralResultModel> createOrderWithAddress(
    CreatePackageOrderRequest request,
  ) async {
    final response = await remoteService.createOrderWithAddress(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Book PackageOrder successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> makePayment({
    required String orderId,
    required bool paymentStatus,
    required String paymentChannel,
    required String trnxReference,
    required String paymentType,
  }) async {
    final response = await remoteService.makePayment(
      orderId: orderId,
      paymentStatus: paymentStatus,
      trnxReference: trnxReference,
      paymentChannel: paymentChannel,
      paymentType: paymentType,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Payment Made successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> updateOrder({required String orderId}) async {
    final response = await remoteService.updateOrder(orderId: orderId);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Order Updated Made successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }
}
