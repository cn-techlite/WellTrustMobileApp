import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/account/data/repository/account_repository_impl.dart';
import 'package:ginilog_customer_app/features/account/data/services/account_remote_services.dart';
import 'package:ginilog_customer_app/features/account/domain/controller/account_controller.dart';
import 'package:ginilog_customer_app/features/account/domain/usercases/account_repository.dart';
import 'package:ginilog_customer_app/features/account/presentation/state/provider/account_provider.dart';

final accountRemoteServiceProvider = Provider<AccountRemoteService>((ref) {
  return AccountRemoteService();
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.read(accountRemoteServiceProvider));
});

final accountProvider =
    AsyncNotifierProvider<AccountController, AccountStateModel>(
      AccountController.new,
    );
