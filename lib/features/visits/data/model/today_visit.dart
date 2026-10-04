class VisitTask {
  final String id;
  final String label;
  final bool medication;
  final bool completed;
  const VisitTask(
    this.label, {
    this.id = '',
    this.medication = false,
    this.completed = false,
  });

  factory VisitTask.fromJson(Map<String, dynamic> json) => VisitTask(
    (json['label'] ?? '').toString(),
    id: (json['id'] ?? '').toString(),
    medication: json['medication'] == true,
    completed: json['completed'] == true,
  );
}

/// Where a visit sits in the carer's day (design `visitState`).
enum TodayVisitState { upcoming, due, active, overdue, done }

/// One visit on the carer's round today.
class TodayVisit {
  final String id;
  final String clientId;
  final String name;
  final String preferred;
  final String address;
  final String phone;

  /// The client's home, for the "how far away are you" check at clock-in.
  /// Null when it is not known.
  final double? latitude;
  final double? longitude;
  final DateTime start;
  final int minutes;

  /// Minutes of travel from the previous visit.
  final int travelMins;
  final String withStaff;
  final String type;
  final String accessType;
  final String accessCode;
  final String accessNote;
  final List<String> thingsToKnow;
  final List<VisitTask> tasks;
  final String status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool requiresFollowUp;

  const TodayVisit({
    required this.id,
    required this.clientId,
    required this.name,
    required this.preferred,
    required this.address,
    required this.phone,
    this.latitude,
    this.longitude,
    required this.start,
    required this.minutes,
    required this.travelMins,
    required this.type,
    required this.accessType,
    required this.accessCode,
    required this.accessNote,
    required this.thingsToKnow,
    required this.tasks,
    this.withStaff = '',
    this.status = 'Scheduled',
    this.checkInAt,
    this.checkOutAt,
    this.requiresFollowUp = false,
  });

  factory TodayVisit.fromJson(Map<String, dynamic> json) {
    final start =
        DateTime.tryParse(
          (json['scheduledStart'] ?? '').toString(),
        )?.toLocal() ??
        DateTime.now();
    final end = DateTime.tryParse(
      (json['scheduledEnd'] ?? '').toString(),
    )?.toLocal();
    final duration =
        (json['durationMinutes'] as num?)?.toInt() ??
        (end == null ? 0 : end.difference(start).inMinutes);
    final things = (json['thingsToKnow'] ?? '').toString().trim();
    return TodayVisit(
      id: (json['id'] ?? '').toString(),
      clientId: (json['clientId'] ?? '').toString(),
      name: (json['clientName'] ?? '').toString(),
      preferred: ((json['preferredName'] ?? json['clientName']) ?? '')
          .toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      start: start,
      minutes: duration,
      travelMins: (json['travelMinutes'] as num?)?.toInt() ?? 0,
      type: (json['visitType'] ?? '').toString(),
      accessType: (json['accessType'] ?? '').toString(),
      accessCode: (json['accessCode'] ?? '').toString(),
      accessNote: (json['accessNote'] ?? '').toString(),
      thingsToKnow: things.isEmpty ? const [] : [things],
      tasks: [
        for (final item in (json['tasks'] as List? ?? const []))
          if (item is Map) VisitTask.fromJson(Map<String, dynamic>.from(item)),
      ],
      withStaff: (json['withStaff'] ?? '').toString(),
      status: (json['status'] ?? 'Scheduled').toString(),
      checkInAt: DateTime.tryParse(
        (json['checkInAt'] ?? '').toString(),
      )?.toLocal(),
      checkOutAt: DateTime.tryParse(
        (json['checkOutAt'] ?? '').toString(),
      )?.toLocal(),
      requiresFollowUp: json['requiresFollowUp'] == true,
    );
  }

  DateTime get end => start.add(Duration(minutes: minutes));

  bool get canStart =>
      const {'Scheduled', 'Assigned', 'Accepted'}.contains(status);
  bool get isInProgress => status.toLowerCase() == 'inprogress';
  bool get isCompleted => status.toLowerCase() == 'completed';
}

String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "45 min", "1 h" or "1 h 5 min".
String formatMinutes(int m) {
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}
