import 'package:ginilog_customer_app/features/account/data/model/user_response_model.dart';

class AccountStateModel {
  final RegisterResponseModel? userData;

  final bool hasFetchedAccount;
  final int accountVisitCount;

  final String? error;
  final String? successMessage;

  const AccountStateModel({
    this.userData,
    this.hasFetchedAccount = false,
    this.accountVisitCount = 0,

    this.error,
    this.successMessage,
  });

  AccountStateModel copyWith({
    RegisterResponseModel? userData,

    bool? hasFetchedAccount,
    int? accountVisitCount,

    String? error,
    String? successMessage,
  }) {
    return AccountStateModel(
      userData: userData ?? this.userData,

      hasFetchedAccount: hasFetchedAccount ?? this.hasFetchedAccount,
      accountVisitCount: accountVisitCount ?? this.accountVisitCount,

      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
