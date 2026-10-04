import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';

abstract class MeetingRepository {
  Future<List<TeamMeeting>> getMeetings();
}
