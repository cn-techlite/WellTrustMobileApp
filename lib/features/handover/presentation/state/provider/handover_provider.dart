import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

class HandoverState {
  final List<HandoverEntry> entries;

  /// Last time the carer marked each client's handover as read.
  final Map<String, DateTime> readAt;

  const HandoverState({required this.entries, required this.readAt});

  List<HandoverEntry> forClient(String id) =>
      entries.where((e) => e.clientId == id).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  int unreadFor(String id) {
    final read = readAt[id];
    return forClient(id)
        .where((e) => e.by != 'You' && (read == null || e.at.isAfter(read)))
        .length;
  }

  List<HandoverEntry> openFor(String id) =>
      forClient(id).where((e) => e.isOpen).toList();

  int get unreadTotal => handoverClients.fold(0, (n, c) => n + unreadFor(c.id));
}

class HandoverNotifier extends Notifier<HandoverState> {
  @override
  HandoverState build() =>
      HandoverState(entries: sampleHandover(), readAt: const {});

  void add(HandoverEntry entry) {
    state = HandoverState(
      entries: [...state.entries, entry],
      readAt: state.readAt,
    );
  }

  void markDone(String id, String who) {
    state = HandoverState(
      entries: [
        for (final e in state.entries) e.id == id ? e.markDone(who) : e,
      ],
      readAt: state.readAt,
    );
  }

  void markRead(String clientId) {
    state = HandoverState(
      entries: state.entries,
      readAt: {...state.readAt, clientId: DateTime.now()},
    );
  }
}

final handoverProvider = NotifierProvider<HandoverNotifier, HandoverState>(
  HandoverNotifier.new,
);
