import 'package:ginilog_customer_app/core/helpers/globals.dart';
import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/email_dialog.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ConfirmEmailAddressScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final bool fromLogin;

  const ConfirmEmailAddressScreen({
    super.key,
    required this.email,
    required this.fromLogin,
    required this.password,
  });

  @override
  ConsumerState<ConfirmEmailAddressScreen> createState() =>
      _ConfirmEmailAddressScreenState();
}

class _ConfirmEmailAddressScreenState
    extends ConsumerState<ConfirmEmailAddressScreen> {
  final TextEditingController pinPutController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String pin = "";

  @override
  void initState() {
    super.initState();

    globals.stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      onEnded: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    globals.stopWatchTimer!.setPresetMinuteTime(10);
    globals.stopWatchTimer!.onStartTimer();
  }

  @override
  void dispose() {
    pinPutController.dispose();
    passwordController.dispose();
    globals.stopWatchTimer?.dispose();
    super.dispose();
  }

  void getPin(String value) {
    setState(() {
      pin = value;
    });

    ref.read(authControllerProvider.notifier).onOtpChanged(value);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnack() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("New code sent to your email")),
    );
  }

  Future<void> resendCode() async {
    if (globals.stopWatchTimer!.isRunning) return;

    setState(() {
      globals.stopWatchTimer!.setPresetMinuteTime(1);
      globals.stopWatchTimer!.onStartTimer();
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .sendVerificationCode(email: widget.email);

    if (!mounted) return;

    if (result.isSuccess) {
      showSnack();
    } else {
      showCustomSnackbar(
        context,
        title: "Verification",
        content: result.message ?? "Failed to resend code",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    if (pinPutController.text.trim().length < 5) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .verifyEmail(
          token: pinPutController.text.trim(),
          password: widget.password,
        );

    if (!mounted) return;

    if (result.isSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const EmailSentDialog(),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ErrorEmailSentDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;
    authAsync.value ?? const AuthState();

    final canVerify = pin.trim().length >= 5;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,

        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0, left: 24),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/emailIcon.png",
                  height: 150,
                  width: 150,
                ),
                AppText(
                  text: "Check Your Email",
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.bodyMedium,
                ),
                addVerticalSpacing(5),
                const AppText(
                  text:
                      "Please enter the 5 digit code that will be sent to your email address.",
                  textAlign: TextAlign.center,
                  color: AppColors.black,
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 60),
                Pinput(
                  length: 5,
                  controller: pinPutController,
                  onCompleted: (value) => submit(),
                  onChanged: (value) {
                    getPin(value);
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: "VERIFY MAIL",
                  onPressed: (canVerify && !isLoading) ? submit : null,
                  widthPercent: 100,
                  heightPercent: 6,
                  btnColor: canVerify ? AppColors.primary : AppColors.grey,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 50),
                StreamBuilder<int>(
                  stream: globals.stopWatchTimer!.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data ?? 0;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value,
                      milliSecond: false,
                      minute: true,
                      hours: false,
                    );

                    return Text(
                      'Code expires in: $displayTime',
                      style: TextStyle(
                        color:
                            globals.stopWatchTimer!.isRunning
                                ? AppColors.primary
                                : AppColors.white,
                      ),
                    );
                  },
                ),
                addVerticalSpacing(5),
                AppButton(
                  borderRadius: 20,
                  onPressed:
                      globals.stopWatchTimer!.isRunning ? null : resendCode,
                  btnColor: AppColors.white,
                  text: "Send again",
                  fontSize: 20,
                  heightPercent: 100,
                  widthPercent: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
