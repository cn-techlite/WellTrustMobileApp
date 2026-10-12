import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/abc_chart_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/abc_chart_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/abc_chart_state.dart';

class AbcChartController extends Notifier<AbcChartState> {
  late final AbcChartRepository _repository;

  @override
  AbcChartState build() {
    _repository = ref.read(abcChartRepositoryProvider);
    return const AbcChartState();
  }

  Future<void> loadForClient(String residentId) async {
    if (!hasActiveSession) {
      state = AbcChartState(
        residentId: residentId,
        error: 'You must be signed in.',
      );
      return;
    }

    state = AbcChartState(residentId: residentId, isLoading: true);
    try {
      final entries = await _repository.getForClient(residentId);
      if (state.residentId != residentId) return;
      state = AbcChartState(residentId: residentId, entries: entries);
    } catch (error) {
      if (state.residentId != residentId) return;
      state = AbcChartState(residentId: residentId, error: error.toString());
    }
  }

  Future<AbcChartEntry> create(AbcChartDraft draft) async {
    if (!hasActiveSession) throw StateError('You must be signed in.');
    final saved = await _repository.create(draft);
    if (state.residentId == draft.residentId) {
      state = AbcChartState(
        residentId: state.residentId,
        entries: [saved, ...state.entries],
      );
    }
    return saved;
  }
}
