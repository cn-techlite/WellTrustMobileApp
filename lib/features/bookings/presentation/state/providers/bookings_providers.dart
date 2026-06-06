import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/bookings/data/repository/bookings_repository_impl.dart';
import 'package:ginilog_customer_app/features/bookings/data/services/booking_remote_service.dart';
import 'package:ginilog_customer_app/features/bookings/domain/controller/accomodation_controller.dart';
import 'package:ginilog_customer_app/features/bookings/domain/controller/accomodation_reservations_controller.dart';
import 'package:ginilog_customer_app/features/bookings/domain/controller/customer_book_contoller.dart';
import 'package:ginilog_customer_app/features/bookings/domain/usercases/bookings_repository.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_reservation_state.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_state.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/customer_book_state.dart';

final bookingsRemoteServiceProvider = Provider<BookingRemoteService>((ref) {
  return BookingRemoteService();
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepositoryImpl(ref.read(bookingsRemoteServiceProvider));
});

//!Accomodation Provider

final accomodationControllerProvider =
    AsyncNotifierProvider<AccomodationController, AccomodationState>(
      AccomodationController.new,
    );

//!Accomodation Reservations Provider

final accomodationReservationControllerProvider = AsyncNotifierProvider<
  AccomodationReservationController,
  AccomodationReservationState
>(AccomodationReservationController.new);

//!Customer Book Accomodation Reservations Provider

final customerBookControllerProvider =
    AsyncNotifierProvider<CustomerBookController, CustomerBookState>(
      CustomerBookController.new,
    );
