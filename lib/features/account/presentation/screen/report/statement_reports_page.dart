import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/account/presentation/widget/bookings_item.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/customer_book_state.dart';
import 'package:ginilog_customer_app/main.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';

class StatementReportScreen extends ConsumerStatefulWidget {
  const StatementReportScreen({super.key});

  @override
  ConsumerState<StatementReportScreen> createState() =>
      _StatementReportScreenState();
}

class _StatementReportScreenState extends ConsumerState<StatementReportScreen>
    with RouteAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      await ref
          .read(customerBookControllerProvider.notifier)
          .getAllCustomerBookData();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref
          .read(customerBookControllerProvider.notifier)
          .loadMoreListCustomerBook();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    ref.read(customerBookControllerProvider.notifier).refreshList();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(customerBookControllerProvider);
    final notifier = ref.read(customerBookControllerProvider.notifier);

    final data = asyncState.value ?? const CustomerBookState();

    final reservationsList = data.listCustomerBook;

    final isFirstLoading = asyncState.isLoading && !data.hasLoadedInitially;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: AppText(
          text: "Bookings Report",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child:
            isFirstLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.0,
                  ),
                )
                : Column(
                  children: [
                    if (reservationsList.isNotEmpty || data.anyItem.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SerachInput(
                          hintText: "Search bookings...",
                          labelText: "",
                          readOnly: false,
                          prefixIcon: Icons.search,
                          prefix: Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.grey.withValues(),
                          ),
                          keyboard: TextInputType.text,
                          styleColor: AppColors.black,
                          labelColor: AppColors.black,
                          hintStyleColor: AppColors.black,
                          onChanged: (value) {
                            notifier.onSearchChanged(value ?? "");
                          },
                          validator: (value) => null,
                          toggleEye: () {},
                          onSaved: (value) {},
                          onTap: () {},
                        ),
                      ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: notifier.refreshList,
                        child:
                            reservationsList.isEmpty
                                ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    addVerticalSpacing(15),
                                    const Center(
                                      child: AppText(
                                        text: "Nothing to show here",
                                        textAlign: TextAlign.start,

                                        color: AppColors.black,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: AppText(
                                        text:
                                            "You don't have any Bookings at the moment",
                                        textAlign: TextAlign.center,

                                        color: AppColors.black,

                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount:
                                      reservationsList.length +
                                      (data.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= reservationsList.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    return CustomerItemPage(
                                      accomodation: reservationsList[index],
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
