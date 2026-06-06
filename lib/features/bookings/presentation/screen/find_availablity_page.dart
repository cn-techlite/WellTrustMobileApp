import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_reservation_state.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/find_reservation_widget.dart';
import 'package:ginilog_customer_app/shared/widgets/shimmer_loader.dart';

import '../../../../core/utils/package_export.dart';

class FindReservationPage extends ConsumerStatefulWidget {
  const FindReservationPage({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
  });

  final String accommodationId;
  final String accommodationName;

  @override
  ConsumerState<FindReservationPage> createState() =>
      _FindReservationPageState();
}

class _FindReservationPageState extends ConsumerState<FindReservationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(accomodationReservationControllerProvider.notifier)
          .setFilterAccomodationId(widget.accommodationId);
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
  void dispose() {
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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: AppText(
          text: "${widget.accommodationName} Available Rooms",
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
                : RefreshIndicator(
                  onRefresh: notifier.refreshList,
                  child:
                      reservations.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                padding: EdgeInsets.symmetric(horizontal: 20),
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
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                reservations.length +
                                (data.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= reservations.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              return FindReservationWidget(
                                accomodationReservation: reservations[index],
                              );
                            },
                          ),
                ),
      ),
    );
  }
}
