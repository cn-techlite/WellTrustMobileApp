import 'dart:convert';

import 'package:well_trust_mobile_app/core/extension/error_handling.dart';
import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/create_bookings.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_reservations_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/customer_book_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/reservation_date_response_model.dart';
import 'package:http/http.dart' as http;

class BookingRemoteService {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${globals.token}',
  };

  Future<AccomodationPaginatedModel> getAllAccomodationData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) async {
    try {
      final queryParams = <String, String>{
        //"UserId":globals.userId,
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
        "${Endpoints.baseUrl}bookings/accomodation",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All Accomodations', response.body);
        return accomodationPaginatedModelFromJson(response.body);
      }

      printData('All Accomodation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Accomodation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<AccomodationResponseModel> getAccomodationData({
    required String id,
  }) async {
    try {
      final url = Uri.parse("${Endpoints.baseUrl}bookings/accomodation/$id");

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = AccomodationResponseModel.fromJson(
          jsonDecode(response.body),
        );

        printData('Single Accomodation', response.body);
        return data;
      }

      printData('Single Accomodation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single Accomodation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! ACCOMODATION RESERVATION

  Future<AccomodationReservationPaginatedModel>
  getAllAccomodationReservationData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
    String? accomodationId,
  }) async {
    try {
      final queryParams = <String, String>{
        //"UserId":globals.userId,
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
      if (accomodationId != null && accomodationId.trim().isNotEmpty) {
        queryParams["UserId"] = accomodationId.trim();
      }
      if (filterTypes != null && filterTypes.trim().isNotEmpty) {
        queryParams["FilterTypes"] = filterTypes.trim();
      }

      final url = Uri.parse(
        "${Endpoints.baseUrl}bookings/accomodation-reservations",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All Accomodations Reservation', response.body);
        return accomodationReservationPaginatedModelFromJson(response.body);
      }

      printData('All Accomodation Reservation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Accomodation Reservation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<AccomodationReservationResponseModel> getAccomodationReservationData({
    required String id,
  }) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}bookings/accomodation-reservations/$id",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = AccomodationReservationResponseModel.fromJson(
          jsonDecode(response.body),
        );

        printData('Single Accomodation Reservation', response.body);
        return data;
      }

      printData('Single Accomodation Reservation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single Accomodation Reservation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  //! CUSTOMER BOOK ACCOMODATION RESERVATION

  Future<CustomerBookPaginatedModel> getAllCustomerBookData({
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
        "${Endpoints.baseUrl}bookings/accomodation-reservations-customer",
      ).replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        printData('All Customer Book Reservation', response.body);
        return customerBookPaginatedModelFromJson(response.body);
      }

      printData('All Customer Book Reservation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Customer Book Reservation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<CustomerBookResponseModel> getCustomerBookData({
    required String id,
  }) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}bookings/accomodation-reservations-customer/$id",
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = CustomerBookResponseModel.fromJson(
          jsonDecode(response.body),
        );

        printData('Single Customer Book Reservation', response.body);
        return data;
      }

      printData('Single Customer Book Reservation Error', response.body);
      throw Exception(
        getErrorMessageFromResponse(response.statusCode, response.body),
      );
    } catch (e) {
      printData('Single Customer Book Reservation Catch Error', e.toString());
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> bookAccomodationReservation(
    CreateAccomodationReservationRequest request,
  ) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}bookings/initialize-${request.paymentType}-accomodation-reservations-customer",
      );

      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
        headers: _headers,
      );
      printData("Add Bookings data Response", response.body);
      printData("Add Bookings data Response  Status Code", response.statusCode);
      printData("Add Bookings data Response url", url);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  Future<http.Response> addAccomodationReview({
    required String accomodationId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    try {
      final url = Uri.parse(
        "${Endpoints.baseUrl}bookings/update-accomodation-review/$accomodationId",
      );

      final response = await http.post(
        url,
        body: jsonEncode({
          "reviewMessage": reviewMessage,
          "ratingNum": ratingNum,
        }),
        headers: _headers,
      );
      printData("Add Accomodation Review Response", response.body);
      printData(
        "Add Accomodation Review Response  Status Code",
        response.statusCode,
      );
      printData("Add Accomodation Review Response url", url);
      return response;
    } catch (e) {
      return Future.error(handleHttpError(e));
    }
  }

  //Reservation Date
  Future<List<ReservationDataResponseModel>> getAllReservationDateData({
    required String reservationId,
  }) async {
    List<ReservationDataResponseModel> data = [];
    try {
      Map<String, String> headers2 = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
        "reservationId": reservationId,
      };
      var url = Uri.parse(
        "${Endpoints.baseUrl}Bookings/all-reservations-dates",
      );
      var response = await http.get(url, headers: headers2);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data1 = reservationDataResponseModelFromJson(response.body);
        data = data1;
        printData('All Reservation Dates', response.body);
        return data;
      } else {
        printData('All Reservation Dates Error', response.body);
      }
    } catch (e) {
      printData('Error', e.toString());
      return Future.error(handleHttpError(e));
    }
    return data;
  }
}
