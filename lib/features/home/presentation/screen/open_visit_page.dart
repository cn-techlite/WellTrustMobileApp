import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_design_page.dart';

/// A visit the carer is already clocked in to.
class OpenVisitDetailsPage extends StatelessWidget {
  const OpenVisitDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VisitDesignPage(
      clientName: "Maeve O'Connor",
      subtitle: 'Lunch call',
      dateTime: 'Today, 12:00 to 13:00',
      duration: '60 min',
      address: '11 Rosedale Walk, Burton Latimer NN15 5XB',
      phone: '07700 900113',
      accessType: 'Key safe',
      accessCode: '4821',
      accessNote: "Her son Sean O'Connor (07700 900112) is next of kin.",
      thingsToKnow: const ['Falls risk. Uses a walking frame.'],
      tasks: const [
        VisitTask('Lunch prep'),
        VisitTask('Eating support'),
        VisitTask('Lunch meds', medication: true),
        VisitTask('Toilet'),
        VisitTask('Bin out'),
      ],
      started: true,
      startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      plannedLabel: 'scheduled 60 min',
    );
  }
}
