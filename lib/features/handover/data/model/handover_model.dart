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
  final Map<String, String> details;
  final bool needsFollowUp;
  final String followUpFor;
  final DateTime? followUpDue;
  final bool resolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String resolutionNote;

  const HandoverEntry({
    required this.id,
    required this.clientId,
    required this.at,
    required this.by,
    required this.kind,
    required this.priority,
    required this.text,
    this.details = const {},
    this.needsFollowUp = false,
    this.followUpFor = 'Next carer',
    this.followUpDue,
    this.resolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNote = '',
  });

  factory HandoverEntry.fromJson(Map<String, dynamic> json) => HandoverEntry(
    id: (json['id'] ?? '').toString(),
    clientId: (json['clientId'] ?? '').toString(),
    at:
        DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
    by: (json['staffName'] ?? '').toString(),
    kind: _handoverKind((json['kind'] ?? '').toString()),
    priority: _handoverPriority((json['priority'] ?? '').toString()),
    text: (json['text'] ?? '').toString(),
    details: {
      for (final entry
          in (json['details'] is Map
                  ? Map<String, dynamic>.from(json['details'] as Map)
                  : const <String, dynamic>{})
              .entries)
        entry.key: (entry.value ?? '').toString(),
    },
    needsFollowUp: json['needsFollowUp'] == true,
    followUpFor: (json['followUpFor'] ?? 'Next carer').toString(),
    followUpDue: DateTime.tryParse(
      (json['followUpDue'] ?? '').toString(),
    )?.toLocal(),
    resolved: json['resolved'] == true,
    resolvedBy: json['resolvedBy']?.toString(),
    resolvedAt: DateTime.tryParse(
      (json['resolvedAt'] ?? '').toString(),
    )?.toLocal(),
    resolutionNote: (json['resolutionNote'] ?? '').toString(),
  );

  bool get isOpen =>
      !resolved &&
      (needsFollowUp ||
          kind == HandoverKind.concern ||
          kind == HandoverKind.todo ||
          priority == HandoverPriority.urgent);

  HandoverEntry markDone(
    String who, {
    DateTime? completedAt,
    String note = '',
  }) => HandoverEntry(
    id: id,
    clientId: clientId,
    at: at,
    by: by,
    kind: kind,
    priority: priority,
    text: text,
    details: details,
    needsFollowUp: needsFollowUp,
    followUpFor: followUpFor,
    followUpDue: followUpDue,
    resolved: true,
    resolvedBy: who,
    resolvedAt: completedAt ?? DateTime.now(),
    resolutionNote: note,
  );
}

HandoverKind _handoverKind(String value) => switch (value.toLowerCase()) {
  'concern' => HandoverKind.concern,
  'change' => HandoverKind.change,
  'todo' || 'to do' => HandoverKind.todo,
  'visitsummary' || 'visit summary' => HandoverKind.visitSummary,
  _ => HandoverKind.info,
};

HandoverPriority _handoverPriority(String value) =>
    switch (value.toLowerCase()) {
      'important' => HandoverPriority.important,
      'urgent' => HandoverPriority.urgent,
      _ => HandoverPriority.routine,
    };
