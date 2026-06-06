import 'package:ginilog_customer_app/core/helpers/globals.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/provider/package_provider.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/state_model/package_order_state.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/widget/ongoing_tab.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late final TabController tabController;
  final ScrollController scrollController = ScrollController();

  String userPhone = "";

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      final user = ref.read(accountProvider).value?.userData;
      userPhone = user?.phoneNo ?? "";

      await ref
          .read(packageOrderControllerProvider.notifier)
          .getAllPackageOrderData();

      final userId = globals.userId;

      if (userId.isNotEmpty) {
        await ref
            .read(packageOrderControllerProvider.notifier)
            .connectAndJoinOrder(orderId: userId, isSingle: false);
      }

      if (mounted) setState(() {});
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref
          .read(packageOrderControllerProvider.notifier)
          .loadMoreListPackageOrder();
    }
  }

  @override
  void dispose() {
    ref.read(packageOrderControllerProvider.notifier).disconnect();

    scrollController
      ..removeListener(_onScroll)
      ..dispose();

    tabController.dispose();

    super.dispose();
  }

  void selectTab(int index) {
    tabController.animateTo(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(packageOrderControllerProvider);
    final notifier = ref.read(packageOrderControllerProvider.notifier);

    final data = asyncState.value ?? const PackageOrderState();

    final orders = data.listPackageOrder;

    final isLoading = asyncState.isLoading && !data.hasLoadedInitially;

    final pending =
        orders.where((element) {
          return element.orderStatus == OrderClassState.open ||
              element.orderStatus == OrderClassState.booked;
        }).toList();

    final ongoingOrder =
        orders.where((element) {
          return element.orderStatus == OrderClassState.picked ||
              element.orderStatus == OrderClassState.inTransit;
        }).toList();

    final completedOrder =
        orders.where((element) {
          return element.orderStatus == OrderClassState.delivered;
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        showBackButton: false,
        title: const AppText(
          text: "My Orders",
          textAlign: TextAlign.start,

          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
        bottomWidget: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final selected = tabController.index == index;

                return ElevatedButton(
                  onPressed: () => selectTab(index),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: selected ? Colors.red : Colors.white,
                    foregroundColor: selected ? Colors.white : AppColors.grey2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    ['Pending', 'In-transit', 'Completed', 'All'][index],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
                : RefreshIndicator(
                  onRefresh: notifier.refreshList,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      OngoingTab(
                        ongoingOrder: pending,
                        userPhone: userPhone,
                        scrollController: scrollController,
                        isLoadingMore: data.isLoadingMore,
                      ),
                      OngoingTab(
                        ongoingOrder: ongoingOrder,
                        userPhone: userPhone,
                        scrollController: scrollController,
                        isLoadingMore: data.isLoadingMore,
                      ),
                      OngoingTab(
                        ongoingOrder: completedOrder,
                        userPhone: userPhone,
                        scrollController: scrollController,
                        isLoadingMore: data.isLoadingMore,
                      ),
                      OngoingTab(
                        ongoingOrder: orders,
                        userPhone: userPhone,
                        scrollController: scrollController,
                        isLoadingMore: data.isLoadingMore,
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
