import 'package:ginilog_customer_app/features/bookings/data/model/customer_book_response_model.dart';

class CustomerBookState {
  final List<CustomerBookResponseModel> listCustomerBook;
  final CustomerBookResponseModel? singleData;
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

  // Create Bookings
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String comment;
  final String numberOfGuest;
  final String reservationStartDate;
  final String reservationEndDate;
  final bool isLoading;

  // Review Message
  final String reviewMessageChanged;
  final double isReviewChanged;

  const CustomerBookState({
    this.listCustomerBook = const [],
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
    // Create Bookings
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.comment = "",
    this.phoneNo = "",
    this.numberOfGuest = "",
    this.reservationStartDate = "",
    this.reservationEndDate = "",
    this.isLoading = false,
    // Review Message
    this.reviewMessageChanged = "",
    this.isReviewChanged = 0.0,
  });

  CustomerBookState copyWith({
    List<CustomerBookResponseModel>? listCustomerBook,
    CustomerBookResponseModel? singleData,
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

    // Create Bookings
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNo,
    String? comment,
    String? numberOfGuest,
    String? reservationStartDate,
    String? reservationEndDate,
    bool? isLoading,
    // Review Message
    String? reviewMessageChanged,
    double? isReviewChanged,
  }) {
    return CustomerBookState(
      listCustomerBook: listCustomerBook ?? this.listCustomerBook,
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
      // Create Bookings
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      comment: comment ?? this.comment,
      numberOfGuest: numberOfGuest ?? this.numberOfGuest,
      reservationStartDate: reservationStartDate ?? this.reservationStartDate,
      reservationEndDate: reservationEndDate ?? this.reservationEndDate,
      isLoading: isLoading ?? this.isLoading,
      // Review Message
      reviewMessageChanged: reviewMessageChanged ?? this.reviewMessageChanged,
      isReviewChanged: isReviewChanged ?? this.isReviewChanged,
    );
  }

  bool get canCreateBookings {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        numberOfGuest.trim().isNotEmpty &&
        phoneNo.trim().isNotEmpty &&
        reservationStartDate.trim().isNotEmpty &&
        reservationEndDate.trim().isNotEmpty;
  }
}
