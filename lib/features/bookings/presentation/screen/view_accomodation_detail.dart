// ignore_for_file: library_private_types_in_public_api

import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/money_formatter.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/review_summary.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/screen/add_review.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/accomodation_response_model.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/screen/find_availablity_page.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/screen/view_all_review.dart';

class ViewAccomodationPage extends ConsumerStatefulWidget {
  const ViewAccomodationPage({
    required this.reservation,
    super.key,
    required this.accomodationId,
  });
  final AccomodationResponseModel reservation;
  final String accomodationId;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<ViewAccomodationPage> {
  // AccomodationResponseModel accomodationData = AccomodationResponseModel();
  final ScrollController _scrollController = ScrollController();
  bool _showBottomButton = false;
  final GlobalKey _inBodyButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    // Listen to scroll events
    _scrollController.addListener(_checkInBodyButtonVisibility);
    var accomodationsProviders = ref.read(
      accomodationControllerProvider.notifier,
    );
    Future.microtask(() {
      accomodationsProviders.getAccomodationData(id: widget.accomodationId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<int, int> getReviewCounts(List<AccomodationReviewModel> reviews) {
    Map<int, int> reviewCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in reviews) {
      int rating = (review.ratingNum ?? 0).toInt(); // Convert num to int
      if (reviewCounts.containsKey(rating)) {
        reviewCounts[rating] = reviewCounts[rating]! + 1;
      }
    }

    return reviewCounts;
  }

  void _checkInBodyButtonVisibility() {
    RenderBox? box =
        _inBodyButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      bool isButtonVisible = position.dy < MediaQuery.of(context).size.height;

      setState(() {
        _showBottomButton = !isButtonVisible;
      });
    }
  }

  final PageController _pageController = PageController();
  int selectedIndex = 0;

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

  Widget _description(String description) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Description",

                    style: TextStyle(
                      fontSize: 15.textSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Inter",
                      color: AppColors.black,
                    ),
                  ),
                ),
                collapsed: Text(
                  description,
                  softWrap: true,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 12.textSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var _ in Iterable.generate(1))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          description,
                          softWrap: true,
                          overflow: TextOverflow.fade,

                          style: TextStyle(
                            fontSize: 18.textSize,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Mulish",
                            color: AppColors.black,
                          ),
                        ),
                      ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, AccomodationResponseModel userChat) {
    var reviews = userChat.accomodationReviewModels!.take(5).toList();
    Map<int, int> reviewCounts = getReviewCounts(
      userChat.accomodationReviewModels!,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top PageView Carousel
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _pageController,
            itemCount: userChat.accomodationImages!.length,
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
                    image: NetworkImage(userChat.accomodationImages![index]),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(userChat.accomodationImages!.length, (
              index,
            ) {
              return GestureDetector(
                onTap: () => _onThumbnailTap(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 80,
                  height: 60,
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
                      image: NetworkImage(userChat.accomodationImages![index]),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppText(
                    text: "${userChat.accomodationName}",
                    textAlign: TextAlign.start,

                    color: AppColors.primaryDark,

                    fontWeight: FontWeight.bold,
                  ),
                  Spacer(),
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey, width: 1),
                      borderRadius: BorderRadius.circular(50),
                      //set border radius to 50% of square height and width
                      image: DecorationImage(
                        image: NetworkImage(
                          userChat.accomodationLogo.toString(),
                        ),
                        fit: BoxFit.contain, //change image fill type
                      ),
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(2),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/svgs/loaction_icon.svg', width: 20),
                  Expanded(
                    child: AppText(
                      text:
                          "${userChat.location}, ${userChat.locality}, ${userChat.state}",
                      textAlign: TextAlign.start,

                      color: AppColors.black,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(2),
              const AppText(
                text: "Opens Monday - Sunday",
                textAlign: TextAlign.start,

                color: AppColors.black,

                fontWeight: FontWeight.w600,
              ),
              addVerticalSpacing(2),
              AppText(
                text:
                    "Booking Price: ${moneyFormat(context, userChat.bookingAmount!.toDouble())}",
                textAlign: TextAlign.start,

                color: AppColors.primaryDark,

                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),

        addVerticalSpacing(2),
        userChat.accomodationDescription!.isEmpty
            ? const SizedBox.shrink()
            : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: _description("${userChat.accomodationDescription}"),
            ),
        addVerticalSpacing(2),
        Row(
          children: [
            addHorizontalSpacing(10),
            AppButton(
              key: _inBodyButtonKey,
              text: "Find Availability",
              onPressed: () {
                navigateToRoute(
                  context,
                  FindReservationPage(
                    accommodationId: widget.reservation.id.toString(),
                    accommodationName:
                        widget.reservation.accomodationName.toString(),
                  ),
                );
              },
              widthPercent: 40,
              heightPercent: 5,
              btnColor: AppColors.primary,
              isLoading: false,
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppText(
            text: "${widget.reservation.accomodationType} Facilities",
            textAlign: TextAlign.center,

            color: AppColors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(userChat.accomodationFacilities!.length, (
              index,
            ) {
              return Container(
                width: SizeConfig.widthAdjusted(100) / 3.5,
                decoration: BoxDecoration(
                  color: AppColors.grey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                  child: AppText(
                    text: userChat.accomodationFacilities![index],
                    textAlign: TextAlign.center,

                    color: AppColors.black,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
        ),
        addVerticalSpacing(1),
        const Divider(thickness: 0.7, color: AppColors.grey),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppText(
                    text: "Reviews",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      navigateToRoute(
                        context,
                        AddAccomodationReviewScreen(
                          accomodationId: userChat.id.toString(),
                          accomodationLogo:
                              userChat.accomodationLogo.toString(),
                          accomodationName:
                              userChat.accomodationName.toString(),
                        ),
                      );
                    },
                    child: const AppText(
                      text: "Add ReView",
                      textAlign: TextAlign.start,

                      decoration: TextDecoration.underline,
                      color: AppColors.primary,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(3),
              userChat.accomodationReviewModels!.isEmpty
                  ? SizedBox.shrink()
                  : ReviewSummary(reviews: reviewCounts),
              addVerticalSpacing(3),
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Column(
                  children: List.generate(reviews.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              height: 30.0,
                              width: 30.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                //set border radius to 50% of square height and width
                                image: DecorationImage(
                                  image: NetworkImage(
                                    reviews[index].profileImage.toString(),
                                  ),
                                  fit: BoxFit.contain, //change image fill type
                                ),
                              ),
                            ),
                            addHorizontalSpacing(10),
                            AppText(
                              text: "${reviews[index].userName}",
                              textAlign: TextAlign.start,

                              color: AppColors.primaryDark,

                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        RatingBar.readOnly(
                          isHalfAllowed: true,
                          alignment: Alignment.centerLeft,
                          halfFilledIcon: Icons.star_half,
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          emptyColor: Colors.yellow,
                          halfFilledColor: Colors.grey,
                          initialRating: reviews[index].ratingNum!.toDouble(),
                          size: 15,
                        ),
                        addVerticalSpacing(4),
                        AppText(
                          text: "${reviews[index].reviewMessage}",
                          textAlign: TextAlign.start,

                          color: AppColors.primaryDark,

                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    );
                  }),
                ),
              ),
              userChat.accomodationReviewModels!.isEmpty
                  ? SizedBox.shrink()
                  : Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        navigateToRoute(
                          context,
                          ViewAllReviewPagePage(
                            accomodationName:
                                userChat.accomodationName.toString(),
                            reviews: userChat.accomodationReviewModels!,
                          ),
                        );
                      },
                      child: const AppText(
                        text: "See All Review",
                        textAlign: TextAlign.start,

                        decoration: TextDecoration.underline,
                        color: AppColors.primary,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              addVerticalSpacing(5),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accomodations = ref.watch(accomodationControllerProvider.notifier);
    final accomodationState = ref.watch(accomodationControllerProvider);
    final data33 = accomodations.getAccomodationById(widget.accomodationId);
    final isLoading = accomodationState.isLoading && data33 == null;

    return Builder(
      builder: (context) {
        if (isLoading) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: buildFlexibleAppBar(
              context: context,
              title: AppText(
                text: "",
                textAlign: TextAlign.center,

                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),

            body: Center(child: CircularProgressIndicator()),
          );
        }

        var accomodationData = data33 ?? widget.reservation;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: buildFlexibleAppBar(
            context: context,

            title: AppText(
              text: "${accomodationData.accomodationName}",
              textAlign: TextAlign.start,
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: buildItem(context, accomodationData),
                    ),
                  ),
                ),
                // Bottom "Book" Button (only shown when in-body button is not visible)
                if (_showBottomButton)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: AppButton(
                      text: "Find Availability",
                      onPressed: () {
                        navigateToRoute(
                          context,
                          FindReservationPage(
                            accommodationId: accomodationData.id.toString(),
                            accommodationName:
                                accomodationData.accomodationName.toString(),
                          ),
                        );
                      },
                      widthPercent: 100,
                      heightPercent: 6,
                      btnColor: AppColors.primary,
                      isLoading: false,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
