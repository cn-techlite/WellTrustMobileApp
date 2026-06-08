// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/create_bookings.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/bookings_providers.dart';
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

class BookingPaymentBottomSheet extends ConsumerStatefulWidget {
  const BookingPaymentBottomSheet({
    super.key,
    required this.amount,
    required this.reservationId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhoneNumber,
    required this.comment,
    required this.noOfDays,
    required this.numberOfGuests,
    required this.reservationEndDate,
    required this.reservationStartDate,
  });

  final double amount;

  final String reservationId;
  final String customerName;
  final String customerPhoneNumber;
  final String customerEmail;
  final int numberOfGuests;
  final String comment;
  final String reservationStartDate;
  final String reservationEndDate;
  final int noOfDays;

  @override
  ConsumerState<BookingPaymentBottomSheet> createState() =>
      _BookingPaymentBottomSheetState();
}

class _BookingPaymentBottomSheetState
    extends ConsumerState<BookingPaymentBottomSheet> {
  int selected = 0;
  String paymentMethodUse = "";
  bool isLoading = false;

  void handlePayment() {
    if (selected == 1) {
      handlePaystackPayment(widget.noOfDays);
    } else if (selected == 2) {
      handleFlutterWavePayment(widget.noOfDays);
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

  Future<void> handlePaystackPayment(int days) async {
    final fatNum = days == 0 ? 1 : days;

    setState(() {
      isLoading = true;
    });

    final request = CreateAccomodationReservationRequest(
      reservationId: widget.reservationId.toString(),
      customerName: widget.customerName,
      customerPhoneNumber: widget.customerPhoneNumber,
      customerEmail: widget.customerEmail,
      trnxReference: generateTransactionReference(),
      paymentStatus: true,
      numberOfGuests: widget.numberOfGuests,
      comment: widget.comment,
      paymentChannel: "Paystack",
      reservationStartDate: widget.reservationStartDate,
      reservationEndDate: widget.reservationEndDate,
      noOfDays: fatNum,
      paymentType: "paystack",
      purchaseChannel: "Mobile App ${Platform.isIOS ? 'iOS' : 'Android'}",
      ticketClosed: true,
      staffId: globals.userId,
      staffName: globals.userName,
      userType: "Registered",
      userId: globals.userId,
    );

    final response = await ref
        .read(customerBookControllerProvider.notifier)
        .bookAccomodationReservation(request: request);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      navigateBack(context);

      final payment = PaystackResponseModel.fromJson(response.data!);

      navigateToRoute(
        context,
        PaystackPaymentPage(
          url: payment.data!.authorizationUrl!,
          isPaystack: true,
          isPackageOrder: false,
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

  Future<void> handleFlutterWavePayment(int days) async {
    final fatNum = days == 0 ? 1 : days;

    setState(() {
      isLoading = true;
    });

    final request = CreateAccomodationReservationRequest(
      reservationId: widget.reservationId.toString(),
      customerName: widget.customerName,
      customerPhoneNumber: widget.customerPhoneNumber,
      customerEmail: widget.customerEmail,
      trnxReference: generateTransactionReference(),
      paymentStatus: true,
      numberOfGuests: widget.numberOfGuests,
      comment: widget.comment,
      paymentChannel: "Flutterwave",
      reservationStartDate: widget.reservationStartDate,
      reservationEndDate: widget.reservationEndDate,
      noOfDays: fatNum,
      paymentType: "flutterwave",
      purchaseChannel: "Mobile App ${Platform.isIOS ? 'iOS' : 'Android'}",
      ticketClosed: true,
      staffId: globals.userId,
      staffName: globals.userName,
      userType: "Registered",
      userId: globals.userId,
    );

    final response = await ref
        .read(customerBookControllerProvider.notifier)
        .bookAccomodationReservation(request: request);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      navigateBack(context);

      final payment = FlutterwaveResponseModel.fromJson(response.data!);

      navigateToRoute(
        context,
        PaystackPaymentPage(
          url: payment.data!.link!,
          isPaystack: false,
          isPackageOrder: false,
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

          // Uncomment this when you want Flutterwave back
          // addVerticalSpacing(10),
          // _buildPaymentOption("Pay with Flutterwave", 2),
          addVerticalSpacing(10.2),

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
        width: double.infinity,
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
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
