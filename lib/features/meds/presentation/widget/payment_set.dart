// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:well_trust_mobile_app/features/notes/data/model/package_orders_model.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/provider/package_provider.dart';
import 'package:well_trust_mobile_app/shared/model/flutterwave_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/paystack_response_model.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/payment_page_widget.dart';

class PaymentMethodBottomSheet extends ConsumerStatefulWidget {
  const PaymentMethodBottomSheet({super.key, required this.order});

  final PackageOrderResponseModel order;

  @override
  ConsumerState<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState
    extends ConsumerState<PaymentMethodBottomSheet> {
  int selected = 0;
  String paymentMethodUse = "";
  bool isLoading = false;

  void handlePayment() {
    if (selected == 1) {
      handlePaystackPayment();
    } else if (selected == 2) {
      handleFlutterWavePayment();
    } else {
      showCustomSnackbar(
        context,
        title: "Payment Method",
        content: "Please select a payment method",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  String generateTransactionReference() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> handlePaystackPayment() async {
    setState(() {
      isLoading = true;
    });

    final response = await ref
        .read(packageOrderControllerProvider.notifier)
        .makePayment(
          orderId: widget.order.id.toString(),
          trnxReference: generateTransactionReference(),
          paymentStatus: true,
          paymentChannel: "Paystack",
          paymentType: "paystack",
        );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      final payment = PaystackResponseModel.fromJson(response.data!);

      navigateBack(context);

      navigateToRoute(
        context,
        PaystackPaymentPage(
          url: payment.data!.authorizationUrl!,
          isPaystack: true,
          isPackageOrder: true,
        ),
      );
    } else {
      navigateBack(context);

      showCustomSnackbar(
        context,
        title: "Payment Error",
        content: response.message ?? "Payment could not be completed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> handleFlutterWavePayment() async {
    setState(() {
      isLoading = true;
    });

    final response = await ref
        .read(packageOrderControllerProvider.notifier)
        .makePayment(
          orderId: widget.order.id.toString(),
          trnxReference: generateTransactionReference(),
          paymentStatus: true,
          paymentChannel: "Flutterwave",
          paymentType: "flutterwave",
        );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      final payment = FlutterwaveResponseModel.fromJson(response.data!);

      navigateBack(context);

      navigateToRoute(
        context,
        PaystackPaymentPage(
          url: payment.data!.link!,
          isPaystack: false,
          isPackageOrder: true,
        ),
      );
    } else {
      navigateBack(context);

      showCustomSnackbar(
        context,
        title: "Payment Error",
        content: response.message ?? "Payment could not be completed",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
      height: SizeConfig.heightAdjusted(100) * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Choose Payment Method",
                textAlign: TextAlign.start,

                color: AppColors.black,

                fontWeight: FontWeight.w800,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  height: 30,
                  width: 30,
                  child: Icon(Icons.close),
                ),
              ),
            ],
          ),

          addVerticalSpacing(1.2),

          const Divider(),

          addVerticalSpacing(5.2),

          _buildPaymentOption("Pay with Paystack", 1),

          // Uncomment when Flutterwave is active
          // addVerticalSpacing(2.2),
          // _buildPaymentOption("Pay with Flutterwave", 2),
          addVerticalSpacing(2.2),

          AppButton(
            text: "Continue",
            onPressed: isLoading ? null : handlePayment,
            widthPercent: 100,
            heightPercent: 6,
            btnColor: AppColors.primary,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String text, int value) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              setState(() {
                selected = value;
                paymentMethodUse = text;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(color: AppColors.primaryDark),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.textSize,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
