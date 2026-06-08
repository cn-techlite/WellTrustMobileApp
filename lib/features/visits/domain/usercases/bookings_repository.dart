import 'package:well_trust_mobile_app/features/visits/data/dto/create_bookings.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_reservations_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/customer_book_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/reservation_date_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class BookingsRepository {
  Future<AccomodationPaginatedModel> getAllAccomodationData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  });

  Future<AccomodationResponseModel> getAccomodationData({required String id});

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
  });

  Future<AccomodationReservationResponseModel> getAccomodationReservationData({
    required String id,
  });

  //! CUSTOMER BOOK ACCOMODATION RESERVATION

  Future<CustomerBookPaginatedModel> getAllCustomerBookData({
    required int page,
    required int pageSize,
    String? anyItem,
    String? state,
    String? locality,
    String? filterTypes,
  });

  Future<CustomerBookResponseModel> getCustomerBookData({required String id});

  Future<GeneralResultModel> bookAccomodationReservation(
    CreateAccomodationReservationRequest request,
  );
  Future<GeneralResultModel> addAccomodationReview({
    required String accomodationId,
    required String reviewMessage,
    required double ratingNum,
  });

  Future<List<ReservationDataResponseModel>> getAllReservationDateData({
    required String reservationId,
  });
}
