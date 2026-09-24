class TeamMeeting {
  final String id;
  final String title;
  final DateTime start;
  final int minutes;
  final String host;
  final String location;

  const TeamMeeting({
    required this.id,
    required this.title,
    required this.start,
    required this.minutes,
    required this.host,
    required this.location,
  });

  DateTime get end => start.add(Duration(minutes: minutes));

  bool get isLive {
    final now = DateTime.now();
    return !now.isBefore(start) && now.isBefore(end);
  }
}

/// Sample meetings until the office publishes them. The next one is today.
final List<TeamMeeting> teamMeetings = _build(DateTime.now());

List<TeamMeeting> _build(DateTime now) {
  final soon = now.add(const Duration(minutes: 27));
  final last = DateTime(now.year, now.month, now.day - 9, 10);
  return [
    TeamMeeting(
      id: 'M1',
      title: 'Monthly team meeting',
      start: soon,
      minutes: 60,
      host: 'Maria Reyes',
      location: 'WellTrust office, Kettering',
    ),
    TeamMeeting(
      id: 'M2',
      title: 'Monthly team meeting (last month)',
      start: last,
      minutes: 60,
      host: 'Maria Reyes',
      location: 'WellTrust office, Kettering',
    ),
  ];
}

/// The next meeting still to come today, if there is one.
TeamMeeting? meetingToday() {
  final now = DateTime.now();
  for (final m in teamMeetings) {
    final sameDay =
        m.start.year == now.year &&
        m.start.month == now.month &&
        m.start.day == now.day;
    if (sameDay && now.isBefore(m.end)) return m;
  }
  return null;
}
