import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/forgot_password_code.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late TextEditingController emailController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .resendPasswordCode(email: emailController.text.trim());

    if (!mounted) return;

    if (result.isSuccess) {
      navigateToRoute(
        context,
        ForgotPasswordCodeScreen(email: emailController.text.trim()),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "User Error",
        content: result.message ?? "Failed to send OTP",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;

    final canSubmit = emailController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const AppText(
                        text: "Forgot Password",
                        textAlign: TextAlign.center,
                        color: AppColors.black,
                        type: AppTextType.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                      const AppText(
                        text: "Enter your email address",
                        textAlign: TextAlign.start,
                        color: AppColors.black,
                        type: AppTextType.bodyMedium,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(height: 40),
                      const AppText(
                        text: "Email Address",
                        textAlign: TextAlign.start,
                        color: AppColors.black,
                        type: AppTextType.bodyMedium,
                        fontWeight: FontWeight.w400,
                      ),
                      GlobalTextField(
                        fieldName: 'Email',
                        keyBoardType: TextInputType.emailAddress,
                        obscureText: false,
                        textController: emailController,
                        onChanged: (String? value) {
                          setState(() {});
                          ref
                              .read(authControllerProvider.notifier)
                              .onEmailChanged(value ?? '');
                        },
                      ),
                      addVerticalSpacing(5),
                      canSubmit
                          ? AppButton(
                              text: "Send OTP",
                              onPressed: isLoading ? null : onSubmit,
                              widthPercent: 100,
                              heightPercent: 6,
                              btnColor: AppColors.primary,
                              isLoading: isLoading,
                            )
                          : AppButton(
                              text: "Send OTP",
                              onPressed: () {},
                              widthPercent: 100,
                              heightPercent: 6,
                              btnColor: AppColors.grey,
                              isLoading: false,
                            ),
                      addVerticalSpacing(5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppText(
                            text: "Remember password? Back to  ",
                            textAlign: TextAlign.center,
                            color: AppColors.black,
                            type: AppTextType.bodySmall,
                            fontWeight: FontWeight.w500,
                          ),
                          GestureDetector(
                            onTap: () {
                              navigateToRoute(context, const LoginScreens());
                            },
                            child: const AppText(
                              text: "Sign In",
                              textAlign: TextAlign.center,
                              color: AppColors.blue,
                              type: AppTextType.bodyLarge,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
