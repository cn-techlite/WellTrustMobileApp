import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/accomodation_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/domain/usercases/bookings_repository.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/bookings_providers.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/accomodation_state.dart';

class AccomodationController extends AsyncNotifier<AccomodationState> {
  late final BookingsRepository _repository;

  final Map<String, bool> fetchedAccomodationById = {};
  final Map<String, AccomodationResponseModel> _accomodationCache = {};
  final Map<String, int> _accomodationVisitCounter = {};

  Timer? _searchDebounce;

  @override
  FutureOr<AccomodationState> build() {
    _repository = ref.read(bookingsRepositoryProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return const AccomodationState(
      listAccomodation: [],
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

  AccomodationState get _current => state.value ?? const AccomodationState();

  Future<void> getAllAccomodationData({
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
        final response = await _repository.getAllAccomodationData(
          page: 1,
          pageSize: resolvedPageSize,
          anyItem: current.anyItem,
          state: current.stateFilter,
          locality: current.localityFilter,
          filterTypes: current.filterTypes,
        );

        _cacheList(response.data ?? []);

        return current.copyWith(
          listAccomodation: response.data ?? [],
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
      final response = await _repository.getAllAccomodationData(
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
          listAccomodation: response.data ?? current.listAccomodation,
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
      final response = await _repository.getAllAccomodationData(
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
          listAccomodation: response.data ?? [],
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

  Future<void> loadMoreListAccomodation() async {
    final current = _current;

    if (!current.hasLoadedInitially) return;
    if (current.isLoadingMore) return;
    if (current.isRefreshing) return;
    if (!current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, error: null));

    try {
      final nextPage = current.page + 1;

      final response = await _repository.getAllAccomodationData(
        page: nextPage,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      final newItems = response.data ?? const <AccomodationResponseModel>[];

      final existingIds = current.listAccomodation.map((e) => e.id).toSet();

      final filteredNewItems = newItems
          .where((e) => !existingIds.contains(e.id))
          .toList();

      _cacheList(filteredNewItems);

      state = AsyncData(
        current.copyWith(
          listAccomodation: [...current.listAccomodation, ...filteredNewItems],
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
          listAccomodation: [],
          hasLoadedInitially: false,
          isLoadingMore: false,
          isRefreshing: false,
          error: null,
        ),
      );

      await getAllAccomodationData(
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
        listAccomodation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationData(
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
        listAccomodation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationData(
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
        listAccomodation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationData(
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
        listAccomodation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationData(
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
        listAccomodation: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllAccomodationData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  AccomodationResponseModel? getAccomodationById(String id) {
    return _accomodationCache[id];
  }

  Future<void> getAccomodationData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _accomodationVisitCounter[id] = (_accomodationVisitCounter[id] ?? 0) + 1;

    final visitCount = _accomodationVisitCounter[id]!;
    final cached = _accomodationCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getAccomodationData(id: id);

      if (response.id != null) {
        _accomodationCache[response.id!] = response;
        fetchedAccomodationById[response.id!] = true;
      }

      final list = [...previous.listAccomodation];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        listAccomodation: list,
        hasLoadedInitially: true,
        error: null,
      );
    });
  }

  void _cacheList(List<AccomodationResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _accomodationCache[id] = item;
      fetchedAccomodationById[id] = true;
    }
  }
}
