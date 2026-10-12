import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/account/data/repository/abc_chart_repository_impl.dart';
import 'package:well_trust_mobile_app/features/account/data/service/abc_chart_remote_service.dart';
import 'package:well_trust_mobile_app/features/account/domain/controller/abc_chart_controller.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/abc_chart_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/abc_chart_state.dart';

final abcChartRemoteServiceProvider = Provider<AbcChartRemoteService>((ref) {
  return AbcChartRemoteService();
});

final abcChartRepositoryProvider = Provider<AbcChartRepository>((ref) {
  return AbcChartRepositoryImpl(
    remoteService: ref.read(abcChartRemoteServiceProvider),
  );
});

final abcChartProvider = NotifierProvider<AbcChartController, AbcChartState>(
  AbcChartController.new,
);
