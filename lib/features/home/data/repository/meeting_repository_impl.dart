import 'package:well_trust_mobile_app/features/home/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/home/data/service/meeting_remote_service.dart';
import 'package:well_trust_mobile_app/features/home/domain/usecases/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteService _remoteService;

  const MeetingRepositoryImpl({required MeetingRemoteService remoteService})
    : _remoteService = remoteService;

  @override
  Future<List<TeamMeeting>> getMeetings() => _remoteService.getMeetings();
}
