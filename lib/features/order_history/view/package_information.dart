// ignore_for_file: use_build_context_synchronously

import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/money_formatter.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/provider/package_provider.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/features/home_screen.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/widget/payment_set.dart';

class PackageInformationPage extends ConsumerStatefulWidget {
  final PackageOrderResponseModel order;
  final String userPhone;
  const PackageInformationPage({
    super.key,
    required this.order,
    required this.userPhone,
  });

  @override
  ConsumerState<PackageInformationPage> createState() =>
      _PackageInformationPageState();
}

class _PackageInformationPageState
    extends ConsumerState<PackageInformationPage> {
  bool isLoading = false;
  int selected = 0;
  String paymentMethodUse = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var notifier = ref.read(packageOrderControllerProvider.notifier);

      notifier.getPackageOrderData(id: widget.order.id!);

      /// Connect to WebSocket for future updates
      notifier.connectAndJoinOrder(
        orderId: widget.order.userId ?? "",
        isSingle: false,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final data3 = widget.order;
    final packageOrder = ref.watch(packageOrderControllerProvider.notifier);
    final packageOrderState = ref.watch(packageOrderControllerProvider);
    final data33 = packageOrder.getPackageOrderById(widget.order.id!);
    final isLoading = packageOrderState.isLoading && data33 == null;

    final data3 = data33 ?? widget.order;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,

        title: AppText(
          text: "Make Payment",
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
                  text: "Package Information",
                  textAlign: TextAlign.start,

                  color: AppColors.primary,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                Divider(),
                AppText(
                  text: "Origin Details",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                  text: "${data3.senderAddress}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                AppText(
                  text: "${data3.senderPhoneNo}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                addVerticalSpacing(5),
                AppText(
                  text: "Destination Details",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                  text: "${data3.recieverAddress}",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.w400,
                ),
                AppText(
                  text: "${data3.recieverPhoneNo}",
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
                      text: "Item Name",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.itemName}",
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
                        text: "Tracking Number",
                        textAlign: TextAlign.start,

                        color: AppColors.black,

                        maxLines: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Expanded(
                      child: AppText(
                        text: "${data3.trackingNum}",
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
                      text: "Item Quantity",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.itemQuantity}",
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
                addVerticalSpacing(5),
                AppText(
                  text: "Company Details",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: "Company Name",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    Expanded(
                      child: AppText(
                        text: "${data3.companyName}",
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
                      text: "Company Address",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    Expanded(
                      child: AppText(
                        text: "${data3.companyAddress}",
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
                      text: "Company Contact",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: "${data3.companyPhoneNo}",
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
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
                      text: "Delivery Charges",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      maxLines: 1,
                      fontWeight: FontWeight.w400,
                    ),
                    Spacer(),
                    AppText(
                      text: moneyFormat(
                        context,
                        (data3.shippingCost!).toDouble(),
                      ),
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
                      text: moneyFormat(context, (data3.vatCost!).toDouble()),
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
                        (data3.shippingCost! + data3.vatCost!).toDouble(),
                      ),
                      textAlign: TextAlign.start,

                      color: AppColors.warning,

                      maxLines: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
                addVerticalSpacing(4),
                AppText(
                  text:
                      data3.shippingCost == 0
                          ? "Waiting for the company to update the shipping cost once the pick up the package"
                          : "",
                  textAlign: TextAlign.start,

                  color: AppColors.black,

                  fontWeight: FontWeight.w500,
                ),
                addVerticalSpacing(2),
                Row(
                  children: [
                    AppButton(
                      text: "Back Home",
                      onPressed: () async {
                        navigateAndReplaceRoute(
                          context,
                          HomeScreenPage(imdex: 0),
                        );
                      },
                      widthPercent: 30,
                      heightPercent: 6,
                      textColor: AppColors.white,
                      btnColor: AppColors.primary,
                      isLoading: false,
                    ),
                    Spacer(),
                    data3.shippingCost == 0
                        ? AppButton(
                          text:
                              "Waiting for the company to update the shipping cost",
                          onPressed: () async {
                            //  showPaymentMethodSelection(context);
                          },
                          widthPercent: 50,
                          heightPercent: 6,
                          textColor: AppColors.black,
                          btnColor: AppColors.grey,
                          isLoading: false,
                        )
                        : AppButton(
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
                                  (context) => PaymentMethodBottomSheet(
                                    order: widget.order,
                                  ),
                            );
                          },
                          widthPercent: 50,
                          heightPercent: 6,
                          textColor: AppColors.white,
                          btnColor: AppColors.green,
                          isLoading: isLoading,
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
