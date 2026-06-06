import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';

class AddAccomodationReviewScreen extends ConsumerStatefulWidget {
  const AddAccomodationReviewScreen({
    super.key,
    required this.accomodationId,
    required this.accomodationName,
    required this.accomodationLogo,
  });

  final String accomodationId;
  final String accomodationName;
  final String accomodationLogo;

  @override
  ConsumerState<AddAccomodationReviewScreen> createState() =>
      _AddAccomodationReviewScreenState();
}

class _AddAccomodationReviewScreenState
    extends ConsumerState<AddAccomodationReviewScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController reviewController = TextEditingController();

  double ratingNum = 0.0;
  bool isLoading = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  bool get canSubmit {
    return ratingNum > 0 && reviewController.text.trim().isNotEmpty;
  }

  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    if (ratingNum <= 0) {
      showCustomSnackbar(
        context,
        title: "Rating Required",
        content: "Please select a rating",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await ref
        .read(customerBookControllerProvider.notifier)
        .addAccomodationReview(
          accomodationId: widget.accomodationId,
          reviewMessage: reviewController.text.trim(),
          ratingNum: ratingNum,
        );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      showCustomSnackbar(
        context,
        title: "Accomodation Review",
        content: response.message ?? "Accomodation Review Added Successfully",
        type: SnackbarType.success,
        isTopPosition: false,
      );

      navigateBack(context);
    } else {
      showCustomSnackbar(
        context,
        title: "Accomodation Review Error",
        content: response.message ?? "Review could not be added",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = widget.accomodationLogo.trim();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "Add Review",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 10),
              child: Column(
                children: [
                  Text(
                    "Review Accommodation",
                    style: TextStyle(
                      fontSize: 8.textSize,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat",
                    ),
                  ),

                  addVerticalSpacing(3),

                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 57,
                        backgroundImage:
                            logo.isEmpty
                                ? const NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png?20170218203212",
                                )
                                : NetworkImage(logo),
                      ),
                    ),
                  ),

                  addVerticalSpacing(2),

                  Center(
                    child: AppText(
                      text: widget.accomodationName,
                      textAlign: TextAlign.center,

                      color: AppColors.black,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  addVerticalSpacing(5),

                  RatingBar(
                    isHalfAllowed: true,
                    halfFilledIcon: Icons.star_half,
                    filledIcon: Icons.star,
                    emptyIcon: Icons.star_border,
                    onRatingChanged: (value) {
                      setState(() {
                        ratingNum = value;
                      });
                    },
                    initialRating: ratingNum,
                    alignment: Alignment.center,
                    size: 50,
                  ),

                  addVerticalSpacing(1),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Write Review",
                      style: TextStyle(
                        fontSize: 12.textSize,
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Montserrat",
                      ),
                    ),
                  ),

                  GlobalTextField(
                    fieldName: 'Write a Review',
                    keyBoardType: TextInputType.multiline,
                    removeSpace: false,
                    obscureText: false,
                    isNotePad: true,
                    maxLength: 200,
                    textController: reviewController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(10),

                  AppButton(
                    text: "Add Review",
                    onPressed: canSubmit && !isLoading ? _submitReview : () {},
                    widthPercent: 100,
                    heightPercent: 5,
                    btnColor: canSubmit ? AppColors.primary : AppColors.grey,
                    isLoading: isLoading,
                  ),

                  addVerticalSpacing(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
