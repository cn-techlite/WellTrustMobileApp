// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/logistic_state.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/package_export.dart';
import '../../../../shared/widgets/app_text.dart';

class ViewAllLogisticsPage extends ConsumerStatefulWidget {
  const ViewAllLogisticsPage({
    required this.state,
    required this.city,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final String state;
  final String city;
  final num latitude;
  final num longitude;

  @override
  ConsumerState<ViewAllLogisticsPage> createState() =>
      _ViewAllLogisticsPageState();
}

class _ViewAllLogisticsPageState extends ConsumerState<ViewAllLogisticsPage> {
  final ScrollController _scrollController = ScrollController();

  final num distance = 10.0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier = ref.read(logisticsControllerProvider.notifier);

      await notifier.setStateFilter(widget.state);

      if (widget.city.isNotEmpty) {
        await notifier.setLocalityFilter(widget.city);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref.read(logisticsControllerProvider.notifier).loadMoreListLogistic();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  num calculateDistance(num lat1, num lon1, num lat2, num lon2) {
    const earthRadiusKm = 6371;

    num dLat = _degreesToRadians(lat2 - lat1);
    num dLon = _degreesToRadians(lon2 - lon1);

    num a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    num c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  num _degreesToRadians(num degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(logisticsControllerProvider);

    final notifier = ref.read(logisticsControllerProvider.notifier);

    final data = asyncState.value ?? const LogisticState();

    final isLoading = asyncState.isLoading && !data.hasLoadedInitially;

    final logistics = data.listLogistic.where((element) {
      if (element.available != true) {
        return false;
      }

      final distanceFilter = calculateDistance(
        widget.latitude,
        widget.longitude,
        element.latitude ?? 0,
        element.longitude ?? 0,
      );

      return distanceFilter <= distance;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "Logistics Company",
          textAlign: TextAlign.start,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.refreshList,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : logistics.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: SizeConfig.heightAdjusted(20)),

                      Image.asset(
                        "assets/images/empty.png",
                        width: 100,
                        height: 100,
                      ),

                      addVerticalSpacing(5),

                      const Center(
                        child: AppText(
                          text: "Coming soon!",
                          textAlign: TextAlign.start,

                          color: AppColors.black,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AppText(
                          text:
                              "There is no available Logistics Company in Your location",
                          textAlign: TextAlign.center,

                          color: AppColors.black,

                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: logistics.length + (data.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= logistics.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final company = logistics[index];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              // navigateToRoute(...)
                            },
                            child: Row(
                              children: [
                                addHorizontalSpacing(10),

                                Container(
                                  margin: const EdgeInsets.all(5),
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        company.companyLogo ?? "",
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                addHorizontalSpacing(10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: company.companyName ?? "",
                                        textAlign: TextAlign.start,

                                        color: AppColors.black,

                                        maxLines: 1,
                                        fontWeight: FontWeight.bold,
                                      ),

                                      AppText(
                                        text:
                                            "${company.companyAddress ?? ""}, ${company.locality ?? ""}, ${company.state ?? ""}",
                                        textAlign: TextAlign.start,

                                        color: AppColors.black,

                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(thickness: 0.7, color: AppColors.grey),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
