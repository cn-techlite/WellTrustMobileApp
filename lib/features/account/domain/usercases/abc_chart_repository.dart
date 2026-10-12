import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';

abstract class AbcChartRepository {
  Future<List<AbcChartEntry>> getForClient(String clientId);
  Future<AbcChartEntry> create(AbcChartDraft draft);
}
