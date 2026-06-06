import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_reservation_state.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/accomodation_reservation_widget.dart';
import 'package:ginilog_customer_app/main.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';

import '../../../../shared/widgets/shimmer_loader.dart';

class MainReservationScreen extends ConsumerStatefulWidget {
  const MainReservationScreen({super.key, this.accomodationId = ""});

  final String accomodationId;

  @override
  ConsumerState<MainReservationScreen> createState() =>
      _MainReservationScreenState();
}

class _MainReservationScreenState extends ConsumerState<MainReservationScreen>
    with RouteAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (widget.accomodationId.trim().isNotEmpty) {
        await ref
            .read(accomodationReservationControllerProvider.notifier)
            .setFilterAccomodationId(widget.accomodationId);
      } else {
        await ref
            .read(accomodationReservationControllerProvider.notifier)
            .getAllAccomodationReservationData();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref
          .read(accomodationReservationControllerProvider.notifier)
          .loadMoreListAccomodationReservation();
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
    ref.read(accomodationReservationControllerProvider.notifier).refreshList();
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
    final asyncState = ref.watch(accomodationReservationControllerProvider);
    final notifier = ref.read(
      accomodationReservationControllerProvider.notifier,
    );

    final data = asyncState.value ?? const AccomodationReservationState();

    final reservations = data.listAccomodationReservation;

    final isFirstLoading = asyncState.isLoading && !data.hasLoadedInitially;

    final types = <String>[
      "All",
      ...reservations
          .map((e) => e.accomodationType ?? "")
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
    ];

    final selectedType =
        data.filterTypes.trim().isEmpty ? "All" : data.filterTypes;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: AppText(
          text: "Accomodation Reservations",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child:
            isFirstLoading
                ? ListView.builder(
                  itemCount: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return buildBookingShimmerCard(context);
                  },
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reservations.isNotEmpty || data.anyItem.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SerachInput(
                          hintText:
                              "Type an accomodation name or location here",
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

                    if (types.length > 1)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          children:
                              types.map((type) {
                                final isSelected = selectedType == type;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: ChoiceChip(
                                    showCheckmark: false,
                                    label: Text(type),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      notifier.setFilterTypes(
                                        type == "All" ? "" : type,
                                      );
                                    },
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.white,
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Colors.transparent
                                              : AppColors.grey,
                                    ),
                                    labelStyle: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: AppText(
                        text:
                            selectedType == "All"
                                ? "Accomodation Reservations"
                                : selectedType,

                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (data.error != null && data.error!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AppText(
                          text: data.error!,

                          color: Colors.red,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: notifier.refreshList,
                        child:
                            reservations.isEmpty
                                ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    addVerticalSpacing(5),
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
                                            "We don't have any Accomodation Reservations at the moment",
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
                                      reservations.length +
                                      (data.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= reservations.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    return AccomodationReservationWidget(
                                      accomodationReservation:
                                          reservations[index],
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
