import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';

class AccountStateModel {
  final RegisterResponseModel? userData;

  /// Lists the profile call does not include. Loaded on their own.
  final List<StaffReference> references;
  final List<StaffSupervision> supervisions;
  final List<StaffProbation> probation;
  final List<StaffDeclaration> declarations;

  final bool hasFetchedAccount;
  final int accountVisitCount;

  final String? error;
  final String? successMessage;

  const AccountStateModel({
    this.userData,
    this.references = const [],
    this.supervisions = const [],
    this.probation = const [],
    this.declarations = const [],
    this.hasFetchedAccount = false,
    this.accountVisitCount = 0,

    this.error,
    this.successMessage,
  });

  AccountStateModel copyWith({
    RegisterResponseModel? userData,
    List<StaffReference>? references,
    List<StaffSupervision>? supervisions,
    List<StaffProbation>? probation,
    List<StaffDeclaration>? declarations,

    bool? hasFetchedAccount,
    int? accountVisitCount,

    String? error,
    String? successMessage,
  }) {
    return AccountStateModel(
      userData: userData ?? this.userData,
      references: references ?? this.references,
      supervisions: supervisions ?? this.supervisions,
      probation: probation ?? this.probation,
      declarations: declarations ?? this.declarations,

      hasFetchedAccount: hasFetchedAccount ?? this.hasFetchedAccount,
      accountVisitCount: accountVisitCount ?? this.accountVisitCount,

      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
