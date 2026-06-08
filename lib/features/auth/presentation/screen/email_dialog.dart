import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

import '../../../../core/utils/package_export.dart';

class EmailSentDialog extends StatefulWidget {
  const EmailSentDialog({super.key});

  @override
  State<EmailSentDialog> createState() => _EmailSentDialogState();
}

class _EmailSentDialogState extends State<EmailSentDialog> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpacing(2),
                Image.asset(
                  "assets/images/good_big.png",
                  height: 100,
                  width: 100,
                ),
                addVerticalSpacing(5),
                AppText(
                  text: "Verified",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.bodyMedium,
                ),

                addVerticalSpacing(2),
                AppText(
                  text: "You Have Successfully Verified your Account",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                  type: AppTextType.bodySmall,
                ),
                addVerticalSpacing(5),
                AppButton(
                  text: "Go to Login",
                  onPressed: () {
                    navigateAndReplaceRoute(context, const LoginScreens());
                  },
                  widthPercent: 70,
                  heightPercent: 5,
                  btnColor: AppColors.primary,
                  isLoading: false,
                ),
                addVerticalSpacing(5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorEmailSentDialog extends StatefulWidget {
  const ErrorEmailSentDialog({super.key});

  @override
  State<ErrorEmailSentDialog> createState() => _ErrorEmailSentDialogState();
}

class _ErrorEmailSentDialogState extends State<ErrorEmailSentDialog> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpacing(2),
                Image.asset(
                  "assets/images/declined.png",
                  height: 100,
                  width: 100,
                ),
                addVerticalSpacing(2),
                AppText(
                  text: "Oops!",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  type: AppTextType.bodyMedium,
                ),

                addVerticalSpacing(2),
                AppText(
                  text: "Something went Wrong, Please Try Again",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  type: AppTextType.bodyMedium,
                ),

                addVerticalSpacing(5),
                AppButton(
                  text: "Retry",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  widthPercent: 70,
                  heightPercent: 5,
                  btnColor: AppColors.primary,
                  isLoading: false,
                ),
                addVerticalSpacing(2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordChangedDialog extends StatefulWidget {
  const PasswordChangedDialog({super.key});

  @override
  State<PasswordChangedDialog> createState() => _PasswordChangedDialogState();
}

class _PasswordChangedDialogState extends State<PasswordChangedDialog> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpacing(2),
                Image.asset(
                  "assets/images/good_big.png",
                  height: 100,
                  width: 100,
                ),
                addVerticalSpacing(2),
                Text(
                  'Password Change!',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter",
                    fontSize: 15.textSize,
                  ),
                ),
                Text(
                  'You have successfully Change your password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontSize: 15.textSize,
                  ),
                ),
                addVerticalSpacing(5),
                AppButton(
                  text: "Go to Login",
                  onPressed: () {
                    navigateAndReplaceRoute(context, const LoginScreens());
                  },
                  widthPercent: 100,
                  heightPercent: 6,
                  btnColor: AppColors.primary,
                  isLoading: false,
                ),
                addVerticalSpacing(2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
