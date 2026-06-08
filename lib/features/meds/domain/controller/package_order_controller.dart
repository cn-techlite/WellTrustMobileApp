import 'dart:async';
import 'dart:convert';

import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/meds/data/dto/create_order.dart';
import 'package:well_trust_mobile_app/features/meds/data/model/package_orders_model.dart';
import 'package:well_trust_mobile_app/features/meds/domain/usercases/package_repository.dart';
import 'package:well_trust_mobile_app/features/meds/presentation/state/provider/package_provider.dart';
import 'package:well_trust_mobile_app/features/meds/presentation/state/state_model/package_order_state.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class PackageOrderController extends AsyncNotifier<PackageOrderState> {
  late final PackageOrderRepository _repository;

  final Map<String, bool> fetchedPackageOrderById = {};
  final Map<String, PackageOrderResponseModel> _packageOrderCache = {};
  final Map<String, int> _packageOrderVisitCounter = {};

  Timer? _searchDebounce;

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _socketSubscription;

  bool isConnected = false;
  bool _isDisposed = false;
  int reconnectionAttempts = 0;
  String orderId = "";

  @override
  FutureOr<PackageOrderState> build() {
    _repository = ref.read(packageOrderRepositoryProvider);

    ref.onDispose(() {
      _isDisposed = true;
      _searchDebounce?.cancel();
      disconnect();
      _searchDebounce?.cancel();
    });

    return const PackageOrderState(
      listPackageOrder: [],
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

  PackageOrderState get _current => state.value ?? const PackageOrderState();

  Future<void> connectAndJoinOrder({
    required String orderId,
    required bool isSingle,
  }) async {
    this.orderId = orderId;

    await disconnect();

    _connectWebSocket(isSingle: isSingle);
  }

  void _connectWebSocket({required bool isSingle}) {
    if (_isDisposed) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://new-api-connection.welltrusthealthstaff.co.uk/ws'),
      );

      printData("Initiate Connection:", '✅ Connected to WebSocket');

      isConnected = true;
      reconnectionAttempts = 0;

      final joinMessage = jsonEncode({
        "action": "JoinOrderTracking",
        "orderId": orderId,
      });

      _channel!.sink.add(joinMessage);

      printData("Connection Established:", 'Sent: $joinMessage');

      _socketSubscription = _channel!.stream.listen(
        (message) {
          printData("Received:", '$message');

          if (isSingle) {
            _handleSingleMessage(message.toString());
          } else {
            _handleMessage(message.toString());
          }
        },
        onError: (error) {
          printData("WebSocket Error:", '$error');
          _handleWebSocketError(isSingle: isSingle);
        },
        onDone: () {
          printData("WebSocket Closed", 'WebSocket Closed');
          _handleWebSocketError(isSingle: isSingle);
        },
        cancelOnError: true,
      );
    } catch (e) {
      printData("Failed to connect:", '$e');
      _handleWebSocketError(isSingle: isSingle);
    }
  }

  void _handleMessage(String message) {
    try {
      final Map<String, dynamic> outerJson = jsonDecode(message);

      if (!outerJson.containsKey('data')) {
        printData("Json Error", 'Unexpected JSON Format');
        return;
      }

      final dynamic rawData = outerJson['data'];

      final Map<String, dynamic> innerJson = rawData is String
          ? jsonDecode(rawData)
          : rawData;

      final updatedOrder = PackageOrderResponseModel.fromJson(innerJson);

      final current = _current;
      final orders = [...current.listPackageOrder];

      final index = orders.indexWhere((x) => x.id == updatedOrder.id);

      if (index != -1) {
        orders[index] = updatedOrder;
      } else {
        orders.insert(0, updatedOrder);
      }

      if (updatedOrder.id != null && updatedOrder.id!.isNotEmpty) {
        _packageOrderCache[updatedOrder.id!] = updatedOrder;
        fetchedPackageOrderById[updatedOrder.id!] = true;
      }

      state = AsyncData(
        current.copyWith(
          listPackageOrder: orders,
          singleData: current.singleData?.id == updatedOrder.id
              ? updatedOrder
              : current.singleData,
          successMessage: "Live Order Update",
          error: null,
        ),
      );
    } catch (e) {
      printData("Json Error", 'JSON Parsing Error: $e');
    }
  }

  void _handleSingleMessage(String message) {
    try {
      final Map<String, dynamic> outerJson = jsonDecode(message);

      if (!outerJson.containsKey('data')) {
        printData("Json Error", 'Unexpected JSON Format');
        return;
      }

      final dynamic rawData = outerJson['data'];

      final Map<String, dynamic> innerJson = rawData is String
          ? jsonDecode(rawData)
          : rawData;

      final updatedOrder = PackageOrderResponseModel.fromJson(innerJson);

      final current = _current;
      final orders = [...current.listPackageOrder];

      final index = orders.indexWhere((x) => x.id == updatedOrder.id);

      if (index != -1) {
        orders[index] = updatedOrder;
      } else {
        orders.insert(0, updatedOrder);
      }

      if (updatedOrder.id != null && updatedOrder.id!.isNotEmpty) {
        _packageOrderCache[updatedOrder.id!] = updatedOrder;
        fetchedPackageOrderById[updatedOrder.id!] = true;
      }

      state = AsyncData(
        current.copyWith(
          singleData: updatedOrder,
          listPackageOrder: orders,
          successMessage: "Live Order Update",
          error: null,
        ),
      );
    } catch (e) {
      printData("Json Error", 'JSON Parsing Error: $e');
    }
  }

  void _handleWebSocketError({required bool isSingle}) {
    if (_isDisposed) return;

    isConnected = false;
    reconnectionAttempts++;

    int delay = 1 << reconnectionAttempts;
    delay = delay < 60 ? delay : 60;

    Future.delayed(Duration(seconds: delay), () {
      if (_isDisposed) return;
      if (orderId.isEmpty) return;

      _connectWebSocket(isSingle: isSingle);
    });
  }

  Future<void> disconnect() async {
    isConnected = false;

    await _socketSubscription?.cancel();
    _socketSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    printData("Disconnected", '❌ Disconnected from WebSocket');
  }

  Future<void> getAllPackageOrderData({
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
        final response = await _repository.getAllPackageOrderData(
          page: 1,
          pageSize: resolvedPageSize,
          anyItem: current.anyItem,
          state: current.stateFilter,
          locality: current.localityFilter,
          filterTypes: current.filterTypes,
        );

        _cacheList(response.data ?? []);

        return current.copyWith(
          listPackageOrder: response.data ?? [],
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
      final response = await _repository.getAllPackageOrderData(
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
          listPackageOrder: response.data ?? current.listPackageOrder,
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
      final response = await _repository.getAllPackageOrderData(
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
          listPackageOrder: response.data ?? [],
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

  Future<void> loadMoreListPackageOrder() async {
    final current = _current;

    if (!current.hasLoadedInitially) return;
    if (current.isLoadingMore) return;
    if (current.isRefreshing) return;
    if (!current.hasNext) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, error: null));

    try {
      final nextPage = current.page + 1;

      final response = await _repository.getAllPackageOrderData(
        page: nextPage,
        pageSize: current.pageSize,
        anyItem: current.anyItem,
        state: current.stateFilter,
        locality: current.localityFilter,
        filterTypes: current.filterTypes,
      );

      final newItems = response.data ?? const <PackageOrderResponseModel>[];

      final existingIds = current.listPackageOrder.map((e) => e.id).toSet();

      final filteredNewItems = newItems
          .where((e) => !existingIds.contains(e.id))
          .toList();

      _cacheList(filteredNewItems);

      state = AsyncData(
        current.copyWith(
          listPackageOrder: [...current.listPackageOrder, ...filteredNewItems],
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
          listPackageOrder: [],
          hasLoadedInitially: false,
          isLoadingMore: false,
          isRefreshing: false,
          error: null,
        ),
      );

      await getAllPackageOrderData(
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
        listPackageOrder: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllPackageOrderData(
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
        listPackageOrder: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllPackageOrderData(
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
        listPackageOrder: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllPackageOrderData(
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
        listPackageOrder: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllPackageOrderData(
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
        listPackageOrder: [],
        hasLoadedInitially: false,
        isLoadingMore: false,
        isRefreshing: false,
        error: null,
      ),
    );

    await getAllPackageOrderData(
      forceRefresh: true,
      pageSize: current.pageSize,
    );
  }

  PackageOrderResponseModel? getPackageOrderById(String id) {
    return _packageOrderCache[id];
  }

  Future<void> getPackageOrderData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _packageOrderVisitCounter[id] = (_packageOrderVisitCounter[id] ?? 0) + 1;

    final visitCount = _packageOrderVisitCounter[id]!;
    final cached = _packageOrderCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _repository.getPackageOrderData(id: id);

      if (response.id != null) {
        _packageOrderCache[response.id!] = response;
        fetchedPackageOrderById[response.id!] = true;
      }

      final list = [...previous.listPackageOrder];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        listPackageOrder: list,
        hasLoadedInitially: true,
        error: null,
      );
    });
  }

  void _cacheList(List<PackageOrderResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _packageOrderCache[id] = item;
      fetchedPackageOrderById[id] = true;
    }
  }

  //!PACKAGE ORDER CREATE
  void onCompanyIdChanged(String value) {
    state = AsyncData(_current.copyWith(companyId: value));
  }

  void onCompanyNameChanged(String value) {
    state = AsyncData(_current.copyWith(companyName: value));
  }

  // Sender
  void onSenderNameChanged(String value) {
    state = AsyncData(_current.copyWith(senderName: value));
  }

  void onSenderEmailChanged(String value) {
    state = AsyncData(_current.copyWith(senderEmail: value));
  }

  void onOriginAddressChanged(String value) {
    state = AsyncData(_current.copyWith(originAddress: value));
  }

  void onOriginPhoneNoChanged(String value) {
    state = AsyncData(_current.copyWith(originPhoneNo: value));
  }

  void onOriginPostCodeChanged(String value) {
    state = AsyncData(_current.copyWith(originPostcodes: value));
  }

  void onSenderStateChanged(String value) {
    state = AsyncData(_current.copyWith(senderState: value));
  }

  void onSenderCityChanged(String value) {
    state = AsyncData(_current.copyWith(senderCity: value));
  }

  void onSenderCountryChanged(String value) {
    state = AsyncData(_current.copyWith(senderCountry: value));
  }

  void onOriginLatitudeChanged(double value) {
    state = AsyncData(_current.copyWith(originLatitude: value));
  }

  void onOriginLongitudeChanged(double value) {
    state = AsyncData(_current.copyWith(originLongitude: value));
  }

  // Receiver
  void onReceiverNameChanged(String value) {
    state = AsyncData(_current.copyWith(receiverName: value));
  }

  void onReceiverEmailChanged(String value) {
    state = AsyncData(_current.copyWith(receiverEmail: value));
  }

  void onReceiverAddressChanged(String value) {
    state = AsyncData(_current.copyWith(receiverAddress: value));
  }

  void onReceiverPhoneNoChanged(String value) {
    state = AsyncData(_current.copyWith(receiverPhoneNo: value));
  }

  void onReceiverPostCodeChanged(String value) {
    state = AsyncData(_current.copyWith(receiverPostcodes: value));
  }

  void onReceiverStateChanged(String value) {
    state = AsyncData(_current.copyWith(receiverState: value));
  }

  void onReceiverCityChanged(String value) {
    state = AsyncData(_current.copyWith(receiverCity: value));
  }

  void onReceiverCountryChanged(String value) {
    state = AsyncData(_current.copyWith(receiverCountry: value));
  }

  void onReceiverLatitudeChanged(double value) {
    state = AsyncData(_current.copyWith(receiverLatitude: value));
  }

  void onReceiverLongitudeChanged(double value) {
    state = AsyncData(_current.copyWith(receiverLongitude: value));
  }

  // Package Information
  void onPackageNameChanged(String value) {
    state = AsyncData(_current.copyWith(packageName: value));
  }

  void onItemCostChanged(String value) {
    state = AsyncData(_current.copyWith(itemCost: value));
  }

  void onItemQuantityChanged(String value) {
    state = AsyncData(_current.copyWith(itemQuantity: value));
  }

  void onItemWeightChanged(String value) {
    state = AsyncData(_current.copyWith(itemWeight: value));
  }

  void onItemModelNumberChanged(String value) {
    state = AsyncData(_current.copyWith(itemModelNumber: value));
  }

  void onItemDescriptionChanged(String value) {
    state = AsyncData(_current.copyWith(itemDescription: value));
  }

  void onItemTypeChanged(String value) {
    state = AsyncData(_current.copyWith(itemType: value));
  }

  void onPackageTypeChanged(String value) {
    state = AsyncData(_current.copyWith(packageType: value));
  }

  void onSelectedVehicleChanged(String value) {
    state = AsyncData(_current.copyWith(selectedVehicle: value));
  }

  void onSelectedInterStateVehicleChanged(String value) {
    state = AsyncData(_current.copyWith(selectedInterStateVehicle: value));
  }

  // Images
  void addImageUrl(String imageUrl) {
    final images = [..._current.imageUrls];

    if (!images.contains(imageUrl)) {
      images.add(imageUrl);
    }

    state = AsyncData(_current.copyWith(imageUrls: images));
  }

  void removeImageUrl(String imageUrl) {
    final images = [..._current.imageUrls];

    images.remove(imageUrl);

    state = AsyncData(_current.copyWith(imageUrls: images));
  }

  void clearImages() {
    state = AsyncData(_current.copyWith(imageUrls: []));
  }

  void setImageUrls(List<String> images) {
    state = AsyncData(_current.copyWith(imageUrls: images));
  }

  void resetCreatePackageOrder() {
    state = AsyncData(
      _current.copyWith(
        senderName: "",
        senderEmail: "",
        originAddress: "",
        originPhoneNo: "",
        originPostcodes: "",
        senderState: "",
        senderCity: "",
        senderCountry: "",
        originLatitude: 0,
        originLongitude: 0,
        receiverName: "",
        receiverEmail: "",
        receiverAddress: "",
        receiverPhoneNo: "",
        receiverPostcodes: "",
        receiverState: "",
        receiverCity: "",
        receiverCountry: "",
        receiverLatitude: 0,
        receiverLongitude: 0,
        packageName: "",
        itemCost: "",
        itemQuantity: "",
        itemWeight: "",
        itemModelNumber: "",
        itemDescription: "",
        itemType: "",
        packageType: "",
        selectedVehicle: "",
        selectedInterStateVehicle: "",
        imageUrls: [],
      ),
    );
  }

  Future<GeneralResultModel> createOrderWithAddress({
    required CreatePackageOrderRequest request,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.createOrderWithAddress(request);
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }

  Future<GeneralResultModel> makePayment({
    required String orderId,
    required bool paymentStatus,
    required String paymentChannel,
    required String trnxReference,
    required String paymentType,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.makePayment(
        orderId: orderId,
        paymentStatus: paymentStatus,
        paymentChannel: paymentChannel,
        trnxReference: trnxReference,
        paymentType: paymentType,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }

  Future<GeneralResultModel> updateOrder({
    required String orderId,
    required String reviewMessage,
    required double ratingNum,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.updateOrder(orderId: orderId);
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }
}
