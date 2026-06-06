import 'package:ginilog_customer_app/core/helpers/globals.dart';
import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/logins.dart';
import 'package:ginilog_customer_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';
import 'package:flutter/cupertino.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  final String imageUrl;
  final String name;

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController reason;

  @override
  void initState() {
    super.initState();
    reason = TextEditingController();
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final result = await ref.read(authControllerProvider.notifier).deleteUser();

    if (!mounted) return;

    if (result.isSuccess) {
      showCustomSnackbar(
        context,
        title: "Account Deletion",
        content: "Account Deleted Successfully",
        type: SnackbarType.success,
        isTopPosition: false,
      );

      navigateAndRemoveUntilRoute(context, const LoginScreens());
    } else {
      showCustomSnackbar(
        context,
        title: "Error",
        content: result.message ?? "Failed to delete account",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> _confirmDelete() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const AppText(
            text: "Delete Account",
            textAlign: TextAlign.center,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
          content: const AppText(
            text:
                "Are you sure you want to delete your account? This action is irreversible.",
            textAlign: TextAlign.center,
            color: AppColors.black,
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Proceed"),
              onPressed: () async {
                Navigator.pop(context); // close dialog first
                await _deleteAccount();
              },
            ),
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;

    final canSubmit = reason.text.trim().isNotEmpty;

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
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: AppText(
                    text: "Delete Account",
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                /// Profile Image
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 57,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          widget.imageUrl.isEmpty
                              ? const NetworkImage(
                                "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png",
                              )
                              : NetworkImage(widget.imageUrl),
                    ),
                  ),
                ),

                /// Name
                Center(
                  child: AppText(
                    text: widget.name,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// Email
                Center(
                  child: AppText(
                    text: "${globals.userEmail}",
                    color: AppColors.black,
                  ),
                ),

                addVerticalSpacing(20),

                const AppText(
                  text:
                      "Please provide a reason for deleting your account. We will be sad to see you go.",
                  color: AppColors.black,
                ),

                const SizedBox(height: 20),

                /// Reason input
                GlobalTextField(
                  keyBoardType: TextInputType.multiline,
                  fieldName: "Write a reason",
                  obscureText: false,
                  isNotePad: true,
                  textController: reason,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),

                addVerticalSpacing(60),

                /// Button
                canSubmit
                    ? AppButton(
                      text: "Delete My Account",
                      onPressed: isLoading ? null : _confirmDelete,
                      widthPercent: 100,
                      heightPercent: 6,
                      btnColor: AppColors.primary,
                      isLoading: isLoading,
                    )
                    : AppButton(
                      text: "Delete My Account",
                      onPressed: () {},
                      widthPercent: 100,
                      heightPercent: 6,
                      btnColor: AppColors.grey,
                      isLoading: false,
                    ),

                addVerticalSpacing(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
