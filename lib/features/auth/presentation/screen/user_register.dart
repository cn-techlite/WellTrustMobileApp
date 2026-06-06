import 'dart:io';

import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/confirm_email.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/logins.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:ginilog_customer_app/features/home_screen.dart';
import 'package:ginilog_customer_app/shared/state/connectivity_state.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/bizora_checkbox_widget.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';
import 'package:flutter/gestures.dart';

import '../../data/dto/register_request.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;
  bool obscureConfirmPassword = true;

  late TextEditingController email;
  late TextEditingController fistNameTEC;
  late TextEditingController lastNameTEC;
  late TextEditingController password;
  late TextEditingController confirmPassword;
  late TextEditingController phoneNo;

  final focusEmail = FocusNode();
  final focusPassword = FocusNode();
  late FocusNode firstNameFocusNode = FocusNode();
  late FocusNode lastNameFocusNode = FocusNode();
  final focusConfirmPassword = FocusNode();
  final focusPhoneNo = FocusNode();

  String selectedCountryCode = "+234";

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    fistNameTEC = TextEditingController();
    lastNameTEC = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    phoneNo = TextEditingController();
    Future.microtask(() {
      ref.read(connectivityStatusProviders);
    });
  }

  @override
  void dispose() {
    email.dispose();
    fistNameTEC.dispose();
    lastNameTEC.dispose();
    password.dispose();
    confirmPassword.dispose();
    phoneNo.dispose();

    focusEmail.dispose();
    focusPassword.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    focusConfirmPassword.dispose();
    focusPhoneNo.dispose();

    super.dispose();
  }

  Future<void> urlString(String? url) async {
    final link = Uri.parse(url!);
    if (await canLaunchUrl(link)) {
      await launchUrl(link);
    } else {
      throw 'Could not launch $url';
    }
  }

  void obscureTextPassword() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void obscureTextConfirmPassword() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])");
  double passStrength = 0;

  bool validatePassword(String pass) {
    final text = pass.trim();
    if (text.isEmpty) {
      setState(() {
        passStrength = 0;
      });
    } else if (text.length < 6) {
      passStrength = 1 / 4;
    } else if (text.length < 8) {
      passStrength = 2 / 4;
    } else {
      if (passValid.hasMatch(text)) {
        passStrength = 4 / 4;
        return true;
      } else {
        passStrength = 3 / 4;
        return false;
      }
    }
    return false;
  }

  Future<void> userRegister() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);
    final authState =
        ref.read(authControllerProvider).value ?? const AuthState();

    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    if (connectivityStatusProvider.value != ConnectivityStatus.isConnected) {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (!authState.agreedToTerms) {
      showCustomSnackbar(
        context,
        title: "Terms of Service",
        content: "Please accept terms & condition",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (password.text.trim() != confirmPassword.text.trim()) {
      showCustomSnackbar(
        context,
        title: "Password",
        content: "Passwords do not match",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final request = RegisterRequest(
      firstName: fistNameTEC.text.trim(),
      lastName: lastNameTEC.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
      phoneNo: "$selectedCountryCode${phoneNo.text.trim()}",
    );

    final result = await ref
        .read(authControllerProvider.notifier)
        .register(request: request);

    if (!mounted) return;

    if (result.isSuccess) {
      navigateToRoute(
        context,
        ConfirmEmailAddressScreen(
          email: email.text.trim(),
          fromLogin: false,
          password: password.text.trim(),
        ),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "User Error",
        content: result.message ?? "Registration failed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> google() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);
    final authState =
        ref.read(authControllerProvider).value ?? const AuthState();

    if (connectivityStatusProvider.value != ConnectivityStatus.isConnected) {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (!authState.agreedToTerms) {
      showCustomSnackbar(
        context,
        title: "Terms of Service",
        content: "Please accept terms & condition",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final result =
        await ref.read(authControllerProvider.notifier).loginWithGoogle();

    if (!mounted) return;

    if (result.isSuccess && result.loginData != null) {
      navigateAndReplaceRoute(context, const HomeScreenPage(imdex: 0));
    } else {
      showCustomSnackbar(
        context,
        title: "Authentication Error",
        content: result.message ?? "Google sign in failed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> apple() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);
    final authState =
        ref.read(authControllerProvider).value ?? const AuthState();

    if (connectivityStatusProvider.value != ConnectivityStatus.isConnected) {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (!authState.agreedToTerms) {
      showCustomSnackbar(
        context,
        title: "Terms of Service",
        content: "Please accept terms & condition",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final result =
        await ref.read(authControllerProvider.notifier).loginWithApple();

    if (!mounted) return;

    if (result.isSuccess && result.loginData != null) {
      navigateAndReplaceRoute(context, const HomeScreenPage(imdex: 0));
    } else {
      showCustomSnackbar(
        context,
        title: "Authentication Error",
        content: result.message ?? "Apple sign in failed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> google1() async {
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final authState = authAsync.value ?? const AuthState();
    final isLoading = authAsync.isLoading;

    final canSubmit =
        authState.firstName.trim().isNotEmpty &&
        authState.lastName.trim().isNotEmpty &&
        authState.email.trim().isNotEmpty &&
        authState.phone.trim().isNotEmpty &&
        authState.password.trim().isNotEmpty &&
        authState.confirmPassword.trim().isNotEmpty &&
        authState.password.trim() == authState.confirmPassword.trim() &&
        authState.agreedToTerms;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: buildFlexibleAppBar(
        context: context,

        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: "Complete the sign up process to get started",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "First Name",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalTextField(
                    fieldName: 'First Name',
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    textController: fistNameTEC,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onFirstNameChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "Last Name",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalTextField(
                    fieldName: 'Last Name',
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    textController: lastNameTEC,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onLastNameChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "Email",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalTextField(
                    fieldName: 'Email',
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    textController: email,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onEmailChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "Phone Number",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalPhoneTextField(
                    fieldName: 'Phone Number',
                    textController: phoneNo,
                    onChanged: (value) {
                      final completeNumber = value?.completeNumber ?? '';
                      ref
                          .read(authControllerProvider.notifier)
                          .onPhoneChanged(completeNumber);
                    },
                  ),
                  AppText(
                    text: "Password",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalTextField(
                    fieldName: 'Password',
                    obscureText: obscureText,
                    isEyeVisible: true,
                    keyBoardType: TextInputType.name,
                    textController: password,
                    onChanged: (String? value) {
                      final text = value ?? '';
                      validatePassword(text);
                      ref
                          .read(authControllerProvider.notifier)
                          .onPasswordChanged(text);
                    },
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "Confirm Password",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    type: AppTextType.bodyMedium,
                  ),
                  GlobalTextField(
                    fieldName: 'Confirm Password',
                    obscureText: obscureConfirmPassword,
                    isEyeVisible: true,
                    keyBoardType: TextInputType.name,
                    textController: confirmPassword,
                    confirmPasswordMatch: authState.confirmPassword,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onConfirmPasswordChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BizoraCheckBoxWidget(
                        onChanged: (value) {
                          ref
                              .read(authControllerProvider.notifier)
                              .toggleTerms(value);
                        },
                        isChecked: authState.agreedToTerms,
                      ),
                      addHorizontalSpacing(1),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppTextType.bodyMedium.style(
                              context,
                              color: AppColors.black,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                            ),
                            text: " ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Terms and Conditions",
                                style: AppTextType.bodyMedium.style(
                                  context,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                  // decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        urlString(
                                          "https://ginilog.com/Home/TermsOfService",
                                        );
                                      },
                              ),
                              TextSpan(
                                text: " & ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Mulish",
                                  fontSize: 18.textSize,
                                ),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: AppTextType.bodyMedium.style(
                                  context,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                  // decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        urlString(
                                          "https://ginilog.com/Home/Privacy",
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(2),
                  canSubmit
                      ? AppButton(
                        text: "Sign Up",
                        onPressed: isLoading ? null : userRegister,
                        widthPercent: 100,
                        heightPercent: 6,
                        fontSize: 35,
                        btnColor: AppColors.primary,
                        isLoading: isLoading,
                      )
                      : AppButton(
                        text: "Sign Up",
                        onPressed: () {},
                        widthPercent: 100,
                        heightPercent: 6,
                        fontSize: 35,
                        btnColor: AppColors.grey,
                        isLoading: false,
                      ),
                  addVerticalSpacing(2),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: AppTextType.bodyMedium.style(
                          context,
                          color: AppColors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        text: "Already Has an Account? ",
                        children: <TextSpan>[
                          TextSpan(
                            text: "Sign In",
                            style: AppTextType.bodyLarge.style(
                              context,
                              color: AppColors.blue,
                              fontWeight: FontWeight.w800,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    navigateToRoute(
                                      context,
                                      const LoginScreens(),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                  addVerticalSpacing(2),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color.fromRGBO(218, 218, 218, 1),
                          thickness: 1,
                        ),
                      ),
                      SizedBox(width: 10),
                      AppText(
                        text: "Or sign up with",
                        textAlign: TextAlign.center,
                        color: AppColors.black,
                        type: AppTextType.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          color: Color.fromRGBO(218, 218, 218, 1),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(2),
                  Platform.isIOS
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          IconButton(
                            onPressed: isLoading ? null : google,
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // elevation: const WidgetStatePropertyAll(6),
                              // backgroundColor: WidgetStatePropertyAll(
                              //   AppColors.black.withValues(alpha: 0.1),
                              // ),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsetsGeometry.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/svgs/google.svg',
                              height: 30,
                              width: 30,
                            ),
                          ),
                          addHorizontalSpacing(6),
                          IconButton(
                            onPressed: isLoading ? null : apple,
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // elevation: const WidgetStatePropertyAll(6),
                              // backgroundColor: WidgetStatePropertyAll(
                              //   AppColors.black.withValues(alpha: 0.1),
                              // ),
                              padding: const WidgetStatePropertyAll(
                                EdgeInsetsGeometry.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/svgs/apple.svg',
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ],
                      )
                      : Center(
                        child: IconButton(
                          onPressed: isLoading ? null : google,
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // elevation: const WidgetStatePropertyAll(6),
                            // backgroundColor: WidgetStatePropertyAll(
                            //   AppColors.black.withValues(alpha: 0.1),
                            // ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsetsGeometry.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            'assets/svgs/google.svg',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                  addVerticalSpacing(5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
