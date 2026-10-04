import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/meetings/data/service/meeting_remote_service.dart';
import 'package:well_trust_mobile_app/features/meetings/domain/usercases/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteService _remoteService;

  const MeetingRepositoryImpl({required MeetingRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<TeamMeeting>> getMeetings() => _remoteService.getMeetings();
}
