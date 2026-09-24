/// Care handover between carers and the office.
enum HandoverKind { info, concern, change, todo, visitSummary }

enum HandoverPriority { routine, important, urgent }

extension HandoverKindLabel on HandoverKind {
  String get label => switch (this) {
    HandoverKind.info => 'Info',
    HandoverKind.concern => 'Concern',
    HandoverKind.change => 'Change',
    HandoverKind.todo => 'To do',
    HandoverKind.visitSummary => 'Visit summary',
  };
}

extension HandoverPriorityLabel on HandoverPriority {
  String get label => switch (this) {
    HandoverPriority.routine => 'Routine',
    HandoverPriority.important => 'Important',
    HandoverPriority.urgent => 'Urgent',
  };
}

class HandoverEntry {
  final String id;
  final String clientId;
  final DateTime at;
  final String by;
  final HandoverKind kind;
  final HandoverPriority priority;
  final String text;
  final bool needsFollowUp;
  final String followUpFor;
  final bool resolved;
  final String? resolvedBy;

  const HandoverEntry({
    required this.id,
    required this.clientId,
    required this.at,
    required this.by,
    required this.kind,
    required this.priority,
    required this.text,
    this.needsFollowUp = false,
    this.followUpFor = 'Next carer',
    this.resolved = false,
    this.resolvedBy,
  });

  bool get isOpen =>
      !resolved &&
      (needsFollowUp ||
          kind == HandoverKind.concern ||
          kind == HandoverKind.todo ||
          priority == HandoverPriority.urgent);

  HandoverEntry markDone(String who) => HandoverEntry(
    id: id,
    clientId: clientId,
    at: at,
    by: by,
    kind: kind,
    priority: priority,
    text: text,
    needsFollowUp: needsFollowUp,
    followUpFor: followUpFor,
    resolved: true,
    resolvedBy: who,
  );
}

class HandoverClient {
  final String id;
  final String name;
  final String preferred;
  final String nextVisit;
  final bool visitToday;

  const HandoverClient({
    required this.id,
    required this.name,
    required this.preferred,
    required this.nextVisit,
    this.visitToday = false,
  });
}

const handoverClients = <HandoverClient>[
  HandoverClient(
    id: 'U1',
    name: 'Mr Harold Fisher',
    preferred: 'Harold',
    nextVisit: 'Today 09:00',
    visitToday: true,
  ),
  HandoverClient(
    id: 'U2',
    name: 'Mrs Margaret Hensley',
    preferred: 'Margaret',
    nextVisit: 'Today 10:00',
    visitToday: true,
  ),
  HandoverClient(
    id: 'U3',
    name: 'Mrs Dorothy Bell',
    preferred: 'Dorothy',
    nextVisit: 'Today 13:00',
    visitToday: true,
  ),
  HandoverClient(
    id: 'U4',
    name: 'Mr Suresh Patel',
    preferred: 'Suresh',
    nextVisit: 'Tomorrow 17:30',
  ),
  HandoverClient(
    id: 'U5',
    name: 'Mrs Joan Whitmore',
    preferred: 'Joan',
    nextVisit: 'Today',
    visitToday: true,
  ),
  HandoverClient(
    id: 'U6',
    name: 'Mr George Adeyemi',
    preferred: 'George',
    nextVisit: 'Thu 20:30',
  ),
];

List<HandoverEntry> sampleHandover() {
  final now = DateTime.now();
  DateTime ago(int h) => now.subtract(Duration(hours: h));
  return [
    HandoverEntry(
      id: 'H1',
      clientId: 'U1',
      at: ago(5),
      by: 'Sarah Williams',
      kind: HandoverKind.concern,
      priority: HandoverPriority.urgent,
      text:
          'Harold was more tired than usual and ate very little at lunch. Check his sugar readings and tell the office if they are low.',
      needsFollowUp: true,
    ),
    HandoverEntry(
      id: 'H2',
      clientId: 'U1',
      at: ago(30),
      by: 'Office',
      kind: HandoverKind.todo,
      priority: HandoverPriority.important,
      text:
          'The GP is visiting on Tuesday at 11:00. Please make sure Harold is dressed and ready.',
      needsFollowUp: true,
      followUpFor: 'Anyone',
    ),
    HandoverEntry(
      id: 'H3',
      clientId: 'U1',
      at: ago(48),
      by: 'John Jones',
      kind: HandoverKind.info,
      priority: HandoverPriority.routine,
      text:
          'The new pressure-relieving cushion has arrived. Please keep it on his chair.',
    ),
    HandoverEntry(
      id: 'H4',
      clientId: 'U2',
      at: ago(20),
      by: 'Office',
      kind: HandoverKind.change,
      priority: HandoverPriority.important,
      text:
          "Margaret's hoist sling has changed to the blue one. Check the label before every transfer.",
    ),
    HandoverEntry(
      id: 'H5',
      clientId: 'U2',
      at: ago(26),
      by: 'Sarah Williams',
      kind: HandoverKind.visitSummary,
      priority: HandoverPriority.routine,
      text:
          'Good visit. Skin is intact. She likes the bedroom window open in the mornings.',
    ),
    HandoverEntry(
      id: 'H6',
      clientId: 'U3',
      at: ago(8),
      by: 'John Jones',
      kind: HandoverKind.concern,
      priority: HandoverPriority.important,
      text:
          'Dorothy refused her lunchtime tablets twice this week. This has been reported to the office. Do not force her. Record it each time.',
      needsFollowUp: true,
      followUpFor: 'Office',
    ),
    HandoverEntry(
      id: 'H7',
      clientId: 'U4',
      at: ago(40),
      by: 'David Eze',
      kind: HandoverKind.visitSummary,
      priority: HandoverPriority.routine,
      text:
          'His speech is improving. Give him time to answer and do not finish his sentences.',
    ),
    HandoverEntry(
      id: 'H8',
      clientId: 'U5',
      at: ago(12),
      by: 'Office',
      kind: HandoverKind.change,
      priority: HandoverPriority.important,
      text:
          'Joan has a new pendant alarm. Test it at every visit and tell the office if it does not connect.',
      needsFollowUp: true,
    ),
    HandoverEntry(
      id: 'H9',
      clientId: 'U6',
      at: ago(48),
      by: 'Office',
      kind: HandoverKind.todo,
      priority: HandoverPriority.routine,
      text:
          'The oxygen supplier visits on Thursday morning. No candles or naked flames in the house.',
      needsFollowUp: true,
      followUpFor: 'Anyone',
    ),
  ];
}
