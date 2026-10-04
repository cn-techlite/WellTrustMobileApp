class TeamMeeting {
  final String id;
  final String title;
  final DateTime start;
  final int minutes;
  final String host;
  final String location;
  final List<String> agenda;
  final MeetingMinutes? savedMinutes;
  final bool cancelled;

  const TeamMeeting({
    required this.id,
    required this.title,
    required this.start,
    required this.minutes,
    required this.host,
    required this.location,
    this.agenda = const [],
    this.savedMinutes,
    this.cancelled = false,
  });

  factory TeamMeeting.fromJson(Map<String, dynamic> json) {
    final summary = (json['summary'] ?? '').toString();
    final decisions = [
      for (final value in (json['decisions'] as List? ?? const []))
        value.toString(),
    ];
    final actions = [
      for (final value in (json['actions'] as List? ?? const []))
        MeetingAction.fromDisplay(value.toString()),
    ];
    return TeamMeeting(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      start:
          DateTime.tryParse((json['start'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      host: (json['host'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      agenda: [
        for (final value in (json['agenda'] as List? ?? const []))
          value.toString(),
      ],
      savedMinutes: summary.isEmpty && decisions.isEmpty && actions.isEmpty
          ? null
          : MeetingMinutes(
              summary: summary,
              decisions: decisions,
              actions: actions,
            ),
      cancelled: json['cancelled'] == true,
    );
  }

  DateTime get end => start.add(Duration(minutes: minutes));

  bool get isLive {
    final now = DateTime.now();
    return !now.isBefore(start) && now.isBefore(end);
  }

  bool get isSaved => savedMinutes != null;
}

class MeetingMinutes {
  final String summary;
  final List<String> decisions;
  final List<MeetingAction> actions;

  const MeetingMinutes({
    required this.summary,
    this.decisions = const [],
    this.actions = const [],
  });
}

class MeetingAction {
  final String action;
  final String owner;
  final DateTime? due;

  const MeetingAction({required this.action, required this.owner, this.due});

  factory MeetingAction.fromDisplay(String value) {
    final parts = value.split(' — ');
    return MeetingAction(
      action: parts.isEmpty ? value : parts.first,
      owner: parts.length > 1 ? parts[1].split(' (').first : '',
    );
  }
}

/// The next meeting still to come today, if there is one.
TeamMeeting? meetingToday(List<TeamMeeting> meetings) {
  final now = DateTime.now();
  for (final m in meetings) {
    final sameDay =
        m.start.year == now.year &&
        m.start.month == now.month &&
        m.start.day == now.day;
    if (sameDay && now.isBefore(m.end)) return m;
  }
  return null;
}
