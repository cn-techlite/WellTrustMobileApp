
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/confirm_email.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/forgot_password.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:well_trust_mobile_app/features/home_screen.dart';

import 'package:well_trust_mobile_app/shared/state/connectivity_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class LoginScreens extends ConsumerStatefulWidget {
  const LoginScreens({super.key});

  @override
  ConsumerState<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends ConsumerState<LoginScreens> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureText = true;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool isPhoneSelected = false;
  bool isEmailSelected = true;
  String selectedCountryCode = "+234";

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    Future.microtask(() {
      ref.read(connectivityStatusProviders);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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

  void onIsPhoneNumber() {
    setState(() {
      isPhoneSelected = true;
      isEmailSelected = false;
      emailController.clear();
    });

    ref.read(authControllerProvider.notifier).selectPhone();
  }

  void onIsEmail() {
    setState(() {
      isEmailSelected = true;
      isPhoneSelected = false;
      emailController.clear();
    });

    ref.read(authControllerProvider.notifier).selectEmail();
  }

  void phoneNoCountryCodeChanged(String value) {
    setState(() {
      selectedCountryCode = value;
    });

    ref.read(authControllerProvider.notifier).onCountryCodeChanged(value);
  }

  Future<void> loginUser() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);

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

    // ref.read(authControllerProvider).value ?? const AuthState();

    final identifier = isPhoneSelected
        ? "$selectedCountryCode${emailController.text.trim()}"
        : emailController.text.trim();

    final result = await ref
        .read(authControllerProvider.notifier)
        .login(
          identifier: identifier,
          password: passwordController.text.trim(),
        );

    if (!mounted) return;

    if (result.isSuccess && result.loginData != null) {
      navigateAndReplaceRoute(context, const HomeScreenPage(imdex: 0));
    } else if ((result.message ?? '').trim() == "User Email Not Yet Verify") {
      navigateToRoute(
        context,
        ConfirmEmailAddressScreen(
          email: emailController.text.trim(),
          fromLogin: false,
          password: passwordController.text.trim(),
        ),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "User Error",
        content: result.message ?? "Login failed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final authState = authAsync.value ?? const AuthState();
    final isLoading = authAsync.isLoading;

    final connectivity = ref.watch(connectivityStatusProviders).value;
    final bool isConnected = connectivity == ConnectivityStatus.isConnected;

    final canLogin =
        authState.email.trim().isNotEmpty &&
        authState.password.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addVerticalSpacing(5),
                  AppText(
                    text: globals.userName.isEmpty
                        ? "Login"
                        : "Welcome back, ${globals.userName}",
                    textAlign: TextAlign.start,

                    color: AppColors.black,
                    type: AppTextType.titleLarge,
                    fontWeight: FontWeight.w700,
                  ),

                  addVerticalSpacing(4),
                  const AppText(
                    text:
                        "Enter username and password to login to your account",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  addVerticalSpacing(4),
                  const AppText(
                    text: "Email Address",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),

                  GlobalTextField(
                    fieldName: 'Enter your email',
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    textController: emailController,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onEmailChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  const AppText(
                    text: "Password",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),

                  GlobalTextField(
                    fieldName: 'Enter your Password',
                    obscureText: true,
                    isEyeVisible: true,
                    isNotePad: false,
                    keyBoardType: TextInputType.name,
                    textController: passwordController,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onPasswordChanged(value ?? '');
                    },
                  ),

                  addVerticalSpacing(.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          navigateToRoute(
                            context,
                            const ForgotPasswordScreen(),
                          );
                        },
                        child: const AppText(
                          text: "Forgot Password?",
                          textAlign: TextAlign.end,

                          color: AppColors.blue,

                          type: AppTextType.bodyLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  addVerticalSpacing(.5),
                  canLogin
                      ? AppButton(
                          text: "Log In",
                          onPressed: (!isConnected || isLoading)
                              ? null
                              : loginUser,
                          widthPercent: 100,
                          heightPercent: 6,
                          fontSize: 18,
                          btnColor: isConnected
                              ? AppColors.primary
                              : AppColors.grey,
                          isLoading: isLoading,
                        )
                      : AppButton(
                          text: "Log In",
                          onPressed: () {},
                          widthPercent: 100,
                          heightPercent: 6,
                          fontSize: 18,
                          btnColor: AppColors.grey,
                          isLoading: false,
                        ),
                  addVerticalSpacing(3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
