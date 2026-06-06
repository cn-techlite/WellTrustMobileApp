import 'dart:async';

import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/bookings/data/dto/create_bookings.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/customer_book_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/domain/usercases/bookings_repository.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/customer_book_state.dart';
import 'package:ginilog_customer_app/shared/model/response_result_model.dart';

class CustomerBookController extends AsyncNotifier<CustomerBookState> {
  late final BookingsRepository _repository;

  final Map<String, bool> fetchedCustomerBookById = {};
  final Map<String, CustomerBookResponseModel> _customerBookCache = {};
  final Map<String, int> _customerBookVisitCounter = {};

  Timer? _searchDebounce;

  @override
  FutureOr<CustomerBookState> build() {
    _repository = ref.read(bookingsRepositoryProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return const CustomerBookState(
      listCustomerBook: [],
      hasNext: false,
      singleData: null,
      hasLoadedInitially: false,
      isLoadingMore: false,
      isRefreshing: false,
      page: 1,
      pageSize: 20,
      anyItem: '',
      stateFilter: '',
      localityFilter: '',
      error: null,
      visitCount: 0,
      filterTypes: '',
    );
  }

  CustomerBookState get _current => state.value ?? const CustomerBookState();

  Future<void> getAllCustomerBookData({
    bool forceRefresh = false,
    int? pageSize,
  }) async {
    final current = _current;
    final resolvedPageSize = pageSize ?? current.pageSize;
    final newVisit = current.visitCount + 1;

    /// FIRST LOAD OR FORCE REFRESH = show full loader
    if (!current.hasLoadedInitially || forceRefresh) {
      state = const AsyncLoading();

      state = await AsyncValue.guard(() async {
        final response = await _repository.getAllCustomerBookData(
          page: 1,
          pageSize: resolvedPageSize,
          anyItem: current.anyItem,
          state: current.stateFilter,
          locality: current.localityFilter,
          filterTypes: current.filterTypes,
        );

        _cacheList(response.data ?? []);

        return current.copyWith(
          listCustomerBook: response.data ?? [],
          totalCount: response.totalCount ?? 0,
          hasNext: response.hasNext ?? false,
          page: response.page ?? 1,
          pageSize: response.pageSize ?? resolvedPageSize,
          isLoadingMore: false,
          isRefreshing: false,
          hasLoadedInitially: true,
          visitCount: newVisit,
          error: null,
        );
      });

      return;
    }

    /// SECOND TIME ENTERING PAGE = silent backend refresh
    try {
      final response = await _repository.getAllCustomerBookData(
        page: 1,
        pageSize: resolvedPageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      _cacheList(response.data ?? []);

      state = AsyncData(
        current.copyWith(
          listCustomerBook: response.data ?? current.listCustomerBook,
          totalCount: response.totalCount ?? current.totalCount,
          hasNext: response.hasNext ?? current.hasNext,
          page: response.page ?? 1,
          pageSize: response.pageSize ?? resolvedPageSize,
          isLoadingMore: false,
          isRefreshing: false,
          visitCount: newVisit,
          error: null,
        ),
      );
    } catch (e, st) {
      state = AsyncData(
        current.copyWith(
          error: "$e\n$st",
          isLoadingMore: false,
          isRefreshing: false,
        ),
      );
    }
  }

  Future<void> refreshList() async {
    final current = _current;

    if (current.isRefreshing) return;

    state = AsyncData(current.copyWith(isRefreshing: true, error: null));

    try {
      final response = await _repository.getAllCustomerBookData(
        page: 1,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      _cacheList(response.data ?? []);

      state = AsyncData(
        current.copyWith(
          listCustomerBook: response.data ?? [],
          totalCount: response.totalCount ?? current.totalCount,
          hasNext: response.hasNext ?? false,
          page: response.page ?? 1,
          pageSize: response.pageSize ?? current.pageSize,
          isRefreshing: false,
          isLoadingMore: false,
          hasLoadedInitially: true,
          error: null,
        ),
      );
    } catch (e, st) {
      state = AsyncData(
        current.copyWith(isRefreshing: false, error: "$e\n$st"),
      );
    }
  }

  Future<void> loadMoreListCustomerBook() async {
    final current = _current;

    if (!current.hasLoadedInitially) return;
    if (current.isLoadingMore) return;
    if (current.isRefreshing) return;
    if (!current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, error: null));

    try {
      final nextPage = current.page + 1;

      final response = await _repository.getAllCustomerBookData(
        page: nextPage,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      final newItems = response.data ?? const <CustomerBookResponseModel>[];

      final existingIds = current.listCustomerBook.map((e) => e.id).toSet();

      final filteredNewItems =
          newItems.where((e) => !existingIds.contains(e.id)).toList();

      _cacheList(filteredNewItems);

      state = AsyncData(
        current.copyWith(
          listCustomerBook: [...current.listCustomerBook, ...filteredNewItems],
          page: response.page ?? nextPage,
          pageSize: response.pageSize ?? current.pageSize,
          totalCount: response.totalCount ?? current.totalCount,
          hasNext: response.hasNext ?? false,
          isLoadingMore: false,
          error: null,
        ),
      );
    } catch (e, st) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, error: "$e\n$st"),
      );
    }
  }

  void onSearchChanged(
    String value, {
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) {
    _searchDebounce?.cancel();

    final current = _current;

    state = AsyncData(current.copyWith(anyItem: value, error: null));

    _searchDebounce = Timer(debounceDuration, () async {
      final latest = _current;

      state = AsyncData(
        latest.copyWith(
          page: 1,
          hasNext: true,
          listCustomerBook: [],
          hasLoadedInitially: false,
          isLoadingMore: false,
          isRefreshing: false,
          error: null,
        ),
      );

      await getAllCustomerBookData(
        forceRefresh: true,
        pageSize: latest.pageSize,
      );
    });
  }

  Future<void> setAnyItem(String value) async {
    _searchDebounce?.cancel();

    final current = _current;

    state = AsyncData(
      current.copyWith(
        anyItem: value,
        page: 1,
        hasNext: true,
        listCustomerBook: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllCustomerBookData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  Future<void> setStateFilter(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        stateFilter: value,
        page: 1,
        hasNext: true,
        listCustomerBook: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllCustomerBookData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  Future<void> setLocalityFilter(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        localityFilter: value,
        page: 1,
        hasNext: true,
        listCustomerBook: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllCustomerBookData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  Future<void> setFilterTypes(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        filterTypes: value,
        page: 1,
        hasNext: true,
        listCustomerBook: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllCustomerBookData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  Future<void> clearFilters() async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        anyItem: '',
        stateFilter: '',
        localityFilter: '',
        filterTypes: '',
        page: 1,
        hasNext: true,
        listCustomerBook: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllCustomerBookData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  CustomerBookResponseModel? getCustomerBookById(String id) {
    return _customerBookCache[id];
  }

  Future<void> getCustomerBookData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _customerBookVisitCounter[id] = (_customerBookVisitCounter[id] ?? 0) + 1;

    final visitCount = _customerBookVisitCounter[id]!;
    final cached = _customerBookCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getCustomerBookData(id: id);

      if (response.id != null) {
        _customerBookCache[response.id!] = response;
        fetchedCustomerBookById[response.id!] = true;
      }

      final list = [...previous.listCustomerBook];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        listCustomerBook: list,
        hasLoadedInitially: true,
        error: null,
      );
    });
  }

  void _cacheList(List<CustomerBookResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _customerBookCache[id] = item;
      fetchedCustomerBookById[id] = true;
    }
  }

  //!BOOKINGS CREATE
  void onFirstNameChanged(String value) {
    state = AsyncData(_current.copyWith(firstName: value));
  }

  void onLastNameChanged(String value) {
    state = AsyncData(_current.copyWith(lastName: value));
  }

  void onEmailChanged(String value) {
    state = AsyncData(_current.copyWith(email: value));
  }

  void onPhoneChanged(String value) {
    state = AsyncData(_current.copyWith(phoneNo: value));
  }

  void onNoOfGuestChanged(String value) {
    state = AsyncData(_current.copyWith(numberOfGuest: value));
  }

  void onReservationStartDateChanged(String value) {
    state = AsyncData(_current.copyWith(reservationStartDate: value));
  }

  void onReservationEndDateChanged(String value) {
    state = AsyncData(_current.copyWith(reservationEndDate: value));
  }

  Future<GeneralResultModel> bookAccomodationReservation({
    required CreateAccomodationReservationRequest request,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.bookAccomodationReservation(request);
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }

  Future<GeneralResultModel> addAccomodationReview({
    required String accomodationId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.addAccomodationReview(
        accomodationId: accomodationId,
        reviewMessage: reviewMessage,
        ratingNum: ratingNum,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }
}
