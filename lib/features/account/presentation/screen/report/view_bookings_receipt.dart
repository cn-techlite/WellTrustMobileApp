import 'dart:convert';

import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/money_formatter.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/customer_book_response_model.dart';

class ViewCustomerBookReceiptPage extends ConsumerStatefulWidget {
  final CustomerBookResponseModel order;
  const ViewCustomerBookReceiptPage({super.key, required this.order});

  @override
  ConsumerState<ViewCustomerBookReceiptPage> createState() =>
      _ViewCustomerBookReceiptPageState();
}

class _ViewCustomerBookReceiptPageState
    extends ConsumerState<ViewCustomerBookReceiptPage> {
  bool isLoading = false;
  String generateTransactionReference() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    final data3 = widget.order;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,

        title: AppText(
          text: "Booking Receipt",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AppText(
                  text: "Bookings Information",
                  textAlign: TextAlign.start,

                  color: AppColors.primary,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                Divider(),
                AppText(
                  text: "Customer Details",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                  text: "${data3.customerName}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                AppText(
                  text: "${data3.customerPhoneNumber}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),

                AppText(
                  text: "No of Guest: ${data3.numberOfGuests}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                AppText(
                  text: "Accomodation Type: ${data3.accomodationType}",
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
                      text: "Room",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.roomNumber}",
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: "Start",
                        textAlign: TextAlign.start,

                        color: AppColors.black,

                        maxLines: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Expanded(
                      child: AppText(
                        text: DateFormatter.formatDateTime(
                          data3.reservationStartDate!,
                        ),
                        textAlign: TextAlign.start,

                        color: AppColors.warning,

                        maxLines: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: "End Date",
                        textAlign: TextAlign.start,

                        color: AppColors.black,

                        maxLines: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Expanded(
                      child: AppText(
                        text: DateFormatter.formatDateTime(
                          data3.reservationEndDate!,
                        ),
                        textAlign: TextAlign.start,

                        color: AppColors.warning,

                        maxLines: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppText(
                      text: "Ticket #",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.ticketNum}",
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
                      text: "Payment Channel",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.paymentChannel}",
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
                      text: "Transaction Reference",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.trnxReference}",
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
                addVerticalSpacing(2),
                AppText(
                  text: "Accomodation Details",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: "Reservation Name",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    Expanded(
                      child: AppText(
                        text: "${data3.accomodationName}",
                        textAlign: TextAlign.start,

                        color: AppColors.warning,

                        maxLines: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: "Reservation Location",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    Expanded(
                      child: AppText(
                        text: "${data3.accomodationLocation}",
                        textAlign: TextAlign.start,

                        color: AppColors.warning,

                        maxLines: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Divider(),
                addVerticalSpacing(2),
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
                      text: "Payment Charges",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: moneyFormat(context, (data3.totalCost!).toDouble()),
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
                      text: "Vat/Tax Services",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: moneyFormat(context, (data3.totalCost!).toDouble()),
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
                        (data3.totalCost! + data3.totalCost!).toDouble(),
                      ),
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
                addVerticalSpacing(1),
                Center(
                  child: Image.memory(
                    base64Decode(data3.qrCode!),
                    height: SizeConfig.heightAdjusted(50),
                    width: SizeConfig.widthAdjusted(50),
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
