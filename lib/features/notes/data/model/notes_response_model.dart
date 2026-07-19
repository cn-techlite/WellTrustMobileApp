class NoteType {
  final String id;
  final String icon;
  final String label;
  final String desc;
  final String placeholder;
  final List<String> tags;
  final String cqcKey; // safe|effective|caring|responsive|wellled
  final String cqcQS;
  final String cqcLabel;
  const NoteType({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
    required this.placeholder,
    required this.tags,
    required this.cqcKey,
    required this.cqcQS,
    required this.cqcLabel,
  });
}

class CareNote {
  final String by;
  final String date;
  final String dateISO;
  final String text;
  final List<String> tags;
  final String noteType;
  final String cqcKey;
  final String cqcQS;
  const CareNote({
    required this.by,
    required this.date,
    required this.dateISO,
    required this.text,
    required this.tags,
    required this.noteType,
    required this.cqcKey,
    required this.cqcQS,
  });

  Map<String, dynamic> toJson() => {
    'by': by,
    'date': date,
    'dateISO': dateISO,
    'text': text,
    'tags': tags,
    'noteType': noteType,
    'cqcKey': cqcKey,
    'cqcQS': cqcQS,
  };

  factory CareNote.fromJson(Map<String, dynamic> j) => CareNote(
    by: j['by'] ?? '',
    date: j['date'] ?? '',
    dateISO: j['dateISO'] ?? '',
    text: j['text'] ?? '',
    tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    noteType: j['noteType'] ?? 'general',
    cqcKey: j['cqcKey'] ?? 'wellled',
    cqcQS: j['cqcQS'] ?? 'W1.1',
  );
}
