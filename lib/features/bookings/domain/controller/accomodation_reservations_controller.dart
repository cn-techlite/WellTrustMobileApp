import 'dart:async';

import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/accomodation_reservations_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/domain/usercases/bookings_repository.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_reservation_state.dart';

class AccomodationReservationController
    extends AsyncNotifier<AccomodationReservationState> {
  late final BookingsRepository _repository;

  final Map<String, bool> fetchedAccomodationReservationById = {};
  final Map<String, AccomodationReservationResponseModel>
  _accomodationReservationCache = {};
  final Map<String, int> _accomodationReservationVisitCounter = {};

  Timer? _searchDebounce;

  @override
  FutureOr<AccomodationReservationState> build() {
    _repository = ref.read(bookingsRepositoryProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return const AccomodationReservationState(
      listAccomodationReservation: [],
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
      accomodationId: '',
    );
  }

  AccomodationReservationState get _current =>
      state.value ?? const AccomodationReservationState();

  Future<void> getAllAccomodationReservationData({
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
        final response = await _repository.getAllAccomodationReservationData(
          page: 1,
          pageSize: resolvedPageSize,
          anyItem: current.anyItem,
          state: current.stateFilter,
          locality: current.localityFilter,
          filterTypes: current.filterTypes,
          accomodationId: current.accomodationId,
        );

        _cacheList(response.data ?? []);

        return current.copyWith(
          listAccomodationReservation: response.data ?? [],
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
      final response = await _repository.getAllAccomodationReservationData(
        page: 1,
        pageSize: resolvedPageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
        accomodationId: current.accomodationId,
      );

      _cacheList(response.data ?? []);

      state = AsyncData(
        current.copyWith(
          listAccomodationReservation:
              response.data ?? current.listAccomodationReservation,
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
      final response = await _repository.getAllAccomodationReservationData(
        page: 1,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
        accomodationId: current.accomodationId,
      );

      _cacheList(response.data ?? []);

      state = AsyncData(
        current.copyWith(
          listAccomodationReservation: response.data ?? [],
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

  Future<void> loadMoreListAccomodationReservation() async {
    final current = _current;

    if (!current.hasLoadedInitially) return;
    if (current.isLoadingMore) return;
    if (current.isRefreshing) return;
    if (!current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, error: null));

    try {
      final nextPage = current.page + 1;

      final response = await _repository.getAllAccomodationReservationData(
        page: nextPage,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
        accomodationId: current.accomodationId,
      );

      final newItems =
          response.data ?? const <AccomodationReservationResponseModel>[];

      final existingIds =
          current.listAccomodationReservation.map((e) => e.id).toSet();

      final filteredNewItems =
          newItems.where((e) => !existingIds.contains(e.id)).toList();

      _cacheList(filteredNewItems);

      state = AsyncData(
        current.copyWith(
          listAccomodationReservation: [
            ...current.listAccomodationReservation,
            ...filteredNewItems,
          ],
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
          listAccomodationReservation: [],
          hasLoadedInitially: false,
          isLoadingMore: false,
          isRefreshing: false,
          error: null,
        ),
      );

      await getAllAccomodationReservationData(
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
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
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
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
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
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
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
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  Future<void> setFilterAccomodationId(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        accomodationId: value,
        page: 1,
        hasNext: true,
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
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
        accomodationId: '',
        page: 1,
        hasNext: true,
        listAccomodationReservation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationReservationData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  AccomodationReservationResponseModel? getAccomodationReservationById(
    String id,
  ) {
    return _accomodationReservationCache[id];
  }

  Future<void> getAccomodationReservationData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _accomodationReservationVisitCounter[id] =
        (_accomodationReservationVisitCounter[id] ?? 0) + 1;

    final visitCount = _accomodationReservationVisitCounter[id]!;
    final cached = _accomodationReservationCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getAccomodationReservationData(id: id);

      if (response.id != null) {
        _accomodationReservationCache[response.id!] = response;
        fetchedAccomodationReservationById[response.id!] = true;
      }

      final list = [...previous.listAccomodationReservation];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        listAccomodationReservation: list,
        hasLoadedInitially: true,
        error: null,
      );
    });
  }

  void _cacheList(List<AccomodationReservationResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _accomodationReservationCache[id] = item;
      fetchedAccomodationReservationById[id] = true;
    }
  }
}
