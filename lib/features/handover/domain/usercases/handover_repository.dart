import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

abstract class HandoverRepository {
  Future<List<HandoverEntry>> getHandovers({String? clientId, bool? openOnly});
  Future<HandoverEntry> create(HandoverEntry entry);
  Future<HandoverEntry> resolve(String id, String note);
  Future<void> markRead(String clientId);
}
