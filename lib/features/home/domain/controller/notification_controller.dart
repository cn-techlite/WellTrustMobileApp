import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class NotificationController extends AsyncNotifier<NotificationStateModel> {
  late final HomeRepository _home;

  final Map<String, bool> fetchedNotificationById = {};
  final Map<String, NotificationResponseModel> _notificationCache = {};
  final Map<String, int> _notificationVisitCounter = {};

  @override
  FutureOr<NotificationStateModel> build() async {
    _home = ref.read(homeRepositoryProvider);
    return const NotificationStateModel();
  }

  NotificationStateModel get _current =>
      state.value ?? const NotificationStateModel();
  Future<void> getAllNotificationExploreData({
    bool forceRefresh = false,
  }) async {
    final current = state.value ?? const NotificationStateModel();
    final visit = current.visitCount + 1;

    if (!current.hasFetched || forceRefresh) {
      state = const AsyncLoading();

      final data = await _home.getAllNotificationData();
      _cacheList(data);
      state = AsyncData(
        current.copyWith(
          allNotification: data,
          hasFetched: true,
          visitCount: visit,
        ),
      );
    } else {
      final data = await _home.getAllNotificationData();
      _cacheList(data);
      state = AsyncData(
        current.copyWith(allNotification: data, visitCount: visit),
      );
    }
  }

  NotificationResponseModel? getNotificationById(String id) {
    return _notificationCache[id];
  }

  Future<void> getNotificationData({
    required String id,
    bool forceRefresh = false,
  }) async {
    final previous = _current;

    _notificationVisitCounter[id] = (_notificationVisitCounter[id] ?? 0) + 1;

    final visitCount = _notificationVisitCounter[id]!;
    final cached = _notificationCache[id];

    if (cached != null && visitCount > 1 && !forceRefresh) {
      state = AsyncData(previous.copyWith(singleData: cached));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _home.getNotificationData(id: id);

      if (response.id != null) {
        _notificationCache[response.id!] = response;
        fetchedNotificationById[response.id!] = true;
      }

      final list = [...previous.allNotification];

      final index = list.indexWhere((e) => e.id == response.id);

      if (index != -1) {
        list[index] = response;
      } else {
        list.insert(0, response);
      }

      return previous.copyWith(
        singleData: response,
        allNotification: list,
        hasFetched: true,
      );
    });
  }

  void _cacheList(List<NotificationResponseModel> items) {
    for (final item in items) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;

      _notificationCache[id] = item;
      fetchedNotificationById[id] = true;
    }
  }

  Future<GeneralResultModel> sendNotification({
    required String title,
    required String body,
    required String notificationType,
    required String deviceToken,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _home.sendNotification(
        title: title,
        body: body,
        notificationType: notificationType,
        deviceToken: deviceToken,
      );
    });

    state = AsyncData(previous);
    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Creation Of failed",
        );
  }

  Future<GeneralResultModel> sendNotificationRider({
    required String title,
    required String body,
    required String notificationType,
    required String riderDeviceToken,
    required String riderId,
  }) async {
    final previous = _current;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _home.sendNotificationRider(
        title: title,
        body: body,
        notificationType: notificationType,
        riderDeviceToken: riderDeviceToken,
        riderId: riderId,
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
