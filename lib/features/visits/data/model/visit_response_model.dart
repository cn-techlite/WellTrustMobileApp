enum VisitStatus { scheduled, inProgress, complete, missed }

extension VisitStatusX on VisitStatus {
  String get wire => switch (this) {
    VisitStatus.scheduled => 'scheduled',
    VisitStatus.inProgress => 'in-progress',
    VisitStatus.complete => 'complete',
    VisitStatus.missed => 'missed',
  };
}

class VisitResponseModel {
  final String id;
  final String suId;
  final String start; // HH:MM
  final String end; // HH:MM
  final int duration; // minutes (scheduled)
  final String type; // key into visitTypes
  final int travelMin;
  VisitStatus status;
  String? actualStart;
  String? actualEnd;
  final List<String> tasks;
  String? gapReason;
  String visitNotes;
  final Set<int> completedTaskIdx = {};

  VisitResponseModel({
    required this.id,
    required this.suId,
    required this.start,
    required this.end,
    required this.duration,
    required this.type,
    required this.travelMin,
    required this.status,
    this.actualStart,
    this.actualEnd,
    required this.tasks,
    this.gapReason,
    this.visitNotes = '',
  });
}

class VisitType {
  final String label;
  final String icon;
  const VisitType(this.label, this.icon);
}

class ResidentModel {
  final String initials;
  final String fullName;
  final int age;
  final String address;
  final String careHours;
  final int visitsToday;
  final int visitsDone;
  final int visitsRemaining;

  final String careSummary;
  final String nextOfKin;
  final String gp;
  final String keySafeCode;

  final bool fallsRisk;
  final String? allergy;

  ResidentModel({
    required this.initials,
    required this.fullName,
    required this.age,
    required this.address,
    required this.careHours,
    required this.visitsToday,
    required this.visitsDone,
    required this.visitsRemaining,
    required this.careSummary,
    required this.nextOfKin,
    required this.gp,
    required this.keySafeCode,
    required this.fallsRisk,
    this.allergy,
  });
}
