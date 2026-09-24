import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_design_page.dart';

/// A visit that has not been started yet.
class VisitStartDetailsPage extends StatelessWidget {
  const VisitStartDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VisitDesignPage(
      clientName: 'Anita Patel',
      subtitle: 'Lunch call',
      dateTime: 'Today, 12:30 to 12:45',
      duration: '15 min',
      address: '14 Linden Avenue, Kettering',
      phone: '07700 900112',
      accessType: 'Key safe',
      accessCode: '4821',
      accessNote:
          "Key safe is by the front door. Her son Sean (07700 900112) is next of kin.",
      thingsToKnow: [
        'Falls risk. Keep the hallway clear.',
        'Allergy: penicillin.',
      ],
      tasks: [
        VisitTask('Lunch prompt'),
        VisitTask('Lunch meds', medication: true),
        VisitTask('Fluids'),
      ],
    );
  }
}
