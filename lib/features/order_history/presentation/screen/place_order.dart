import 'dart:io';

import 'package:ginilog_customer_app/core/helpers/endpoints.dart';
import 'package:ginilog_customer_app/core/helpers/globals.dart';
import 'package:ginilog_customer_app/core/services/upload_service.dart';
import 'package:ginilog_customer_app/core/utils/app_buttons.dart';
import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/helper_functions.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/features/account/states/account_provider.dart';
import 'package:ginilog_customer_app/features/home/data/model/company_response_model.dart';
import 'package:ginilog_customer_app/features/home/presentation/screen/company_select_page.dart';
import 'package:ginilog_customer_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:ginilog_customer_app/features/order_history/data/dto/create_order.dart';
import 'package:ginilog_customer_app/features/order_history/data/model/package_orders_model.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/provider/package_provider.dart';
import 'package:ginilog_customer_app/features/order_history/presentation/state/state_model/package_order_state.dart';
import 'package:ginilog_customer_app/features/order_history/view/package_information.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';
import 'package:ginilog_customer_app/shared/widgets/custom_snackbar.dart';
import 'package:ginilog_customer_app/shared/widgets/input.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class PlaceOrderScreen extends ConsumerStatefulWidget {
  const PlaceOrderScreen({
    super.key,
    required this.shippingType,
    required this.userPhone,
  });

  final String shippingType;
  final String userPhone;

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> {
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  final PageController pageController = PageController();

  final senderName = TextEditingController();
  final senderEmail = TextEditingController();
  final originAddress = TextEditingController();
  final originPhoneNoTec = TextEditingController();
  final originPostcodes = TextEditingController();

  final receiverName = TextEditingController();
  final receiverEmail = TextEditingController();
  final destinationAddress = TextEditingController();
  final destinationPhoneNoTec = TextEditingController();
  final destinationPostcodes = TextEditingController();

  final packageName = TextEditingController();
  final itemCost = TextEditingController();
  final itemQuantity = TextEditingController();
  final itemWeight = TextEditingController();
  final itemModelNumber = TextEditingController();
  final itemDescription = TextEditingController();
  final itemType = TextEditingController();
  final company = TextEditingController();

  final _searchController = TextEditingController();

  final List<XFile> imageFiles = [];
  final int maxImages = 4;

  bool isLoading = false;
  int currentPage = 0;

  final List<String> allItems = [
    "Electronics",
    "Documents",
    "Clothing",
    "Foodstuff",
    "Others",
  ];

  List<String> filteredItems = [];

  final List<Map<String, dynamic>> vehicles = [
    {"name": "Motorcycle", "icon": Icons.motorcycle},
    {"name": "Van", "icon": Icons.directions_bus},
    {"name": "Truck", "icon": Icons.local_shipping},
  ];

  final List<Map<String, dynamic>> vehiclesInterState = [
    {"name": "Van", "icon": Icons.directions_bus},
    {"name": "Truck", "icon": Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      final user = ref.read(accountProvider).value?.userData;

      final notifier = ref.read(packageOrderControllerProvider.notifier);

      if (user != null) {
        final fullName = "${user.firstName ?? ""} ${user.lastName ?? ""}";

        senderName.text = fullName.trim();
        senderEmail.text = user.email ?? "";
        originPhoneNoTec.text = user.phoneNo ?? "";

        notifier.onSenderNameChanged(fullName.trim());
        notifier.onSenderEmailChanged(user.email ?? "");
        notifier.onOriginPhoneNoChanged(user.phoneNo ?? "");
      }

      if (widget.shippingType.toLowerCase() == "charter") {
        itemType.text = "Charter";
        notifier.onItemTypeChanged("Charter");
        notifier.onPackageTypeChanged("Charter");
      }

      notifier.onSelectedVehicleChanged("Motorcycle");
      notifier.onSelectedInterStateVehicleChanged("Van");
    });
  }

  @override
  void dispose() {
    pageController.dispose();

    senderName.dispose();
    senderEmail.dispose();
    originAddress.dispose();
    originPhoneNoTec.dispose();
    originPostcodes.dispose();

    receiverName.dispose();
    receiverEmail.dispose();
    destinationAddress.dispose();
    destinationPhoneNoTec.dispose();
    destinationPostcodes.dispose();

    packageName.dispose();
    itemCost.dispose();
    itemQuantity.dispose();
    itemWeight.dispose();
    itemModelNumber.dispose();
    itemDescription.dispose();
    itemType.dispose();
    company.dispose();
    _searchController.dispose();

    super.dispose();
  }

  Future<void> origin(Prediction placeId) async {
    if (placeId.placeId == null || placeId.placeId!.isEmpty) return;

    final notifier = ref.read(packageOrderControllerProvider.notifier);

    final result = await ref
        .read(logisticsControllerProvider.notifier)
        .getPlaceDetails(placeId.placeId!);

    if (!result.isSuccess) return;

    final Map<String, dynamic>? placeDetails = result.data;
    if (placeDetails == null) return;

    String country = "";
    String state = "";
    String city = "";
    String postcode = "";

    final components = placeDetails['address_components'] ?? [];

    for (final component in components) {
      final List types = component['types'] ?? [];

      if (types.contains('country')) {
        country = component['long_name'].toString();
      }

      if (types.contains('administrative_area_level_1')) {
        state = component['long_name'].toString();
      }

      if (types.contains('administrative_area_level_2')) {
        city = component['long_name'].toString();
      }

      if (types.contains('postal_code')) {
        postcode = component['long_name'].toString();
      }
    }

    originAddress.text = placeId.description ?? "";
    originPostcodes.text = postcode;

    notifier.onOriginAddressChanged(placeId.description ?? "");
    notifier.onSenderCountryChanged(country);
    notifier.onSenderStateChanged(state);
    notifier.onSenderCityChanged(city);
    notifier.onOriginPostCodeChanged(postcode);
    notifier.onOriginLatitudeChanged(
      double.tryParse(placeId.lat.toString()) ?? 0,
    );
    notifier.onOriginLongitudeChanged(
      double.tryParse(placeId.lng.toString()) ?? 0,
    );

    setState(() {});
  }

  Future<void> destination(Prediction placeId) async {
    if (placeId.placeId == null || placeId.placeId!.isEmpty) return;

    final notifier = ref.read(packageOrderControllerProvider.notifier);

    final result = await ref
        .read(logisticsControllerProvider.notifier)
        .getPlaceDetails(placeId.placeId!);

    if (!result.isSuccess) return;

    final Map<String, dynamic>? placeDetails = result.data;
    if (placeDetails == null) return;

    String country = "";
    String state = "";
    String city = "";
    String postcode = "";

    final components = placeDetails['address_components'] ?? [];

    for (final component in components) {
      final List types = component['types'] ?? [];

      if (types.contains('country')) {
        country = component['long_name'].toString();
      }

      if (types.contains('administrative_area_level_1')) {
        state = component['long_name'].toString();
      }

      if (types.contains('administrative_area_level_2')) {
        city = component['long_name'].toString();
      }

      if (types.contains('postal_code')) {
        postcode = component['long_name'].toString();
      }
    }

    destinationAddress.text = placeId.description ?? "";
    destinationPostcodes.text = postcode;

    notifier.onReceiverAddressChanged(placeId.description ?? "");
    notifier.onReceiverCountryChanged(country);
    notifier.onReceiverStateChanged(state);
    notifier.onReceiverCityChanged(city);
    notifier.onReceiverPostCodeChanged(postcode);
    notifier.onReceiverLatitudeChanged(
      double.tryParse(placeId.lat.toString()) ?? 0,
    );
    notifier.onReceiverLongitudeChanged(
      double.tryParse(placeId.lng.toString()) ?? 0,
    );

    setState(() {});
  }

  void showBottomSheet() {
    _searchController.clear();
    filteredItems = List.from(allItems);

    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        modalSetState(() {
                          filteredItems =
                              allItems
                                  .where(
                                    (item) => item.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          filteredItems.isEmpty
                              ? const Center(child: Text("No results found"))
                              : ListView.builder(
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      filteredItems[index],
                                      style: TextStyle(
                                        fontSize: 18.textSize,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                    onTap: () {
                                      itemType.text = filteredItems[index];

                                      ref
                                          .read(
                                            packageOrderControllerProvider
                                                .notifier,
                                          )
                                          .onItemTypeChanged(
                                            filteredItems[index],
                                          );

                                      ref
                                          .read(
                                            packageOrderControllerProvider
                                                .notifier,
                                          )
                                          .onPackageTypeChanged(
                                            filteredItems[index],
                                          );

                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickImages() async {
    if (imageFiles.length >= maxImages) {
      showCustomSnackbar(
        context,
        title: "Image Select",
        content: "You can only select a maximum of $maxImages images",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      limit: maxImages - imageFiles.length,
    );

    if (pickedFiles.isEmpty) return;

    for (final image in pickedFiles) {
      setState(() {
        imageFiles.add(image);
      });

      final imageUrl = await ApiService.upload(image.path);

      ref.read(packageOrderControllerProvider.notifier).addImageUrl(imageUrl);
    }
  }

  void removeImage(int index) {
    final state = ref.read(packageOrderControllerProvider).value;
    final imageUrls = state?.imageUrls ?? [];

    if (index < imageFiles.length) {
      setState(() {
        imageFiles.removeAt(index);
      });
    }

    if (index < imageUrls.length) {
      ref
          .read(packageOrderControllerProvider.notifier)
          .removeImageUrl(imageUrls[index]);
    }
  }

  void clearAllImage() {
    setState(() {
      imageFiles.clear();
    });

    ref.read(packageOrderControllerProvider.notifier).clearImages();
  }

  Future<void> navigateToSelectionPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CompanySelectPage(isSelectionType: widget.shippingType),
      ),
    );

    if (result != null && result is LogisticResponseModel) {
      company.text = result.companyName ?? "";

      final notifier = ref.read(packageOrderControllerProvider.notifier);

      notifier.onCompanyIdChanged(result.id ?? "");
      notifier.onCompanyNameChanged(result.companyName ?? "");
    }
  }

  Future<void> submitOrder() async {
    final data =
        ref.read(packageOrderControllerProvider).value ??
        const PackageOrderState();

    FocusScope.of(context).unfocus();

    if (!formKey2.currentState!.validate()) return;

    if (widget.shippingType.toLowerCase() == "same state" &&
        data.senderState.trim().toLowerCase() !=
            data.receiverState.trim().toLowerCase()) {
      showCustomSnackbar(
        context,
        title: "Same State Order",
        content: "Choose the same State and place the order",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (data.companyId.trim().isEmpty) {
      showCustomSnackbar(
        context,
        title: "Select Hub",
        content: "Please select a logistics hub",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    if (data.imageUrls.isEmpty) {
      showCustomSnackbar(
        context,
        title: "Package Images",
        content: "Please upload at least one package image",
        type: SnackbarType.error,
        isTopPosition: false,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String riderType = "";

    if (widget.shippingType.toLowerCase() == "same state") {
      riderType = data.selectedVehicle;
    } else if (widget.shippingType.toLowerCase() == "inter state") {
      riderType = data.selectedInterStateVehicle;
    } else if (widget.shippingType.toLowerCase() == "charter") {
      riderType = "Pickup";
    } else {
      riderType = "Plane Flight";
    }

    final request = CreatePackageOrderRequest(
      companyId: data.companyId,
      itemName: data.packageName,
      itemDescription: data.itemDescription,
      itemModelNumber: data.itemModelNumber,
      itemCost: num.tryParse(data.itemCost) ?? 0,
      itemWeight: num.tryParse(data.itemWeight) ?? 0,
      itemQuantity: int.tryParse(data.itemQuantity) ?? 0,
      packageType:
          widget.shippingType.toLowerCase() == "charter"
              ? "Charter"
              : data.itemType,
      senderName: data.senderName,
      senderPhoneNo: data.originPhoneNo,
      senderEmail: data.senderEmail,
      senderAddress: data.originAddress,
      senderState: data.senderState,
      senderCountry: data.senderCountry,
      senderLocality: data.senderCity,
      senderPostalCode: data.originPostcodes,
      senderLatitude: data.originLatitude,
      senderLongitude: data.originLongitude,
      recieverName: data.receiverName,
      recieverPhoneNo: data.receiverPhoneNo,
      recieverEmail: data.receiverEmail,
      recieverAddress: data.receiverAddress,
      recieverState: data.receiverState,
      recieverCountry: data.receiverCountry,
      recieverLocality: data.receiverCity,
      recieverPostalCode: data.receiverPostcodes,
      recieverLatitude: data.receiverLatitude,
      recieverLongitude: data.receiverLongitude,
      packageImageLists: data.imageUrls,
      riderType: riderType,
      shippingType: widget.shippingType,
      staffId: globals.userId,
      staffName: globals.userName,
      purchaseChannel: "Mobile App ${Platform.isIOS ? 'iOS' : 'Android'}",
      userType: "Registered",
    );

    final response = await ref
        .read(packageOrderControllerProvider.notifier)
        .createOrderWithAddress(request: request);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.isSuccess == true) {
      showCustomSnackbar(
        context,
        title: "Package Order",
        content: response.message ?? "Order Created Successfully",
        type: SnackbarType.success,
        isTopPosition: false,
      );

      final order = PackageOrderResponseModel.fromJson(response.data!);

      navigateToRoute(
        context,
        PackageInformationPage(order: order, userPhone: widget.userPhone),
      );
    } else {
      showCustomSnackbar(
        context,
        title: "Package Order",
        content: response.message ?? "Error in Creating The Order",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageOrderControllerProvider);
    final data = packageAsync.value ?? const PackageOrderState();

    final pageOneReady =
        data.hasSenderDetails &&
        data.hasReceiverDetails &&
        data.packageName.trim().isNotEmpty &&
        data.itemQuantity.trim().isNotEmpty &&
        data.itemCost.trim().isNotEmpty &&
        data.itemWeight.trim().isNotEmpty &&
        data.itemModelNumber.trim().isNotEmpty;

    final pageTwoReady =
        data.itemDescription.trim().isNotEmpty &&
        (widget.shippingType.toLowerCase() == "charter" ||
            data.itemType.trim().isNotEmpty) &&
        data.companyId.trim().isNotEmpty &&
        data.imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "Place Your Order",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 1.widthAdjusted,
                vertical: 1.heightAdjusted,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 0.5.heightAdjusted,
                      decoration: BoxDecoration(
                        color: pageOneReady ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 0.5.heightAdjusted,
                      decoration: BoxDecoration(
                        color: pageTwoReady ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                children: [
                  _buildPageOne(data, pageOneReady),
                  _buildPageTwo(data, pageTwoReady),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageOne(PackageOrderState data, bool pageOneReady) {
    final notifier = ref.read(packageOrderControllerProvider.notifier);

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                "Origin Details",
                style: TextStyle(
                  fontSize: 18.textSize,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),

              GooglePlacesAutoCompleteTextFormField(
                config: GoogleApiConfig(apiKey: Endpoints.googleApiKey),
                textEditingController: originAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter Origin your address',
                  labelText: 'Origin',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter origin address';
                  }
                  return null;
                },
                onChanged: (value) {
                  notifier.onOriginAddressChanged(value);
                },
                onPredictionWithCoordinatesReceived: origin,
                onSuggestionClicked: (prediction) {
                  originAddress.text = prediction.description ?? "";
                  notifier.onOriginAddressChanged(prediction.description ?? "");
                },
                minInputLength: 3,
              ),

              GlobalTextField(
                fieldName: 'Sender Name',
                keyBoardType: TextInputType.name,
                removeSpace: false,
                obscureText: false,
                textController: senderName,
                onChanged: (value) {
                  notifier.onSenderNameChanged(value ?? "");
                },
              ),

              GlobalTextField(
                fieldName: 'Sender Email',
                keyBoardType: TextInputType.emailAddress,
                obscureText: false,
                textController: senderEmail,
                onChanged: (value) {
                  notifier.onSenderEmailChanged(value ?? "");
                },
              ),

              GlobalPhoneTextField(
                fieldName: 'Phone Number',
                textController: originPhoneNoTec,
                onChanged: (value) {
                  notifier.onOriginPhoneNoChanged(value?.completeNumber ?? "");
                },
              ),

              Text(
                "Destination Details",
                style: TextStyle(
                  fontSize: 18.textSize,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),

              GooglePlacesAutoCompleteTextFormField(
                config: GoogleApiConfig(apiKey: Endpoints.googleApiKey),
                textEditingController: destinationAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter Destination your address',
                  labelText: 'Receiver Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter receiver address';
                  }
                  return null;
                },
                onChanged: (value) {
                  notifier.onReceiverAddressChanged(value);
                },
                onPredictionWithCoordinatesReceived: destination,
                onSuggestionClicked: (prediction) {
                  destinationAddress.text = prediction.description ?? "";
                  notifier.onReceiverAddressChanged(
                    prediction.description ?? "",
                  );
                },
                minInputLength: 3,
              ),

              GlobalTextField(
                fieldName: 'Receiver Name',
                keyBoardType: TextInputType.name,
                removeSpace: false,
                obscureText: false,
                textController: receiverName,
                onChanged: (value) {
                  notifier.onReceiverNameChanged(value ?? "");
                },
              ),

              GlobalTextField(
                fieldName: 'Receiver Email',
                keyBoardType: TextInputType.emailAddress,
                obscureText: false,
                textController: receiverEmail,
                onChanged: (value) {
                  notifier.onReceiverEmailChanged(value ?? "");
                },
              ),

              GlobalPhoneTextField(
                fieldName: 'Phone Number',
                textController: destinationPhoneNoTec,
                onChanged: (value) {
                  notifier.onReceiverPhoneNoChanged(
                    value?.completeNumber ?? "",
                  );
                },
              ),

              Text(
                "Package Details",
                style: TextStyle(
                  fontSize: 18.textSize,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),

              GlobalTextField(
                fieldName: 'Package Name',
                keyBoardType: TextInputType.name,
                obscureText: false,
                removeSpace: false,
                textController: packageName,
                onChanged: (value) {
                  notifier.onPackageNameChanged(value ?? "");
                },
              ),

              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: GlobalTextField(
                      fieldName: 'Package Model Number',
                      keyBoardType: TextInputType.name,
                      obscureText: false,
                      textController: itemModelNumber,
                      onChanged: (value) {
                        notifier.onItemModelNumberChanged(value ?? "");
                      },
                    ),
                  ),
                  Expanded(
                    child: GlobalTextField(
                      fieldName: 'Package Weight',
                      keyBoardType: TextInputType.number,
                      obscureText: false,
                      textController: itemWeight,
                      onChanged: (value) {
                        notifier.onItemWeightChanged(value ?? "");
                      },
                    ),
                  ),
                ],
              ),

              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: GlobalTextField(
                      fieldName: 'Package Cost',
                      keyBoardType: TextInputType.number,
                      obscureText: false,
                      textController: itemCost,
                      onChanged: (value) {
                        notifier.onItemCostChanged(value ?? "");
                      },
                    ),
                  ),
                  Expanded(
                    child: GlobalTextField(
                      fieldName: 'Package Quantity',
                      keyBoardType: TextInputType.number,
                      obscureText: false,
                      textController: itemQuantity,
                      onChanged: (value) {
                        notifier.onItemQuantityChanged(value ?? "");
                      },
                    ),
                  ),
                ],
              ),

              addVerticalSpacing(5),

              AppButton(
                text: "Next",
                onPressed:
                    pageOneReady
                        ? () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        : () {},
                widthPercent: 100,
                heightPercent: 6,
                btnColor: pageOneReady ? AppColors.primary : AppColors.grey,
                isLoading: false,
              ),

              addVerticalSpacing(5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTwo(PackageOrderState data, bool pageTwoReady) {
    final notifier = ref.read(packageOrderControllerProvider.notifier);

    return SingleChildScrollView(
      child: Form(
        key: formKey2,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                "More Details",
                style: TextStyle(
                  fontSize: 18.textSize,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),

              if (widget.shippingType.toLowerCase() != "charter")
                GlobalTextField(
                  fieldName: 'Package Type',
                  keyBoardType: TextInputType.name,
                  obscureText: false,
                  readOnly: true,
                  textController: itemType,
                  isEyeVisible: false,
                  suffix: const Icon(Icons.arrow_drop_down),
                  onChanged: (value) {},
                  onTap: showBottomSheet,
                ),

              GlobalTextField(
                fieldName:
                    widget.shippingType.toLowerCase() == "charter"
                        ? "List other items here"
                        : 'Package Description',
                keyBoardType: TextInputType.multiline,
                removeSpace: false,
                obscureText: false,
                isNotePad: true,
                maxLength: 200,
                textController: itemDescription,
                onChanged: (value) {
                  notifier.onItemDescriptionChanged(value ?? "");
                },
              ),

              DottedBorder(
                options: RectDottedBorderOptions(
                  padding: const EdgeInsets.all(6),
                ),

                child: SizedBox(
                  height: 150,
                  child:
                      imageFiles.isNotEmpty
                          ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                imageFiles.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(imageFiles[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => removeImage(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          : const Center(
                            child: Text(
                              'Kindly upload the pictures of the Items',
                            ),
                          ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: pickImages,
                    child: const Text("Add Images"),
                  ),
                  ElevatedButton(
                    onPressed: imageFiles.isNotEmpty ? clearAllImage : null,
                    child: const Text("Remove All"),
                  ),
                ],
              ),

              GlobalTextField(
                fieldName: 'Select Hub Here',
                keyBoardType: TextInputType.name,
                obscureText: false,
                readOnly: true,
                textController: company,
                isEyeVisible: false,
                suffix: const Icon(Icons.arrow_drop_down),
                onChanged: (value) {},
                onTap: navigateToSelectionPage,
              ),

              if (widget.shippingType.toLowerCase() == "inter state")
                _buildVehicleSelector(
                  vehiclesInterState,
                  data.selectedInterStateVehicle,
                  notifier.onSelectedInterStateVehicleChanged,
                )
              else if (widget.shippingType.toLowerCase() == "same state")
                _buildVehicleSelector(
                  vehicles,
                  data.selectedVehicle,
                  notifier.onSelectedVehicleChanged,
                ),

              addVerticalSpacing(5),

              AppButton(
                text: "Submit",
                onPressed: pageTwoReady ? submitOrder : () {},
                widthPercent: 100,
                heightPercent: 6,
                btnColor: pageTwoReady ? AppColors.primary : AppColors.grey,
                isLoading: isLoading,
              ),

              addVerticalSpacing(5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(
    List<Map<String, dynamic>> vehicleList,
    String selectedVehicle,
    void Function(String value) onSelected,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            vehicleList.map((vehicle) {
              final isSelected = selectedVehicle == vehicle["name"];

              return GestureDetector(
                onTap: () => onSelected(vehicle["name"]),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vehicle["icon"],
                        size: 15,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        text: "${vehicle["name"]}",
                        textAlign: TextAlign.start,

                        color:
                            isSelected
                                ? AppColors.white
                                : AppColors.black.withAlpha(162),

                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
