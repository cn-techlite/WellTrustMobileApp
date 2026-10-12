import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';

class AbcChartState {
  final String? residentId;
  final List<AbcChartEntry> entries;
  final bool isLoading;
  final String? error;

  const AbcChartState({
    this.residentId,
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });
}
