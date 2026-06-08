import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/states/account_provider.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class AccountController extends AsyncNotifier<AccountStateModel> {
  late final AccountRepository _repository;

  @override
  FutureOr<AccountStateModel> build() {
    _repository = ref.read(accountRepositoryProvider);

    return const AccountStateModel(
      userData: null,
      hasFetchedAccount: false,
      accountVisitCount: 0,
      error: null,
      successMessage: null,
    );
  }

  AccountStateModel get _current => state.value ?? const AccountStateModel();

  Future<void> getAccount({bool forceRefresh = false}) async {
    final current = state.value ?? const AccountStateModel();
    final newVisit = current.accountVisitCount + 1;

    // If not fetched before or forced, show loading once.
    if (!current.hasFetchedAccount || forceRefresh) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final response = await _repository.getUserData();
        return current.copyWith(
          userData: response,
          hasFetchedAccount: true,
          accountVisitCount: newVisit,
        );
      });
      return;
    }
    // Already fetched: do a background refresh (no global loading)
    try {
      final response = await _repository.getUserData();
      state = AsyncData(
        current.copyWith(
          userData: response,
          accountVisitCount: newVisit,
          hasFetchedAccount: true,
          successMessage: "Account Loaded",
          error: null,
        ),
      );
    } catch (e, st) {
      // keep old data but surface error
      state = AsyncData(
        current.copyWith(error: "${e.toString()} ${st.toString()}"),
      );
    }
  }

  Future<void> refreshAccount() async {
    await getAccount(forceRefresh: true);
  }

  Future<GeneralResultModel> updateProfile({
    required String firstName,
    required String lastName,
    required String imageFile,
    required String phoneNo,
    required bool availability,
  }) async {
    final previous = _current;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        imageFile: imageFile,
        phoneNo: phoneNo,
        availability: availability,
      );
    });

    if (result.hasError) {
      state = AsyncData(
        previous.copyWith(error: result.error.toString(), successMessage: null),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    await getAccount(forceRefresh: true);

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Profile update failed",
        );
  }

  Future<GeneralResultModel> addNewAddress({
    required String userId,
    required String address,
    required String addressPostCodes,
    required String houseNo,
    required String city,
    required String stateFile,
    required double latitude,
    required double longitude,
    required String phoneNo,
    required String userName,
  }) async {
    final previous = _current;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.addNewAddress(
        userId: userId,
        address: address,
        addressPostCodes: addressPostCodes,
        houseNo: houseNo,
        city: city,
        state: stateFile,
        latitude: latitude,
        longitude: longitude,
        phoneNo: phoneNo,
        userName: userName,
      );
    });

    if (result.hasError) {
      state = AsyncData(
        previous.copyWith(error: result.error.toString(), successMessage: null),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    await getAccount(forceRefresh: true);

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Address creation failed",
        );
  }

  Future<GeneralResultModel> updateAddress({
    required String addressId,
    required String address,
    required String addressPostCodes,
    required String houseNo,
    required String city,
    required double latitude,
    required double longitude,
    required String phoneNo,
    required String userName,
  }) async {
    final previous = _current;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.updateAddress(
        addressId: addressId,
        address: address,
        addressPostCodes: addressPostCodes,
        houseNo: houseNo,
        city: city,
        latitude: latitude,
        longitude: longitude,
        phoneNo: phoneNo,
        userName: userName,
      );
    });

    if (result.hasError) {
      state = AsyncData(
        previous.copyWith(error: result.error.toString(), successMessage: null),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    await getAccount(forceRefresh: true);

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Address update failed",
        );
  }

  Future<GeneralResultModel> deleteDeliveryAddress({
    required String addressId,
  }) async {
    final previous = _current;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.deleteDeliveryAddress(addressId: addressId);
    });

    if (result.hasError) {
      state = AsyncData(
        previous.copyWith(error: result.error.toString(), successMessage: null),
      );

      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    await getAccount(forceRefresh: true);

    return result.value ??
        const GeneralResultModel(
          isSuccess: false,
          message: "Address delete failed",
        );
  }

  Future<GeneralResultModel> sendFeedBack({
    required String feedback,
    required String phoneNo,
  }) async {
    final previous = _current;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await _repository.sendFeedBack(
        feedback: feedback,
        phoneNo: phoneNo,
      );
    });

    state = AsyncData(previous);

    if (result.hasError) {
      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    return result.value ??
        const GeneralResultModel(isSuccess: false, message: "Feedback failed");
  }

  Future<void> handleSignOut() async {
    removeFromLocalStorage(name: "token");
    removeFromLocalStorage(name: "userEmail");
    removeFromLocalStorage(name: "userId");
    removeFromLocalStorage(name: "userPassword");
    removeFromLocalStorage(name: "deviceToken");
    removeFromLocalStorage(name: "state");
    removeFromLocalStorage(name: "city");
    removeFromLocalStorage(name: "address");
    removeFromLocalStorage(name: "latitude");
    removeFromLocalStorage(name: "longitude");

    state = const AsyncData(AccountStateModel());
  }
}
