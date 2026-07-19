import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/general_widget.dart';

class ScheduledVisitCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final int duration;
  final String initials;
  final String clientName;
  final String address;
  final String visitType;
  final List<String> tasks;
  final String status;
  final VoidCallback? onTap;

  const ScheduledVisitCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.initials,
    required this.clientName,
    required this.address,
    required this.visitType,
    required this.tasks,
    this.status = "SCHEDULED",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2D9C9)),
        ),
        child: Column(
          children: [
            /// Top Row
            Row(
              children: [
                AppText(
                  text: '$startTime–$endTime',
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w500,
                ),

                const SizedBox(width: 10),

                AppText(
                  text: '$duration min',
                  textAlign: TextAlign.start,
                  color: AppColors.muted,
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w300,
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2ED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppText(
                    text: status,
                    textAlign: TextAlign.center,
                    color: AppColors.ink,
                    type: AppTextType.labelSmall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            addVerticalSpacing(2),

            /// Avatar + Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(initials, size: 34, bg: AppColors.amber),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: clientName,
                        textAlign: TextAlign.start,
                        color: AppColors.black,
                        type: AppTextType.titleSmall,
                        fontWeight: FontWeight.w700,
                      ),

                      addVerticalSpacing(.2),

                      AppText(
                        text: address,
                        textAlign: TextAlign.start,
                        color: AppColors.muted,
                        type: AppTextType.bodyMedium,
                        fontWeight: FontWeight.w400,
                      ),

                      addVerticalSpacing(.2),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2D9C9)),
                        ),
                        child: AppText(
                          text: visitType,
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          type: AppTextType.labelSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            addVerticalSpacing(1),

            /// Tasks
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Tasks:',
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w700,
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: AppText(
                    text: tasks.join(' · '),
                    textAlign: TextAlign.start,
                    color: AppColors.ink2,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
