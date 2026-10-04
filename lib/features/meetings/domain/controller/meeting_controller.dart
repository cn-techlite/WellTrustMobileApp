import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/meetings/domain/usercases/meeting_repository.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/state/providers/meeting_provider.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/state/state_model/meeting_state.dart';

class MeetingController extends AsyncNotifier<MeetingState> {
  late final MeetingRepository _repository;

  @override
  FutureOr<MeetingState> build() async {
    _repository = ref.read(meetingRepositoryProvider);
    if (!hasActiveSession) return const MeetingState();
    return MeetingState(meetings: await _repository.getMeetings());
  }

  Future<void> refresh() async {
    state = const AsyncLoading<MeetingState>();
    state = await AsyncValue.guard(
      () async => MeetingState(meetings: await _repository.getMeetings()),
    );
  }
}
