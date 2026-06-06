// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/money_formatter.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/view/map_tracking.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  final PackageOrderResponseModel order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;
  PackageOrderResponseModel order = PackageOrderResponseModel();

  @override
  void initState() {
    order = widget.order;
    super.initState();
  }

  void _onThumbnailTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data3 = order;

    DateTime dt2 = DateTime.parse(data3.createdAt!.toLocal().toString());
    // DateTime dt3 = data3.updatedAt!;
    String date = DateFormat("E, MMM d hh:mm a").format(dt2.toLocal());
    // String time = DateFormat("hh:mm a").format(dt3);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,

        title: AppText(
          text: "Package Details",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top PageView Carousel
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: data3.packageImageLists!.length,
                  onPageChanged: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        image: DecorationImage(
                          image: NetworkImage(data3.packageImageLists![index]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 15),

              // Bottom Thumbnails Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(data3.packageImageLists!.length, (
                    index,
                  ) {
                    return GestureDetector(
                      onTap: () => _onThumbnailTap(index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                selectedIndex == index
                                    ? Colors.blueAccent
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              data3.packageImageLists![index],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/rider_icon.png',
                              width: 50,
                              height: 50,
                            ),
                            Spacer(),
                            AppText(
                              text: "TN: ${data3.trackingNum}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "Item Name:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            AppText(
                              text: "${data3.itemName}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "Item Model No:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            AppText(
                              text: "${data3.itemModelNumber}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "Item Quantity:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            AppText(
                              text: "${data3.itemQuantity}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "Item Weight:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            AppText(
                              text: "${data3.itemWeight}Kg",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "Item Cost:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            AppText(
                              text: moneyFormat(
                                context,
                                data3.itemCost!.toDouble(),
                              ),
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        const Divider(
                          color: AppColors.primaryDark,
                          thickness: 0.3,
                        ),
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

                          color: AppColors.warning,

                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                        ),
                        AppText(
                          text: "${data3.senderPhoneNo}",
                          textAlign: TextAlign.start,

                          color: AppColors.warning,

                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          children: [
                            const AppText(
                              text: "Rider:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              maxLines: 1,
                              fontWeight: FontWeight.bold,
                            ),
                            addHorizontalSpacing(2),
                            Expanded(
                              child:
                                  data3.riderName!.isEmpty
                                      ? const AppText(
                                        text:
                                            "Order Awaiting to Assign A Rider",
                                        textAlign: TextAlign.center,

                                        color: AppColors.primaryDark,

                                        fontWeight: FontWeight.normal,
                                      )
                                      : Row(
                                        children: [
                                          addHorizontalSpacing(10),
                                          AppText(
                                            text: "${data3.riderName}",
                                            textAlign: TextAlign.start,

                                            color: AppColors.black,

                                            maxLines: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          const Spacer(),
                                          data3.orderStatus ==
                                                      OrderClassState.open ||
                                                  data3.orderStatus ==
                                                      OrderClassState.booked ||
                                                  data3.orderStatus ==
                                                      OrderClassState.picked ||
                                                  data3.orderStatus ==
                                                      OrderClassState.inTransit
                                              ? GestureDetector(
                                                onTap: () async {
                                                  Uri phoneNo = Uri.parse(
                                                    'tel:${data3.companyPhoneNo!}',
                                                  );
                                                  if (await launchUrl(
                                                    phoneNo,
                                                  )) {
                                                    //dialer opened
                                                  } else {
                                                    //dailer is not opened
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        blurRadius: 15.0,
                                                        color: Color.fromRGBO(
                                                          0,
                                                          0,
                                                          0,
                                                          0.2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 25.0,
                                                      right: 25,
                                                      top: 15,
                                                      bottom: 15,
                                                    ),
                                                    child: AppText(
                                                      text: "Contact",
                                                      textAlign:
                                                          TextAlign.center,

                                                      color: AppColors.white,

                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                            ),
                          ],
                        ),
                        addVerticalSpacing(2),
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

                          color: AppColors.warning,

                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                        ),
                        AppText(
                          text: "${data3.recieverPhoneNo}",
                          textAlign: TextAlign.start,

                          color: AppColors.warning,

                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                        ),
                        addVerticalSpacing(2),
                        AppText(
                          text: "Company Details",
                          textAlign: TextAlign.start,

                          color: AppColors.black,

                          maxLines: 1,
                          fontWeight: FontWeight.bold,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Company Name:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              maxLines: 1,
                              fontWeight: FontWeight.w500,
                            ),
                            AppText(
                              text: "${data3.companyName}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                        addVerticalSpacing(1.2),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Company Address:",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              maxLines: 1,
                              fontWeight: FontWeight.w500,
                            ),
                            AppText(
                              text: "${data3.companyAddress}",
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              maxLines: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                        addVerticalSpacing(1.2),
                        Row(
                          children: [
                            AppText(
                              text: "Company Contact",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              maxLines: 1,
                              fontWeight: FontWeight.w500,
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
                              text: "Delivery Charges",
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              maxLines: 1,
                              fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
                            ),
                            Spacer(),
                            AppText(
                              text: moneyFormat(
                                context,
                                (data3.vatCost!).toDouble(),
                              ),
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
                                (data3.shippingCost! + data3.vatCost!)
                                    .toDouble(),
                              ),
                              textAlign: TextAlign.start,

                              color: AppColors.warning,

                              maxLines: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                        addVerticalSpacing(2),
                        AppText(
                          text: date,
                          textAlign: TextAlign.start,

                          color: AppColors.green,

                          fontWeight: FontWeight.w400,
                        ),
                        const Divider(
                          color: AppColors.primaryDark,
                          thickness: 0.3,
                        ),
                        data3.orderStatus == OrderClassState.delivered
                            ? SizedBox.shrink()
                            : Align(
                              alignment: Alignment.bottomRight,
                              child: AppButton(
                                text: "Track Item",
                                onPressed: () async {
                                  navigateToRoute(
                                    context,
                                    OrderLiveTrackingPage(order: order),
                                  );
                                },
                                widthPercent: 70,
                                heightPercent: 5,
                                btnColor: AppColors.primary,
                                isLoading: false,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              addVerticalSpacing(5),
            ],
          ),
        ),
      ),
    );
  }
}
