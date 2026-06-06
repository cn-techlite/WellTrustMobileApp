import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/accomodation_state.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/accomodation_item_widget.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';
import 'package:ginilog_customer_app/shared/widgets/shimmer_loader.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(accomodationControllerProvider.notifier)
          .getAllAccomodationData();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref
          .read(accomodationControllerProvider.notifier)
          .loadMoreListAccomodation();
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
    final asyncState = ref.watch(accomodationControllerProvider);
    final notifier = ref.read(accomodationControllerProvider.notifier);

    final data = asyncState.value ?? const AccomodationState();

    final accommodations = data.listAccomodation;

    final isFirstLoading = asyncState.isLoading && !data.hasLoadedInitially;

    final types = <String>[
      "All",
      ...accommodations
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
        showBackButton: false,
        title: AppText(
          text: "Bookings",
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
                    if (accommodations.isNotEmpty || data.anyItem.isNotEmpty)
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
                            size: 40,
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
                                ? "Accomodations"
                                : selectedType,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: notifier.refreshList,
                        child:
                            accommodations.isEmpty
                                ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    Icon(
                                      Icons.search_off,
                                      size: 50,
                                      color: AppColors.grey2,
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                      child: AppText(
                                        text: "No matching results found",

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
                                      accommodations.length +
                                      (data.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= accommodations.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    return AccomodationItemWidget(
                                      dataModel: accommodations[index],
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
