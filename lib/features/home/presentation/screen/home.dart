// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:ginilog_customer_app/core/helpers/globals.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/screen/reservation_screen.dart';
import 'package:ginilog_customer_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:ginilog_customer_app/features/home/presentation/state/state_model/advert_state.dart';
import 'package:ginilog_customer_app/features/home/presentation/widget/order_page_widget.dart';
import 'package:ginilog_customer_app/features/home/presentation/widget/send_parcel_bottomsheet.dart';
import 'package:ginilog_customer_app/features/home_screen.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/provider/package_provider.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/state_model/package_order_state.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/arrow_line_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  String userPhone = "";
  String profilePicture = "";
  String allNames = "";

  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      final user = ref.read(accountProvider).value?.userData;

      profilePicture = user?.profilePicture ?? globals.profilePicture;
      userPhone = user?.phoneNo ?? "";
      allNames =
          "${user?.firstName ?? globals.userName} ${user?.lastName ?? ""}"
              .trim();

      await ref
          .read(packageOrderControllerProvider.notifier)
          .getAllPackageOrderData();

      await ref.read(logisticsControllerProvider.notifier).getAllLogisticData();

      await ref
          .read(advertControllerProvider.notifier)
          .getAllAdvertExploreData();

      final userId = globals.userId;

      if (userId.isNotEmpty) {
        await ref
            .read(packageOrderControllerProvider.notifier)
            .connectAndJoinOrder(orderId: userId, isSingle: false);
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ref.read(packageOrderControllerProvider.notifier).disconnect();
    super.dispose();
  }

  void pageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(packageOrderControllerProvider);
    final orderState = orderAsync.value ?? const PackageOrderState();

    final advertAsync = ref.watch(advertControllerProvider);
    final advertState = advertAsync.value ?? const AdvertStateModel();

    final orders = orderState.listPackageOrder;
    final adverts = advertState.explore;

    final isOrderLoading =
        orderAsync.isLoading && !orderState.hasLoadedInitially;

    final isAdvertLoading = advertAsync.isLoading && !advertState.hasFetched;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(packageOrderControllerProvider.notifier)
                .refreshList();

            await ref
                .read(advertControllerProvider.notifier)
                .getAllAdvertExploreData(forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      navigateToRoute(context, HomeScreenPage(imdex: 3));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.grey5,
                          radius: 15,
                          backgroundImage:
                              profilePicture.isEmpty
                                  ? const AssetImage(
                                    "assets/images/profile_icon.png",
                                  )
                                  : NetworkImage(profilePicture)
                                      as ImageProvider,
                        ),

                        addHorizontalSpacing(5),

                        AppText(
                          text: allNames,
                          textAlign: TextAlign.start,

                          color: AppColors.black,

                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),

                  addVerticalSpacing(5),

                  if (isAdvertLoading)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (adverts.isEmpty)
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/book_hotel.png"),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        CarouselSlider(
                          carouselController: carouselController,
                          options: CarouselOptions(
                            autoPlay: true,
                            viewportFraction: 1,
                            aspectRatio: 16 / 9,
                            height: 200,
                            initialPage: 0,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              pageChanged(index);
                            },
                          ),
                          items: List.generate(
                            adverts.length,
                            (index) => InkWell(
                              onTap: () {},
                              child: Card(
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        adverts[index].advertImage ?? "",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        addVerticalSpacing(5),

                        Center(
                          child: AnimatedSmoothIndicator(
                            activeIndex: currentIndex,
                            count: adverts.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.blue,
                              dotColor: Colors.grey,
                            ),
                            onDotClicked: (index) {
                              carouselController.animateToPage(index);
                            },
                          ),
                        ),
                      ],
                    ),

                  addVerticalSpacing(2),

                  Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          size: const Size(100, 10),
                          painter: ArrowPainter(isArrowAtStart: false),
                        ),
                      ),
                      const AppText(
                        text: "Our Services",
                        textAlign: TextAlign.start,

                        color: AppColors.black,

                        fontWeight: FontWeight.w500,
                      ),
                      Expanded(
                        child: CustomPaint(
                          size: const Size(100, 10),
                          painter: ArrowPainter(isArrowAtStart: true),
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(1),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 30.heightAdjusted,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width,
                                ),
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => SendParcelTypeBottomSheet(
                                      phoneNumber: userPhone,
                                    ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: SizeConfig.widthAdjusted(100) / 2,
                                  height: 20.heightAdjusted,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(
                                        "assets/images/place_order_items.png",
                                      ),
                                    ),
                                  ),
                                ),
                                addVerticalSpacing(2),
                                const AppText(
                                  text: "Send A Parcel",
                                  textAlign: TextAlign.start,

                                  color: AppColors.black,

                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ),

                        addHorizontalSpacing(10),

                        SizedBox(
                          height: 30.heightAdjusted,
                          child: GestureDetector(
                            onTap: () {
                              navigateToRoute(
                                context,
                                const MainReservationScreen(),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: SizeConfig.widthAdjusted(100) / 2,
                                  height: 20.heightAdjusted,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(
                                        "assets/images/book_hotel.png",
                                      ),
                                    ),
                                  ),
                                ),
                                addVerticalSpacing(2),
                                const AppText(
                                  text: "Accommodation Bookings",
                                  textAlign: TextAlign.start,

                                  color: AppColors.black,

                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  addVerticalSpacing(1),

                  const AppText(
                    text: "Recent Orders",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    fontWeight: FontWeight.bold,
                  ),

                  addVerticalSpacing(1),

                  if (isOrderLoading)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    OrderPageWidget(allOrder: orders, userPhone: userPhone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
