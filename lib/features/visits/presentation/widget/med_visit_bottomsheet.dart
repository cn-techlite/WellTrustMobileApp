import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class VisitMedication {
  final String medication;
  final String instruction;
  bool isGiven;

  VisitMedication({
    required this.medication,
    required this.instruction,
    this.isGiven = false,
  });
}

class MedsForVisitBottomSheet extends StatefulWidget {
  const MedsForVisitBottomSheet({super.key});

  @override
  State<MedsForVisitBottomSheet> createState() =>
      _MedsForVisitBottomSheetState();
}

class _MedsForVisitBottomSheetState extends State<MedsForVisitBottomSheet> {
  final medications = [
    VisitMedication(
      medication: "Naproxen 500mg",
      instruction: "1 tablet · oral · with food · scheduled 12:00",
    ),
    VisitMedication(
      medication: "Omeprazole 20mg",
      instruction: "1 capsule · oral · before food · scheduled 12:00",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          addVerticalSpacing(1),

          Container(
            width: 65,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xffd7d0bf),
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "💊 Meds for this visit",
                        color: AppColors.black,
                        type: AppTextType.titleMedium,
                        fontWeight: FontWeight.w800,
                      ),

                      SizedBox(height: 4),

                      AppText(
                        text: "Maeve O'Connor · 12:00–13:00 window",
                        color: Color(0xff8a877f),
                        type: AppTextType.bodySmall,
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xfffaf8f3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xffded6c7)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const AppText(
                    text:
                        "Showing only meds scheduled within 15 min of this visit's time slot (12:00–13:00). Full MAR is on the Meds tab.",
                    color: Color(0xff8a877f),
                    type: AppTextType.bodySmall,
                  ),

                  addVerticalSpacing(2),

                  ...medications.map(
                    (medication) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MedicationCard(
                        medication: medication,
                        onGiven: () {
                          setState(() {
                            medication.isGiven = !medication.isGiven;
                          });
                        },
                      ),
                    ),
                  ),

                  addVerticalSpacing(4),

                  AppButton(
                    text: "Close",
                    onPressed: () => Navigator.pop(context),
                    btnColor: Colors.white,
                    textColor: AppColors.black,
                    borderColor: const Color(0xffded6c7),
                    borderRadius: 12,
                  ),

                  addVerticalSpacing(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final VisitMedication medication;
  final VoidCallback onGiven;

  const _MedicationCard({required this.medication, required this.onGiven});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffded6c7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: medication.medication,
                  color: AppColors.black,
                  type: AppTextType.titleSmall,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff7f1e7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppText(
                  text: "⏳ Due",
                  color: AppColors.amber,
                  type: AppTextType.labelSmall,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          addVerticalSpacing(1),

          AppText(
            text: medication.instruction,
            color: const Color(0xff8a877f),
            type: AppTextType.bodySmall,
          ),

          addVerticalSpacing(2),

          AppButton(
            text: medication.isGiven ? "✓ Given" : "✓ Sign as given",
            onPressed: onGiven,
            btnColor: medication.isGiven
                ? const Color(0xff5d825c)
                : const Color(0xff24447f),
            textColor: Colors.white,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
