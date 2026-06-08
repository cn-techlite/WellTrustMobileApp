import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_reservations_response_model.dart';

class AccomodationReservationState {
  final List<AccomodationReservationResponseModel> listAccomodationReservation;
  final AccomodationReservationResponseModel? singleData;
  final int page;
  final int pageSize;
  final bool hasLoadedInitially;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasNext;
  final int totalCount;
  final String? error;
  final String? successMessage;
  final int visitCount;
  // Filters
  final String anyItem;
  final String stateFilter;
  final String localityFilter;
  final String filterTypes;
  final String accomodationId;

  const AccomodationReservationState({
    this.listAccomodationReservation = const [],
    this.singleData,
    this.page = 1,
    this.pageSize = 20,
    this.hasLoadedInitially = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
    this.successMessage,
    this.visitCount = 0,
    this.anyItem = "",
    this.stateFilter = "",
    this.localityFilter = "",
    this.filterTypes = "",
    this.accomodationId = "",
  });

  AccomodationReservationState copyWith({
    List<AccomodationReservationResponseModel>? listAccomodationReservation,
    AccomodationReservationResponseModel? singleData,
    int? page,
    int? pageSize,
    bool? hasLoadedInitially,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasNext,
    int? totalCount,
    String? error,
    String? successMessage,
    String? anyItem,
    int? visitCount,
    String? stateFilter,
    String? localityFilter,
    String? filterTypes,
    String? accomodationId,
  }) {
    return AccomodationReservationState(
      listAccomodationReservation:
          listAccomodationReservation ?? this.listAccomodationReservation,
      singleData: singleData ?? this.singleData,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasLoadedInitially: hasLoadedInitially ?? this.hasLoadedInitially,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      visitCount: visitCount ?? this.visitCount,
      anyItem: anyItem ?? this.anyItem,
      stateFilter: stateFilter ?? this.stateFilter,
      localityFilter: localityFilter ?? this.localityFilter,
      filterTypes: filterTypes ?? this.filterTypes,
      accomodationId: accomodationId ?? this.accomodationId,
    );
  }
}
