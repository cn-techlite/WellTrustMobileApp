//AdvertExplore
import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/home_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/advert_state.dart';

class AdvertController extends AsyncNotifier<AdvertStateModel> {
  late final HomeRepository _home;

  @override
  FutureOr<AdvertStateModel> build() async {
    _home = ref.read(homeRepositoryProvider);
    return const AdvertStateModel();
  }

  Future<void> getAllAdvertExploreData({bool forceRefresh = false}) async {
    final current = state.value ?? const AdvertStateModel();
    final visit = current.visitCount + 1;

    if (!current.hasFetched || forceRefresh) {
      state = const AsyncLoading();

      final data = await _home.getAllAdvertisements();

      state = AsyncData(
        current.copyWith(explore: data, hasFetched: true, visitCount: visit),
      );
    } else {
      final data = await _home.getAllAdvertisements();

      state = AsyncData(current.copyWith(explore: data, visitCount: visit));
    }
  }
}
