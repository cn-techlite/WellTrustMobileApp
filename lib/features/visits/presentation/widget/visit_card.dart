import 'package:flutter/material.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class ActiveVisitCard extends StatelessWidget {
  final String startedTime;
  final String elapsedTime;
  final String clientName;
  final String address;
  final List<String> tasks;
  final VoidCallback? onTap;

  const ActiveVisitCard({
    super.key,
    required this.startedTime,
    required this.elapsedTime,
    required this.clientName,
    required this.address,
    required this.tasks,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sage, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              const Icon(Icons.play_arrow, color: AppColors.sage, size: 22),
              const SizedBox(width: 8),
              AppText(
                text: "Started $startedTime  $elapsedTime",
                textAlign: TextAlign.start,
                color: AppColors.sage,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),

          addVerticalSpacing(1),

          /// Name
          AppText(
            text: clientName,
            textAlign: TextAlign.start,
            color: AppColors.black,
            type: AppTextType.titleSmall,
            fontWeight: FontWeight.w700,
          ),

          addVerticalSpacing(.2),

          /// Address
          AppText(
            text: address,
            textAlign: TextAlign.start,
            color: AppColors.muted,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w400,
          ),

          addVerticalSpacing(2),

          /// Tasks
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppText(
                text: '• $task',
                textAlign: TextAlign.start,
                color: AppColors.ink2,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          addVerticalSpacing(2),

          AppButton(
            text: "Open visit →",
            onPressed: onTap,
            widthPercent: 100,
            heightPercent: 6,
            fontSize: 18,
            btnColor: AppColors.sage,
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
