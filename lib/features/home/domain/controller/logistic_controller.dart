import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/logistic_state.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class LogisticController extends AsyncNotifier<LogisticState> {
  late final HomeRepository _repository;

  final Map<String, bool> fetchedLogisticById = {};
  final Map<String, LogisticResponseModel> _logisticCache = {};
  final Map<String, int> _logisticVisitCounter = {};

  Timer? _searchDebounce;

  @override
  FutureOr<LogisticState> build() {
    _repository = ref.read(homeRepositoryProvider);

    ref.onDispose(() {
      _searchDebounce?.cancel();
    });

    return const LogisticState(
      listLogistic: [],
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

  LogisticState get _current => state.value ?? const LogisticState();

  Future<void> getAllLogisticData({
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
        final response = await _repository.getAllLogisticData(
          page: 1,
          pageSize: resolvedPageSize,
          anyItem: current.anyItem,
          state: current.stateFilter,
          locality: current.localityFilter,
          filterTypes: current.filterTypes,
        );

        _cacheList(response.data ?? []);

        return current.copyWith(
          listLogistic: response.data ?? [],
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
      final response = await _repository.getAllLogisticData(
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
          listLogistic: response.data ?? current.listLogistic,
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
      final response = await _repository.getAllLogisticData(
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
          listLogistic: response.data ?? [],
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

  Future<void> loadMoreListLogistic() async {
    final current = _current;

    if (!current.hasLoadedInitially) return;
    if (current.isLoadingMore) return;
    if (current.isRefreshing) return;
    if (!current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, error: null));

    try {
      final nextPage = current.page + 1;

      final response = await _repository.getAllLogisticData(
        page: nextPage,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      final newItems = response.data ?? const <LogisticResponseModel>[];

      final existingIds = current.listLogistic.map((e) => e.id).toSet();

      final filteredNewItems = newItems
          .where((e) => !existingIds.contains(e.id))
          .toList();

      _cacheList(filteredNewItems);

      state = AsyncData(
        current.copyWith(
          listLogistic: [...current.listLogistic, ...filteredNewItems],
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
          listLogistic: [],
          hasLoadedInitially: false,
          isLoadingMore: false,
          isRefreshing: false,
          error: null,
        ),
      );

      await getAllLogisticData(forceRefresh: true, pageSize: latest.pageSize);
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
        listLogistic: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllLogisticData(forceRefresh: true, pageSize: current.pageSize);
  }

  Future<void> setStateFilter(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        stateFilter: value,
        page: 1,
        hasNext: true,
        listLogistic: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllLogisticData(forceRefresh: true, pageSize: current.pageSize);
  }

  Future<void> setLocalityFilter(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        localityFilter: value,
        page: 1,
        hasNext: true,
        listLogistic: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllLogisticData(forceRefresh: true, pageSize: current.pageSize);
  }

  Future<void> setFilterTypes(String value) async {
    final current = _current;

    state = AsyncData(
      current.copyWith(
        filterTypes: value,
        page: 1,
        hasNext: true,
        listLogistic: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllLogisticData(forceRefresh: true, pageSize: current.pageSize);
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
        listLogistic: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllLogisticData(forceRefresh: true, pageSize: current.pageSize);
  }

  LogisticResponseModel? getLogisticById(String id) {
    return _logisticCache[id];
  }

  Future<void> getLogisticData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _logisticVisitCounter[id] = (_logisticVisitCounter[id] ?? 0) + 1;

    final visitCount = _logisticVisitCounter[id]!;
    final cached = _logisticCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getLogisticData(id: id);

      if (response.id != null) {
        _logisticCache[response.id!] = response;
        fetchedLogisticById[response.id!] = true;
      }

      final list = [...previous.listLogistic];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        listLogistic: list,
        hasLoadedInitially: true,
        error: null,
      );
    });
  }

  void _cacheList(List<LogisticResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _logisticCache[id] = item;
      fetchedLogisticById[id] = true;
    }
  }

  Future<GeneralResultModel> addLogisticsReview({
    required String stationId,
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.addLogisticsReview(
        stationId: stationId,
        orderId: orderId,
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

  Future<GeneralResultModel> getPlaceDetails(String placeId) async {
    final current = _current.copyWith(isLoading: true, error: '');

    state = AsyncData(current);

    final result = await AsyncValue.guard(() async {
      return await _repository.getPlaceDetails(placeId);
    });

    if (result.hasError) {
      state = AsyncData(
        current.copyWith(isLoading: false, error: result.error.toString()),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    state = AsyncData(current.copyWith(isLoading: false));

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Failed to get place details",
        );
  }

  Future<GeneralResultModel> getFullAddressFromLatLng({
    required double lat,
    required double lng,
  }) async {
    final current = _current.copyWith(isLoading: true, error: '');

    state = AsyncData(current);

    final result = await AsyncValue.guard(() async {
      return await _repository.getFullAddressFromLatLng(lat, lng);
    });

    if (result.hasError) {
      state = AsyncData(
        current.copyWith(isLoading: false, error: result.error.toString()),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    state = AsyncData(current.copyWith(isLoading: false));

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Failed to get address",
        );
  }
}
