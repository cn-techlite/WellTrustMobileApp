import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _focusFeedback = FocusNode();
  final _feedback = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(accountProvider.notifier).getAccount();
    });
  }

  @override
  void dispose() {
    _feedback.dispose();
    _focusFeedback.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    _focusFeedback.unfocus();

    if (!_formKey.currentState!.validate()) return;

    final accountState = ref.read(accountProvider);
    final user = accountState.value?.userData;

    if (user == null) {
      showCustomSnackbar(
        context,
        title: "Account Error",
        content: "Unable to load user information",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final response = await ref
        .read(accountProvider.notifier)
        .sendFeedBack(
          feedback: _feedback.text.trim(),
          phoneNo: user.phoneNo ?? "",
        );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (response.isSuccess == true) {
      showCustomSnackbar(
        context,
        title: "Success",
        content: response.message ?? "Feedback sent successfully",
        type: SnackbarType.success,
        isTopPosition: false,
      );

      Navigator.pop(context);
    } else {
      showCustomSnackbar(
        context,
        title: "Feedback Error",
        content: response.message ?? "Unable to send feedback",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final accountState = ref.watch(accountProvider);
    final account = accountState.value;
    final user = account?.userData;

    final isAccountLoading =
        accountState.isLoading && account?.userData == null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "Contact Us",
          textAlign: TextAlign.start,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _focusFeedback.unfocus();
          },
          child:
              isAccountLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                  : ListView(
                    children: [
                      const SizedBox(height: 10),

                      Image.asset(
                        'assets/images/logo_path.png',
                        height: 150,
                        color: AppColors.primary,
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: width / 20,
                          right: width / 20,
                          top: 10,
                        ),
                        child: const AppText(
                          text:
                              "If you are having trouble placing and completing orders, or you have any question or queries, please feel free to email us",
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: width / 20,
                          right: width / 20,
                          top: 10,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse('mailto:info@ginilog.com');
                            await launchUrl(uri);
                          },
                          child: const AppText(
                            text: "info@ginilog.com",
                            textAlign: TextAlign.start,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: width / 20,
                          right: width / 20,
                          top: 10,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse('tel:08166516944');
                            await launchUrl(uri);
                          },
                          child: const AppText(
                            text: "0816 651 6944",
                            textAlign: TextAlign.start,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: width / 20,
                          right: width / 20,
                          top: 10,
                        ),
                        child: const AppText(
                          text: "A member of our team will attend to you",
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: width / 20,
                                  right: width / 20,
                                  top: 10,
                                ),
                                child: const AppText(
                                  text: "Leave a message with us",
                                  textAlign: TextAlign.start,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                  right: 10,
                                ),
                                child: GlobalTextField(
                                  fieldName: 'What Complaints do you have?',
                                  keyBoardType: TextInputType.text,
                                  obscureText: false,
                                  removeSpace: false,
                                  isNotePad: true,
                                  textController: _feedback,
                                  onChanged: (value) {},
                                ),
                              ),

                              addVerticalSpacing(3),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppButton(
                                  text: "Send",
                                  onPressed:
                                      _isProcessing || user == null
                                          ? () {}
                                          : _sendFeedback,
                                  widthPercent: 100,
                                  heightPercent: 6,
                                  btnColor:
                                      user == null
                                          ? AppColors.grey
                                          : AppColors.primary,
                                  isLoading: _isProcessing,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
