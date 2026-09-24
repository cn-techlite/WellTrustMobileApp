import 'package:well_trust_mobile_app/shared/widgets/brand_logo.dart';
import 'package:well_trust_mobile_app/core/routes/route.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

/// Single welcome screen shown the first time the app is opened.
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});
  static const String routeName = "/Onboard";

  Future<void> _start(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', 0);
    if (!context.mounted) return;
    navPush(context, RootRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const WellTrustLogo(height: 200),
              addVerticalSpacing(3),
              AppText(
                text: "WellTrust Carer",
                textAlign: TextAlign.center,
                color: AppColors.ink,
                type: AppTextType.headlineMedium,
                fontWeight: FontWeight.w700,
              ),
              addVerticalSpacing(2),
              AppText(
                text:
                    "Your visits, care notes and handover in one place, so you can spend less time on paperwork and more time with the people you support.",
                textAlign: TextAlign.center,
                color: AppColors.muted,
                type: AppTextType.bodyMedium,
                fontWeight: FontWeight.w400,
              ),
              const Spacer(flex: 4),
              AppButton(
                text: "Get Started",
                onPressed: () => _start(context),
                widthPercent: 100,
                heightPercent: 6,
                fontSize: 18,
              ),
              addVerticalSpacing(3),
            ],
          ),
        ),
      ),
    );
  }
}
