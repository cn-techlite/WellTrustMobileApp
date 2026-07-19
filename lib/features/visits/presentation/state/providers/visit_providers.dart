import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/domain/controller/visit_controller.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/visit_state_model.dart';

// final bookingsRemoteServiceProvider = Provider<BookingRemoteService>((ref) {
//   return BookingRemoteService();
// });

// final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
//   return BookingsRepositoryImpl(ref.read(bookingsRemoteServiceProvider));
// });

//!VISIT Provider

final visitControllerProvider =
    AsyncNotifierProvider<VisitController, VisitState>(VisitController.new);
