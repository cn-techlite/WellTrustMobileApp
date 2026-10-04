import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

class HandoverState {
  final List<HandoverEntry> entries;
  final Map<String, DateTime> readAt;

  const HandoverState({this.entries = const [], this.readAt = const {}});

  List<HandoverEntry> forClient(String id) =>
      entries.where((entry) => entry.clientId == id).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  int unreadFor(String id) {
    final read = readAt[id];
    return forClient(id)
        .where(
          (entry) =>
              entry.by != 'You' && (read == null || entry.at.isAfter(read)),
        )
        .length;
  }

  List<HandoverEntry> openFor(String id) =>
      forClient(id).where((entry) => entry.isOpen).toList();

  int get unreadTotal => entries
      .map((entry) => entry.clientId)
      .toSet()
      .fold(0, (total, clientId) => total + unreadFor(clientId));
}
