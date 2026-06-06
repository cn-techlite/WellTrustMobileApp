import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/view/order_items.dart';

class OngoingTab extends ConsumerStatefulWidget {
  final List<PackageOrderResponseModel> ongoingOrder;
  final String userPhone;
  final ScrollController scrollController;
  final bool isLoadingMore;
  const OngoingTab({
    super.key,
    required this.ongoingOrder,
    required this.userPhone,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  ConsumerState<OngoingTab> createState() => _OngoingTabState();
}

class _OngoingTabState extends ConsumerState<OngoingTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.ongoingOrder.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      addVerticalSpacing(25),
                      const AppText(
                        text: "Nothing to show here",
                        textAlign: TextAlign.start,

                        color: AppColors.black,

                        fontWeight: FontWeight.bold,
                      ),
                      const AppText(
                        text: "You don't have any order at the moment",
                        textAlign: TextAlign.center,

                        color: AppColors.black,

                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount:
                      widget.ongoingOrder.length +
                      (widget.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= widget.ongoingOrder.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return ActiveOrderItem(
                      order: widget.ongoingOrder[index],
                      userPhone: widget.userPhone,
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
