import 'dart:async';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/constants.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/account_state_model.dart';
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
        _syncGlobals(response);
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
      _syncGlobals(response);
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

  /// Runs a save, then quietly re-reads the profile so every screen shows what
  /// the API now holds. The current data stays on screen meanwhile, unlike
  /// [getAccount], which swaps it for a spinner.
  Future<GeneralResultModel> _saveThenRefresh(
    Future<GeneralResultModel> Function() save,
    String failureMessage, {
    bool references = false,
  }) async {
    final result = await AsyncValue.guard(save);

    if (result.hasError) {
      state = AsyncData(
        _current.copyWith(error: result.error.toString(), successMessage: null),
      );
      return GeneralResultModel(
        isSuccess: false,
        message: result.error.toString(),
      );
    }

    final saved = result.value ?? GeneralResultModel.failure(failureMessage);
    if (!saved.isSuccess) return saved;

    try {
      final fresh = await _repository.getUserData();
      _syncGlobals(fresh);
      state = AsyncData(
        _current.copyWith(userData: fresh, hasFetchedAccount: true),
      );
    } catch (_) {
      // The save worked; the next refresh will show it.
    }
    if (references) await loadReferences();
    return saved;
  }

  /// Keeps the name shown in the header and greeting current.
  void _syncGlobals(RegisterResponseModel user) {
    final name = "${user.firstName ?? ''} ${user.surName ?? ''}".trim();
    if (name.isNotEmpty) globals.userName = name;
  }

  Future<GeneralResultModel> updateProfile(UpdateStaffRequest request) {
    return _saveThenRefresh(
      () => _repository.updateProfile(request),
      "Profile update failed",
    );
  }

  /// Adds a list record, or sets job details / emergency contact.
  Future<GeneralResultModel> saveStaffRecord(StaffRecordRequest request) {
    final adminStaffId = _current.userData?.id ?? globals.userId;
    return _saveThenRefresh(
      () => _repository.saveStaffRecord(request, adminStaffId: adminStaffId),
      "${request.kind.label} could not be saved",
      references: request.kind == StaffRecordKind.references,
    );
  }

  Future<GeneralResultModel> updateStaffRecord(
    String id,
    StaffRecordRequest request,
  ) {
    return _saveThenRefresh(
      () => _repository.updateStaffRecord(id, request),
      "${request.kind.label} could not be updated",
      references: request.kind == StaffRecordKind.references,
    );
  }

  Future<GeneralResultModel> deleteStaffRecord(
    StaffRecordKind kind,
    String id,
  ) {
    return _saveThenRefresh(
      () => _repository.deleteStaffRecord(kind, id),
      "${kind.label} could not be deleted",
      references: kind == StaffRecordKind.references,
    );
  }

  /// Emails the referee a link to the reference portal.
  Future<GeneralResultModel> sendReferenceRequest(String id) {
    return _saveThenRefresh(
      () => _repository.sendReferenceRequest(id),
      "The request could not be sent",
      references: true,
    );
  }

  String get _ownId => _current.userData?.id ?? globals.userId;

  /// Loads the carer's referees. The profile call does not include them.
  /// Keeps what is on screen if it fails.
  Future<void> loadReferences() async {
    try {
      final rows = await _repository.getReferences(_ownId);
      state = AsyncData(_current.copyWith(references: rows));
    } catch (e) {
      state = AsyncData(_current.copyWith(error: e.toString()));
    }
  }

  /// Loads the carer's own supervisions, probation and declarations. Each is
  /// loaded on its own, so one failing does not hide the others. Returns an
  /// error message if any of them failed, else null.
  Future<String?> loadOfficeRecords() async {
    String? error;
    Future<T> guarded<T>(Future<T> Function() load, T fallback) async {
      try {
        return await load();
      } catch (e) {
        error = e.toString();
        return fallback;
      }
    }

    final id = _ownId;
    final supervisions = await guarded(
      () => _repository.getSupervisions(id),
      _current.supervisions,
    );
    final probation = await guarded(
      () => _repository.getProbation(id),
      _current.probation,
    );
    final declarations = await guarded(
      () => _repository.getDeclarations(id),
      _current.declarations,
    );
    state = AsyncData(
      _current.copyWith(
        supervisions: supervisions,
        probation: probation,
        declarations: declarations,
      ),
    );
    return error;
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
