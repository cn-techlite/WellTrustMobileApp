import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';
import 'package:well_trust_mobile_app/features/home_screen.dart';

import 'package:well_trust_mobile_app/shared/state/connectivity_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/pin_input.dart';

class LoginScreens extends ConsumerStatefulWidget {
  const LoginScreens({super.key});

  @override
  ConsumerState<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends ConsumerState<LoginScreens> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController usernameController;
  late TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    pinController = TextEditingController();

    Future.microtask(() {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).resetLoginForm();
      ref.read(connectivityStatusProviders);
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    pinController.dispose();
    super.dispose();
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

    final username = usernameController.text.trim();
    final pin = pinController.text.trim();

    final result = await ref
        .read(authControllerProvider.notifier)
        .login(username: username, pin: pin);

    if (!mounted) return;

    if (result.isSuccess && result.loginData != null) {
      navigateAndRemoveUntilRoute(context, const HomeScreenPage(imdex: 0));
    } else {
      // A 401 covers a wrong username or passcode, no device assigned, or a
      // device marked Offline. The server deliberately does not say which.
      pinController.clear();
      ref.read(authControllerProvider.notifier).onPinChanged('');
      showCustomSnackbar(
        context,
        title: "Sign in failed",
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

    final canLogin = authState.canLogin;

    return Scaffold(
      backgroundColor: AppColors.bg,
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
                  AppText(
                    text:
                        "Enter your username and 5 digit PIN to access your account",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  addVerticalSpacing(4),
                  AppText(
                    text: "Username",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),

                  GlobalTextField(
                    fieldName: 'Enter your username',
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    textInputAction: TextInputAction.next,
                    textController: usernameController,
                    onChanged: (String? value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onUsernameChanged(value ?? '');
                    },
                  ),
                  addVerticalSpacing(2),
                  AppText(
                    text: "PIN",
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),

                  addVerticalSpacing(1),
                  AppPinInput(
                    controller: pinController,
                    obscure: true,
                    enabled: !isLoading,
                    onChanged: (value) {
                      ref
                          .read(authControllerProvider.notifier)
                          .onPinChanged(value);
                    },
                    onCompleted: (_) {
                      if (isConnected && !isLoading) loginUser();
                    },
                  ),
                  addVerticalSpacing(1),
                  addVerticalSpacing(1.5),
                  AppText(
                    text:
                        "Forgot your PIN? Ask your administrator to reset it.",
                    textAlign: TextAlign.start,
                    color: AppColors.muted,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w500,
                  ),
                  addVerticalSpacing(2),
                  addVerticalSpacing(.5),
                  AppButton(
                    text: "Log In",
                    onPressed: canLogin && isConnected && !isLoading
                        ? loginUser
                        : null,
                    widthPercent: 100,
                    heightPercent: 6,
                    fontSize: 18,
                    btnColor: canLogin && isConnected
                        ? AppColors.primary
                        : AppColors.grey,
                    isLoading: isLoading,
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
