import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class MedicationResidentCard extends StatelessWidget {
  final String initials;
  final String name;
  final String address;
  final int medsToday;
  final int given;
  final int due;
  final int totalSegments;
  final VoidCallback? onView;

  const MedicationResidentCard({
    super.key,
    required this.initials,
    required this.name,
    required this.address,
    required this.medsToday,
    required this.given,
    required this.due,
    this.totalSegments = 4,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final completedSegments = given.clamp(0, totalSegments);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2D9C9), width: 1.4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFBF9747),
                child: AppText(
                  text: initials,
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  type: AppTextType.bodyLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: name,
                      textAlign: TextAlign.start,
                      color: AppColors.black,
                      type: AppTextType.bodyLarge,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      text: "📍 $address · $medsToday meds today",
                      textAlign: TextAlign.start,
                      color: AppColors.muted,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ],
          ),

          addVerticalSpacing(2),

          Row(
            children: List.generate(totalSegments, (index) {
              final isDone = index < completedSegments;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index == totalSegments - 1 ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.sage : const Color(0xFFBF9747),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),

          addVerticalSpacing(2),

          Row(
            children: [
              AppText(
                text: '$given',
                textAlign: TextAlign.start,
                color: AppColors.black,
                type: AppTextType.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(width: 5),
              const AppText(
                text: 'given',
                textAlign: TextAlign.start,
                color: AppColors.muted,
                type: AppTextType.bodyMedium,
                fontWeight: FontWeight.w400,
              ),

              const Spacer(),

              AppText(
                text: '$due',
                textAlign: TextAlign.center,
                color: AppColors.black,
                type: AppTextType.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(width: 5),
              const AppText(
                text: 'due',
                textAlign: TextAlign.center,
                color: AppColors.muted,
                type: AppTextType.bodyMedium,
                fontWeight: FontWeight.w400,
              ),

              const Spacer(),

              GestureDetector(
                onTap: onView,
                child: const AppText(
                  text: 'View →',
                  textAlign: TextAlign.end,
                  color: AppColors.navy,
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
