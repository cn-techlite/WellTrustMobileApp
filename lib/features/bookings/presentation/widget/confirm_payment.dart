import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/money_formatter.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/booking_payment.dart';

class ConfirmAccomodationBookings extends ConsumerStatefulWidget {
  final String reservationId;
  final String reservationName;
  final String reservationAddress;
  final String customerName;
  final String customerPhoneNumber;
  final String customerEmail;
  final int numberOfGuests;
  final String comment;
  final String reservationStartDate;
  final String reservationEndDate;
  final int noOfDays;
  final double amount;

  const ConfirmAccomodationBookings({
    super.key,
    required this.amount,
    required this.reservationId,
    required this.reservationName,
    required this.reservationAddress,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhoneNumber,
    required this.comment,
    required this.noOfDays,
    required this.numberOfGuests,
    required this.reservationEndDate,
    required this.reservationStartDate,
  });

  @override
  ConsumerState<ConfirmAccomodationBookings> createState() =>
      _ConfirmAccomodationBookingsState();
}

class _ConfirmAccomodationBookingsState
    extends ConsumerState<ConfirmAccomodationBookings> {
  bool isLoading = false;
  int selected = 0;
  String paymentMethodUse = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        backgroundColor: AppColors.white,
        title: AppText(
          text: "Accomodation Payment",
          textAlign: TextAlign.center,
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          type: AppTextType.bodyMedium,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppText(
                text: "Bookings Summary",
                textAlign: TextAlign.start,

                color: AppColors.primary,

                maxLines: 1,
                fontWeight: FontWeight.bold,
              ),
              Divider(),
              AppText(
                text: "Accomodation Details",
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.bold,
              ),
              AppText(
                text: widget.reservationName,
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.w400,
              ),
              AppText(
                text: widget.reservationAddress,
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.w400,
              ),
              addVerticalSpacing(5),
              AppText(
                text: "Customer Details",
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.bold,
              ),
              AppText(
                text: widget.customerName,
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.w400,
              ),
              AppText(
                text: widget.customerEmail,
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.w400,
              ),
              AppText(
                text: widget.customerPhoneNumber,
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.w400,
              ),
              addVerticalSpacing(5),
              AppText(
                text: "Order Details",
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  AppText(
                    text: "Number of Guest",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: "${widget.numberOfGuests}",
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              Row(
                children: [
                  AppText(
                    text: "Duration",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: "${widget.noOfDays} Days",
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              Row(
                children: [
                  AppText(
                    text: "Check In Date",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: widget.reservationStartDate,
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              Row(
                children: [
                  AppText(
                    text: "Check Out Date",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: widget.reservationEndDate,
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              addVerticalSpacing(5),
              Divider(),
              addVerticalSpacing(5),
              AppText(
                text: "Charges",
                textAlign: TextAlign.start,

                color: AppColors.black,

                maxLines: 1,
                fontWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  AppText(
                    text: "Booking Price",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: moneyFormat(context, (widget.amount).toDouble()),
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  AppText(
                    text: "Total Cost",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  Spacer(),
                  AppText(
                    text: moneyFormat(
                      context,
                      (widget.amount * widget.noOfDays).toDouble(),
                    ),
                    textAlign: TextAlign.start,

                    color: AppColors.warning,

                    maxLines: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              addVerticalSpacing(10),
              Align(
                alignment: Alignment.bottomRight,
                child: AppButton(
                  text: "Make Payment",
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(
                              context,
                            ).size.width, // 👈 full width even on iPad
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder:
                          (context) => BookingPaymentBottomSheet(
                            amount: widget.amount,
                            reservationId: widget.reservationId,
                            customerName: widget.customerName,
                            customerEmail: widget.customerEmail,
                            customerPhoneNumber: widget.customerPhoneNumber,
                            comment: widget.comment,
                            noOfDays: widget.noOfDays,
                            numberOfGuests: widget.numberOfGuests,
                            reservationEndDate: widget.reservationEndDate,
                            reservationStartDate: widget.reservationStartDate,
                          ),
                    );
                  },
                  widthPercent: 50,
                  heightPercent: 6,
                  btnColor: AppColors.primary,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
