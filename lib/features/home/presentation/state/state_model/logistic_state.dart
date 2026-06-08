import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';

class LogisticState {
  final List<LogisticResponseModel> listLogistic;
  final LogisticResponseModel? singleData;
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

  // Location
  final bool isLoading;

  const LogisticState({
    this.listLogistic = const [],
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
    // LOCATION
    this.isLoading = false,
  });

  LogisticState copyWith({
    List<LogisticResponseModel>? listLogistic,
    LogisticResponseModel? singleData,
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
    // LOCATION
    bool? isLoading,
  }) {
    return LogisticState(
      listLogistic: listLogistic ?? this.listLogistic,
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
      // LOCATION
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
