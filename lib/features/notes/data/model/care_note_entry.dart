class CareNoteEntry {
  final String id;
  final String clientId;
  final DateTime at;
  final String mood;
  final String intake;
  final String skin;
  final String text;
  final bool flagged;
  final String clientName;
  final String staffName;
  final List<String> tags;
  final DateTime? visitDate;
  final String? startTime;
  final String? endTime;
  final String? supportType;
  final String? outcome;

  const CareNoteEntry({
    required this.id,
    required this.clientId,
    required this.at,
    required this.mood,
    required this.intake,
    required this.skin,
    required this.text,
    required this.flagged,
    this.clientName = '',
    this.staffName = '',
    this.tags = const [],
    this.visitDate,
    this.startTime,
    this.endTime,
    this.supportType,
    this.outcome,
  });

  factory CareNoteEntry.fromJson(Map<String, dynamic> json) => CareNoteEntry(
    id: (json['id'] ?? '').toString(),
    clientId: (json['clientId'] ?? '').toString(),
    clientName: (json['clientName'] ?? '').toString(),
    staffName: (json['staffName'] ?? '').toString(),
    at:
        DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
    mood: (json['mood'] ?? '').toString(),
    intake: (json['intake'] ?? '').toString(),
    skin: (json['skin'] ?? '').toString(),
    text: (json['text'] ?? '').toString(),
    flagged: json['flagged'] == true,
    tags: [
      for (final tag in (json['tags'] as List? ?? const [])) tag.toString(),
    ],
    visitDate: json['visitDate'] != null
        ? DateTime.tryParse(json['visitDate'].toString())
        : null,
    startTime: json['startTime']?.toString(),
    endTime: json['endTime']?.toString(),
    supportType: json['supportType']?.toString(),
    outcome: json['outcome']?.toString(),
  );
}
