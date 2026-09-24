import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

class VisitTask {
  final String label;
  final bool medication;
  const VisitTask(this.label, {this.medication = false});
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
  });

  DateTime get end => start.add(Duration(minutes: minutes));

  HandoverClient get client => handoverClients.firstWhere(
    (c) => c.id == clientId,
    orElse: () => handoverClients.first,
  );
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

/// Sample office number until the office publishes its own.
const sampleOfficePhone = '01536 555 010';

/// "Today 11:15" for someone on today's round, else the stored label.
String nextVisitLabel(HandoverClient c) {
  for (final v in todayVisits) {
    if (v.clientId == c.id) return 'Today ${hhmm(v.start)}';
  }
  return c.nextVisit;
}

/// The round for today. Times are set from the moment the app first asks for
/// them, so the first visit is always about half an hour away.
final List<TodayVisit> todayVisits = _buildToday(DateTime.now());

List<TodayVisit> _buildToday(DateTime now) {
  var t = now.add(const Duration(minutes: 27));
  DateTime next(int prevMinutes, int travel) =>
      t = t.add(Duration(minutes: prevMinutes + travel));

  final harold = t;
  final margaret = next(45, 12);
  final dorothy = next(45, 10);
  final joan = next(30, 15);

  return [
    TodayVisit(
      id: 'V1',
      clientId: 'U1',
      name: 'Mr Harold Fisher',
      preferred: 'Harold',
      address: '14 Rowan Close, Kettering',
      phone: '07700 900101',
      latitude: 52.3975,
      longitude: -0.7395,
      start: harold,
      minutes: 45,
      travelMins: 0,
      type: 'Lunch call',
      accessType: 'Key safe',
      accessCode: '4821',
      accessNote:
          'Key safe is by the front door. His daughter Ann is next of kin.',
      thingsToKnow: const [
        'Diabetic. Check his sugar readings.',
        'Falls risk. Keep the hallway clear.',
        'Allergy: penicillin.',
      ],
      tasks: const [
        VisitTask('Lunch prompt'),
        VisitTask('Lunch meds', medication: true),
        VisitTask('Fluids'),
        VisitTask('Check sugar readings'),
      ],
    ),
    TodayVisit(
      id: 'V2',
      clientId: 'U2',
      name: 'Mrs Margaret Hensley',
      preferred: 'Margaret',
      address: '3 Elm Court, Kettering',
      phone: '07700 900102',
      latitude: 52.4005,
      longitude: -0.7250,
      start: margaret,
      minutes: 45,
      travelMins: 12,
      withStaff: 'Sarah Williams',
      type: 'Lunch call',
      accessType: 'Door code',
      accessCode: '2580',
      accessNote: 'Ring the bell and wait. She may be in the lounge.',
      thingsToKnow: const [
        'Uses a hoist. Check the sling label before every transfer.',
        'Check the skin on her pressure areas.',
      ],
      tasks: const [
        VisitTask('Hoist transfer'),
        VisitTask('Personal care'),
        VisitTask('Lunch prompt'),
        VisitTask('Fluids'),
      ],
    ),
    TodayVisit(
      id: 'V3',
      clientId: 'U3',
      name: 'Mrs Dorothy Bell',
      preferred: 'Dorothy',
      address: '22 Meadow Lane, Kettering',
      phone: '07700 900103',
      latitude: 52.3940,
      longitude: -0.7180,
      start: dorothy,
      minutes: 30,
      travelMins: 10,
      type: 'Lunch call',
      accessType: 'Key safe',
      accessCode: '1937',
      accessNote: 'Key safe is round the side of the house.',
      thingsToKnow: const [
        'Has refused her tablets twice this week. Do not force her. Record it each time.',
      ],
      tasks: const [
        VisitTask('Lunch prompt'),
        VisitTask('Lunch meds', medication: true),
        VisitTask('Fluids'),
      ],
    ),
    TodayVisit(
      id: 'V4',
      clientId: 'U5',
      name: 'Mrs Joan Whitmore',
      preferred: 'Joan',
      address: '61 Beech Road, Kettering',
      phone: '07700 900104',
      latitude: 52.4050,
      longitude: -0.7420,
      start: joan,
      minutes: 60,
      travelMins: 15,
      type: 'Tea call',
      accessType: 'Key safe',
      accessCode: '6410',
      accessNote: 'Key safe is by the back door.',
      thingsToKnow: const [
        'New pendant alarm. Test it at every visit and tell the office if it does not connect.',
      ],
      tasks: const [
        VisitTask('Tea prompt'),
        VisitTask('Test pendant alarm'),
        VisitTask('Fluids'),
        VisitTask('Personal care'),
      ],
    ),
  ];
}
