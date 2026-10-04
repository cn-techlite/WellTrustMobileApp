import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/repository/account_repository_impl.dart';
import 'package:well_trust_mobile_app/features/account/data/service/account_remote_service.dart';
import 'package:well_trust_mobile_app/features/account/domain/controller/account_controller.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/account_state_model.dart';

final accountRemoteServiceProvider = Provider<AccountRemoteService>((ref) {
  return AccountRemoteService();
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.read(accountRemoteServiceProvider));
});

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, AccountStateModel>(
      AccountController.new,
    );
