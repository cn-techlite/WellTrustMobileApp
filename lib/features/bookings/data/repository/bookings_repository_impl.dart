import 'dart:convert';
import 'package:ginilog_customer_app/core/extension/error_handling.dart';
import 'package:ginilog_customer_app/features/bookings/data/dto/create_bookings.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/accomodation_reservations_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/accomodation_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/customer_book_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/reservation_date_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/data/services/booking_remote_service.dart';
import 'package:ginilog_customer_app/features/bookings/domain/usercases/bookings_repository.dart';
import 'package:ginilog_customer_app/shared/model/response_result_model.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingRemoteService remoteService;

  BookingsRepositoryImpl(this.remoteService);

  @override
  Future<AccomodationPaginatedModel> getAllAccomodationData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) {
    return remoteService.getAllAccomodationData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
    );
  }

  @override
  Future<AccomodationResponseModel> getAccomodationData({required String id}) {
    return remoteService.getAccomodationData(id: id);
  }
  //! ACCOMODATION RESERVATION

  @override
  Future<AccomodationReservationPaginatedModel>
  getAllAccomodationReservationData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
    String? accomodationId,
  }) {
    return remoteService.getAllAccomodationReservationData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
      accomodationId: accomodationId,
    );
  }

  @override
  Future<AccomodationReservationResponseModel> getAccomodationReservationData({
    required String id,
  }) {
    return remoteService.getAccomodationReservationData(id: id);
  }

  //! CUSTOMER BOOK ACCOMODATION RESERVATION

  @override
  Future<CustomerBookPaginatedModel> getAllCustomerBookData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  }) {
    return remoteService.getAllCustomerBookData(
      page: page,
      pageSize: pageSize,
      anyItem: anyItem,
      state: state,
      locality: locality,
      filterTypes: filterTypes,
    );
  }

  @override
  Future<CustomerBookResponseModel> getCustomerBookData({required String id}) {
    return remoteService.getCustomerBookData(id: id);
  }

  @override
  Future<GeneralResultModel> bookAccomodationReservation(
    CreateAccomodationReservationRequest request,
  ) async {
    final response = await remoteService.bookAccomodationReservation(request);
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Book Accomodation successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<GeneralResultModel> addAccomodationReview({
    required String accomodationId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final response = await remoteService.addAccomodationReview(
      accomodationId: accomodationId,
      reviewMessage: reviewMessage,
      ratingNum: ratingNum,
    );
    final errorMessage = getErrorMessageFromResponse(
      response.statusCode,
      response.body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return GeneralResultModel.success(
        rawData: response.body,
        message: "Transfer Sent successful",
        data: data,
      );
    }

    return GeneralResultModel.failure(errorMessage);
  }

  @override
  Future<List<ReservationDataResponseModel>> getAllReservationDateData({
    required String reservationId,
  }) {
    return remoteService.getAllReservationDateData(
      reservationId: reservationId,
    );
  }
}
