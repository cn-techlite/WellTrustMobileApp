import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/email_dialog.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ForgotPasswordCodeScreen extends ConsumerStatefulWidget {
  const ForgotPasswordCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState
    extends ConsumerState<ForgotPasswordCodeScreen> {
  late TextEditingController codeController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    globals.stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      onEnded: () {
        if (mounted) setState(() {});
      },
    );

    globals.stopWatchTimer!.setPresetMinuteTime(1);
    globals.stopWatchTimer!.onStartTimer();
  }

  @override
  void dispose() {
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    if (newPasswordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showCustomSnackbar(
        context,
        title: "Password",
        content: "Passwords do not match",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          token: codeController.text.trim(),
          password: newPasswordController.text.trim(),
        );

    if (!mounted) return;

    if (result.isSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PasswordChangedDialog(),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ErrorEmailSentDialog(),
      );
    }
  }

  Future<void> resendCode() async {
    if (globals.stopWatchTimer!.isRunning) return;

    setState(() {
      globals.stopWatchTimer!.setPresetMinuteTime(1);
      globals.stopWatchTimer!.onStartTimer();
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .resendPasswordCode(email: widget.email);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New code sent to your email")),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "Error",
        content: result.message ?? "Failed to resend code",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;
    final authState = authAsync.value ?? const AuthState();

    final canSubmit =
        authState.otp.trim().isNotEmpty &&
        authState.password.trim().isNotEmpty &&
        authState.confirmPassword.trim().isNotEmpty &&
        authState.password == authState.confirmPassword;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: "Create New Password",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  type: AppTextType.titleLarge,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                const AppText(
                  text:
                      "Please enter your new password and OTP sent to your email.",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  type: AppTextType.bodySmall,
                ),
                addVerticalSpacing(5),

                /// OTP
                const AppText(
                  text: "OTP",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.bodyMedium,
                ),
                GlobalTextField(
                  fieldName: 'OTP Code',
                  keyBoardType: TextInputType.number,
                  obscureText: false,
                  maxLength: 5,
                  textController: codeController,
                  onChanged: (value) {
                    ref
                        .read(authControllerProvider.notifier)
                        .onOtpChanged(value ?? '');
                  },
                ),

                addVerticalSpacing(2),

                /// New password
                const AppText(
                  text: "New Password",
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.bodyMedium,
                ),
                GlobalTextField(
                  fieldName: 'New Password',
                  obscureText: obscureText,
                  isEyeVisible: true,
                  textController: newPasswordController,
                  onChanged: (value) {
                    ref
                        .read(authControllerProvider.notifier)
                        .onPasswordChanged(value ?? '');
                  },
                  keyBoardType: TextInputType.name,
                ),

                addVerticalSpacing(2),

                /// Confirm password
                const AppText(
                  text: "Confirm Password",
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.bodyMedium,
                ),
                GlobalTextField(
                  fieldName: 'Confirm Password',
                  obscureText: obscureConfirmPassword,
                  isEyeVisible: true,
                  textController: confirmPasswordController,
                  keyBoardType: TextInputType.name,
                  onChanged: (value) {
                    ref
                        .read(authControllerProvider.notifier)
                        .onConfirmPasswordChanged(value ?? '');
                  },
                ),

                addVerticalSpacing(2),

                /// Button
                canSubmit
                    ? AppButton(
                        text: "Update Password",
                        onPressed: isLoading ? null : onSubmit,
                        widthPercent: 100,
                        heightPercent: 6,
                        btnColor: AppColors.primary,
                        isLoading: isLoading,
                      )
                    : AppButton(
                        text: "Update Password",
                        onPressed: () {},
                        widthPercent: 100,
                        heightPercent: 6,
                        btnColor: AppColors.grey,
                        isLoading: false,
                      ),

                addVerticalSpacing(2),

                /// Resend
                AppButton(
                  text: "Resend Code",
                  onPressed: globals.stopWatchTimer!.isRunning
                      ? null
                      : resendCode,
                  widthPercent: 100,
                  heightPercent: 6,
                  btnColor: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
