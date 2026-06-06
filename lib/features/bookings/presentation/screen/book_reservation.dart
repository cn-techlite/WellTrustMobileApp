// ignore_for_file: use_build_context_synchronously

import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/bookings/data/services/booking_remote_service.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/providers/bookings_providers.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/state/state_model/customer_book_state.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/date_select_widget.dart';
import 'package:ginilog_customer_app/shared/state/connectivity_state.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/features/bookings/presentation/widget/confirm_payment.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';

class BookReservationScreen extends ConsumerStatefulWidget {
  const BookReservationScreen({
    super.key,
    required this.reservationId,
    required this.reservationName,
    required this.reservationAddress,
    required this.bookingPrice,
    required this.maximumNoOfGuest,
  });

  final String reservationId;
  final String reservationName;
  final String reservationAddress;
  final num bookingPrice;
  final int maximumNoOfGuest;

  @override
  ConsumerState<BookReservationScreen> createState() =>
      _BookReservationScreenState();
}

class _BookReservationScreenState extends ConsumerState<BookReservationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final email = TextEditingController();
  final firstNameTec = TextEditingController();
  final lastNameTec = TextEditingController();
  final phoneNo = TextEditingController();
  final numberOfGuest = TextEditingController();
  final comment = TextEditingController();
  final reservationStartDate = TextEditingController();
  final reservationEndDate = TextEditingController();

  final format = DateFormat("dd MMM, yyyy hh:mm a");

  bool isLoading = false;
  bool isDateLoading = false;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Set<DateTime> bookedDates = {};

  String selectedCountryCode = "+234";

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _loadUserDetails();
      await _fetchReservationDates();
    });
  }

  @override
  void dispose() {
    email.dispose();
    firstNameTec.dispose();
    lastNameTec.dispose();
    phoneNo.dispose();
    numberOfGuest.dispose();
    comment.dispose();
    reservationStartDate.dispose();
    reservationEndDate.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final accountNotifier = ref.read(accountProvider.notifier);
    await accountNotifier.getAccount();
    final accountAsync = ref.watch(accountProvider);
    final account = accountAsync.value;

    final user = account?.userData;
    if (user == null) return;

    email.text = user.email ?? "";
    firstNameTec.text = user.firstName ?? "";
    lastNameTec.text = user.lastName ?? "";
    phoneNo.text = user.phoneNo ?? "";

    ref
        .read(customerBookControllerProvider.notifier)
        .onEmailChanged(email.text);

    ref
        .read(customerBookControllerProvider.notifier)
        .onFirstNameChanged(firstNameTec.text);

    ref
        .read(customerBookControllerProvider.notifier)
        .onLastNameChanged(lastNameTec.text);

    ref
        .read(customerBookControllerProvider.notifier)
        .onPhoneChanged(phoneNo.text);
  }

  Future<void> _fetchReservationDates() async {
    setState(() {
      isDateLoading = true;
    });

    try {
      final bookings = await BookingRemoteService().getAllReservationDateData(
        reservationId: widget.reservationId,
      );

      final blocked = <DateTime>{};

      for (final item in bookings) {
        final start = item.reservationStartDate;
        final end = item.reservationEndDate;

        if (start == null || end == null) continue;

        var current = DateTime.utc(start.year, start.month, start.day);
        final last = DateTime.utc(end.year, end.month, end.day);

        while (!current.isAfter(last)) {
          blocked.add(current);
          current = current.add(const Duration(days: 1));
        }
      }

      if (!mounted) return;

      setState(() {
        bookedDates = blocked;
      });
    } catch (_) {
      if (!mounted) return;

      showCustomSnackbar(
        context,
        title: "Booking Dates",
        content: "Unable to load booked dates",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          isDateLoading = false;
        });
      }
    }
  }

  void _onDateSelected(DateTime start, DateTime end) {
    selectedStartDate = start;
    selectedEndDate = end;

    reservationStartDate.text = format.format(start);
    reservationEndDate.text = format.format(end);

    final notifier = ref.read(customerBookControllerProvider.notifier);

    notifier.onReservationStartDateChanged(reservationStartDate.text);
    notifier.onReservationEndDateChanged(reservationEndDate.text);
  }

  int _calculateNoOfDays() {
    if (selectedStartDate == null || selectedEndDate == null) return 0;

    final difference = selectedEndDate!.difference(selectedStartDate!);
    final days = difference.inDays;

    return days == 0 ? 1 : days;
  }

  bool _isFormReady(CustomerBookState state) {
    return firstNameTec.text.trim().isNotEmpty &&
        lastNameTec.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        phoneNo.text.trim().isNotEmpty &&
        numberOfGuest.text.trim().isNotEmpty &&
        reservationStartDate.text.trim().isNotEmpty &&
        reservationEndDate.text.trim().isNotEmpty;
  }

  Future<void> _continueBooking() async {
    final connectivityStatusProvider = ref.read(connectivityStatusProviders);

    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    if (connectivityStatusProvider.value != ConnectivityStatus.isConnected) {
      showCustomSnackbar(
        context,
        title: "Network Connection",
        content: "No Internet Connection",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final guestCount = int.tryParse(numberOfGuest.text.trim()) ?? 0;

    if (guestCount > widget.maximumNoOfGuest) {
      showCustomSnackbar(
        context,
        title: "Maximum Guest",
        content:
            "The no of Guest you selected is more than the maximum number ${widget.maximumNoOfGuest}",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (selectedStartDate == null || selectedEndDate == null) {
      showCustomSnackbar(
        context,
        title: "Booking Date",
        content: "Please select your booking start and end date",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final noOfDays = _calculateNoOfDays();

    navigateToRoute(
      context,
      ConfirmAccomodationBookings(
        amount: widget.bookingPrice.toDouble(),
        reservationId: widget.reservationId,
        reservationName: widget.reservationName,
        reservationAddress: widget.reservationAddress,
        customerName: "${firstNameTec.text.trim()} ${lastNameTec.text.trim()}",
        customerEmail: email.text.trim(),
        customerPhoneNumber: phoneNo.text.trim(),
        numberOfGuests: guestCount,
        comment: comment.text.trim().isEmpty ? "" : comment.text.trim(),
        reservationStartDate: reservationStartDate.text.trim(),
        reservationEndDate: reservationEndDate.text.trim(),
        noOfDays: noOfDays,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(customerBookControllerProvider);
    final notifier = ref.read(customerBookControllerProvider.notifier);

    final data = asyncState.value ?? const CustomerBookState();

    final isButtonReady = _isFormReady(data);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: AppText(
          text: "Book Accommodation",
          textAlign: TextAlign.start,

          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complete the form below and book the accomodation",
                    style: TextStyle(
                      fontSize: 15.textSize,
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Mulish",
                    ),
                  ),

                  addVerticalSpacing(5),

                  GlobalTextField(
                    fieldName: 'First Name',
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    textController: firstNameTec,
                    onChanged: (value) {
                      notifier.onFirstNameChanged(value ?? "");
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'Last Name',
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    textController: lastNameTec,
                    onChanged: (value) {
                      notifier.onLastNameChanged(value ?? "");
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'Email',
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    textController: email,
                    onChanged: (value) {
                      notifier.onEmailChanged(value ?? "");
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(2),

                  GlobalPhoneTextField(
                    fieldName: 'Phone Number',
                    textController: phoneNo,
                    onChanged: (value) {
                      final phone = value?.completeNumber ?? "";
                      phoneNo.text = phone;
                      notifier.onPhoneChanged(phone);
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'Number Of Guest',
                    keyBoardType: TextInputType.number,
                    obscureText: false,
                    textController: numberOfGuest,
                    onChanged: (value) {
                      notifier.onNoOfGuestChanged(value ?? "");
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'Start Date',
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    readOnly: true,
                    textController: reservationStartDate,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => BookingDateSelect(
                              bookedDates: bookedDates,
                              onDateSelected: (start, end) {
                                _onDateSelected(start, end);
                                setState(() {});
                              },
                            ),
                      );
                    },
                    onChanged: (_) {},
                  ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'End Date',
                    keyBoardType: TextInputType.text,
                    obscureText: false,
                    readOnly: true,
                    textController: reservationEndDate,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => BookingDateSelect(
                              bookedDates: bookedDates,
                              onDateSelected: (start, end) {
                                _onDateSelected(start, end);
                                setState(() {});
                              },
                            ),
                      );
                    },
                    onChanged: (_) {},
                  ),

                  if (isDateLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: AppText(
                        text: "Loading unavailable booking dates...",

                        color: AppColors.grey2,
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                  addVerticalSpacing(2),

                  GlobalTextField(
                    fieldName: 'Comments',
                    keyBoardType: TextInputType.multiline,
                    isOptional: true,
                    removeSpace: false,
                    obscureText: false,
                    isNotePad: true,
                    maxLength: 200,
                    textController: comment,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),

                  addVerticalSpacing(3),

                  AppButton(
                    text: "Book Now",
                    onPressed: isButtonReady ? _continueBooking : () {},
                    widthPercent: 100,
                    heightPercent: 6,
                    btnColor:
                        isButtonReady ? AppColors.primary : AppColors.grey,
                    isLoading: isLoading,
                  ),

                  addVerticalSpacing(5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
