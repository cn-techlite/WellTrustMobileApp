import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/features/meds/data/dto/create_order.dart';
import 'package:http/http.dart' as http;
import 'package:well_trust_mobile_app/features/meds/data/model/package_orders_model.dart';

class PackageOrderRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<http.Response> createOrderWithAddress(
    CreatePackageOrderRequest request,
  ) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/package-orders",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: {..._headers, "companyId": request.companyId},
      );
      printData("Add Order data Response", response.body);
      printData("Add Order data Response  Status Code", response.statusCode);
      printData("Add Order data Response url", url);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> makePayment({
    required String orderId,
    required bool paymentStatus,
    required String paymentChannel,
    required String trnxReference,
    required String paymentType,
  }) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/initialize-$paymentType-package-orders/$orderId",
      );

      final msg = jsonEncode({
        "paymentStatus": paymentStatus,
        "paymentChannel": paymentChannel,
        "trnxReference": trnxReference,
      });
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: _headers,
      );
      printData("Make Payment Response Status Code", response.statusCode);
      printData("Make Payment Response", response.body);
      return response;
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<PackageOrderPaginatedModel> getAllPackageOrderData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) async {
    try {
      final queryParams = <String, String>{
        "UserId": globals.userId,
        "Page": page.toString(),
        "PageSize": pageSize.toString(),
      };

      if (state != null && state.trim().isNotEmpty) {
        queryParams["State"] = state.trim();
      }

      if (locality != null && locality.trim().isNotEmpty) {
        queryParams["Locality"] = locality.trim();
      }

      if (anyItem != null && anyItem.trim().isNotEmpty) {
        queryParams["AnyItem"] = anyItem.trim();
      }
      if (filterTypes != null && filterTypes.trim().isNotEmpty) {
        queryParams["FilterTypes"] = filterTypes.trim();
      }

      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/package-orders",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All PackageOrder', response.body);
        return packageOrderPaginatedModelFromJson(response.body);
      }

      printData('All PackageOrder Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('PackageOrder Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<PackageOrderResponseModel> getPackageOrderData({
    required String id,
  }) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/package-orders/$id",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = PackageOrderResponseModel.fromJson(
          jsonDecode(response.body),
        );

        printData('Single PackageOrder', response.body);
        return data;
      }

      printData('Single PackageOrder Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single PackageOrder Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> updateOrder({required String orderId}) async {
    try {
      var stingUrl = Uri.parse(
        "${Endpoints.baseUrl}logistics-controller/package-orders/$orderId",
      );

      final msg = jsonEncode({"orderStatus": "Closed"});
      http.Response response = await http.put(
        stingUrl,
        body: msg,
        headers: _headers,
      );
      printData("Add Updated Package Order Response", response.body);
      printData("Add Updated Package Order Status Code", response.statusCode);
      return response;
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }
}
