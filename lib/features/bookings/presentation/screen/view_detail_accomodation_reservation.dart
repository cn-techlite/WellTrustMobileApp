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
import 'package:ginilog_customer_app/features/bookings/presentation/screen/book_reservation.dart';
import 'package:ginilog_customer_app/features/bookings/data/model/accomodation_reservations_response_model.dart';

class ViewAccomodationReservationPage extends ConsumerStatefulWidget {
  const ViewAccomodationReservationPage({
    required this.reservation,
    super.key,
    required this.reservationId,
  });
  final AccomodationReservationResponseModel reservation;

  final String reservationId;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<ViewAccomodationReservationPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomButton = false;
  final GlobalKey _inBodyButtonKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    // Listen to scroll events
    _scrollController.addListener(_checkInBodyButtonVisibility);
    var accomodationsReservationProviders = ref.read(
      accomodationReservationControllerProvider.notifier,
    );
    Future.microtask(() {
      accomodationsReservationProviders.getAccomodationReservationData(
        id: widget.reservationId,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Widget buildItem(
    BuildContext context,
    AccomodationReservationResponseModel reservation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top PageView Carousel
        SizedBox(
          height: 270,
          child: PageView.builder(
            controller: _pageController,
            itemCount: reservation.roomImages!.length,
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
                    image: NetworkImage(reservation.roomImages![index]),
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
            children: List.generate(reservation.roomImages!.length, (index) {
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
                      image: NetworkImage(reservation.roomImages![index]),
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
                    text: "${reservation.accomodationName}",
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
                          reservation.accomodationImage.toString(),
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
                      text: "${reservation.location}",
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
                    "Booking Price: ${moneyFormat(context, reservation.roomPrice!.toDouble())}",
                textAlign: TextAlign.start,

                color: AppColors.primaryDark,

                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        addVerticalSpacing(2),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppText(
            text: "Room Features",
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
            children: List.generate(reservation.roomFeatures!.length, (index) {
              return Container(
                width: SizeConfig.widthAdjusted(100) / 3.5,
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5),
                  child: AppText(
                    text: reservation.roomFeatures![index],
                    textAlign: TextAlign.center,

                    color: AppColors.black,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ),
        ),

        addVerticalSpacing(2),

        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AppButton(
              key: _inBodyButtonKey,
              text: "Book Now",
              onPressed: () {
                navigateToRoute(
                  context,
                  BookReservationScreen(
                    reservationId: reservation.id.toString(),
                    bookingPrice: reservation.roomPrice!,
                    maximumNoOfGuest: reservation.maximumNoOfGuest!.toInt(),
                    reservationName: reservation.accomodationName.toString(),
                    reservationAddress: reservation.location.toString(),
                  ),
                );
              },
              widthPercent: 25,
              heightPercent: 5,
              fontSize: 13,
              btnColor: AppColors.primary,
              isLoading: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppText(
            text: "${reservation.accomodationType} Room Images",
            textAlign: TextAlign.center,

            color: AppColors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(reservation.roomImages!.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(reservation.roomImages![index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
          ),
        ),

        addVerticalSpacing(1),
        const Divider(thickness: 0.7, color: AppColors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accomodationsReservation = ref.watch(
      accomodationReservationControllerProvider.notifier,
    );
    final accomodationsReservationState = ref.watch(
      accomodationReservationControllerProvider,
    );
    final data33 = accomodationsReservation.getAccomodationReservationById(
      widget.reservationId,
    );
    final isLoading = accomodationsReservationState.isLoading && data33 == null;

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
                      text: "Book Now",
                      onPressed: () {
                        navigateToRoute(
                          context,
                          BookReservationScreen(
                            reservationId: accomodationData.id.toString(),
                            bookingPrice: accomodationData.roomPrice!,
                            maximumNoOfGuest:
                                accomodationData.maximumNoOfGuest!.toInt(),
                            reservationName:
                                accomodationData.accomodationName.toString(),
                            reservationAddress:
                                accomodationData.location.toString(),
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
