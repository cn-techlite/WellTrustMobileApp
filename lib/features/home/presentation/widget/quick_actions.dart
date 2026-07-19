import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class QuickActionButton extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 12.heightAdjusted,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2D9C9), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: icon,
                textAlign: TextAlign.center,
                color: AppColors.black,
                type: AppTextType.headlineSmall,
                fontWeight: FontWeight.w400,
              ),
              addVerticalSpacing(1),
              AppText(
                text: title,
                textAlign: TextAlign.center,
                color: AppColors.ink2,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 13.heightAdjusted,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2D9C9), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: value,
            textAlign: TextAlign.center,
            color: AppColors.black,
            type: AppTextType.headlineLarge,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          AppText(
            text: label,
            textAlign: TextAlign.center,
            color: AppColors.muted,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
