class Med {
  final String time; // HH:MM
  final String name;
  final String dose;
  String status; // due | done
  Med({
    required this.time,
    required this.name,
    required this.dose,
    required this.status,
  });
}

class MarRecord {
  final String suId;
  final String resident;
  final String initials;
  final List<Med> meds;
  const MarRecord({
    required this.suId,
    required this.resident,
    required this.initials,
    required this.meds,
  });
}
