class AbcChartEntry {
  final String id;
  final String residentId;
  final String companyId;
  final DateTime episodeDate;
  final String? episodeTime;
  final String location;
  final String antecedent;
  final String behaviour;
  final String duration;
  final String consequence;
  final String? possibleFunction;
  final String staffInvolved;
  final String recordedBy;
  final String recordedByStaffId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AbcChartEntry({
    required this.id,
    required this.residentId,
    required this.companyId,
    required this.episodeDate,
    required this.episodeTime,
    required this.location,
    required this.antecedent,
    required this.behaviour,
    required this.duration,
    required this.consequence,
    required this.possibleFunction,
    required this.staffInvolved,
    required this.recordedBy,
    required this.recordedByStaffId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbcChartEntry.fromJson(Map<String, dynamic> json) => AbcChartEntry(
    id: (json['id'] ?? '').toString(),
    residentId: (json['residentId'] ?? '').toString(),
    companyId: (json['companyId'] ?? '').toString(),
    episodeDate:
        DateTime.tryParse((json['episodeDate'] ?? '').toString()) ??
        DateTime.now(),
    episodeTime: _nullableText(json['episodeTime']),
    location: (json['location'] ?? '').toString(),
    antecedent: (json['antecedent'] ?? '').toString(),
    behaviour: (json['behaviour'] ?? '').toString(),
    duration: (json['duration'] ?? '').toString(),
    consequence: (json['consequence'] ?? '').toString(),
    possibleFunction: _nullableText(json['possibleFunction']),
    staffInvolved: (json['staffInvolved'] ?? '').toString(),
    recordedBy: (json['recordedBy'] ?? '').toString(),
    recordedByStaffId: (json['recordedByStaffId'] ?? '').toString(),
    createdAt: DateTime.tryParse(
      (json['createdAt'] ?? '').toString(),
    )?.toLocal(),
    updatedAt: DateTime.tryParse(
      (json['updatedAt'] ?? '').toString(),
    )?.toLocal(),
  );

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class AbcChartDraft {
  final String residentId;
  final DateTime episodeDate;
  final String? episodeTime;
  final String location;
  final String antecedent;
  final String behaviour;
  final String duration;
  final String consequence;
  final String? possibleFunction;
  final String staffInvolved;

  const AbcChartDraft({
    required this.residentId,
    required this.episodeDate,
    this.episodeTime,
    this.location = '',
    required this.antecedent,
    required this.behaviour,
    this.duration = '',
    required this.consequence,
    this.possibleFunction,
    this.staffInvolved = '',
  });
}
