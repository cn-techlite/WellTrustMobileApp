import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:well_trust_mobile_app/features/home/data/repository/meeting_repository_impl.dart';
import 'package:well_trust_mobile_app/features/home/data/service/meeting_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/controller/meeting_controller.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/meeting_repository.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/meeting_state.dart';

final meetingRemoteServiceProvider = Provider<MeetingRemoteService>((ref) {
  return MeetingRemoteService();
});

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepositoryImpl(
    remoteService: ref.read(meetingRemoteServiceProvider),
  );
});

final meetingsProvider = AsyncNotifierProvider<MeetingController, MeetingState>(
  MeetingController.new,
);
