import 'package:well_trust_mobile_app/features/meds/data/model/package_orders_model.dart';

class PackageOrderState {
  final List<PackageOrderResponseModel> listPackageOrder;
  final PackageOrderResponseModel? singleData;

  final int page;
  final int pageSize;
  final bool hasLoadedInitially;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasNext;
  final int totalCount;
  final String? error;
  final String? successMessage;
  final int visitCount;

  // Filters
  final String anyItem;
  final String stateFilter;
  final String localityFilter;
  final String filterTypes;

  // Create Package Order - Sender
  final String companyId;
  final String companyName;
  final String senderName;
  final String senderEmail;
  final String originAddress;
  final String originPhoneNo;
  final String originPostcodes;
  final String senderState;
  final String senderCity;
  final String senderCountry;
  final double originLatitude;
  final double originLongitude;

  // Create Package Order - Receiver
  final String receiverName;
  final String receiverEmail;
  final String receiverAddress;
  final String receiverPhoneNo;
  final String receiverPostcodes;
  final String receiverState;
  final String receiverCity;
  final String receiverCountry;
  final double receiverLatitude;
  final double receiverLongitude;

  // Package Info
  final String packageName;
  final String itemCost;
  final String itemQuantity;
  final String itemWeight;
  final String itemModelNumber;
  final String itemDescription;
  final String itemType;
  final String packageType;
  final String selectedVehicle;
  final String selectedInterStateVehicle;
  final List<String> imageUrls;

  final bool isLoading;

  const PackageOrderState({
    this.listPackageOrder = const [],
    this.singleData,
    this.page = 1,
    this.pageSize = 20,
    this.hasLoadedInitially = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
    this.successMessage,
    this.visitCount = 0,

    // Filters
    this.anyItem = "",
    this.stateFilter = "",
    this.localityFilter = "",
    this.filterTypes = "",

    // Sender
    this.companyId = "",
    this.companyName = "",
    this.senderName = "",
    this.senderEmail = "",
    this.originAddress = "",
    this.originPhoneNo = "",
    this.originPostcodes = "",
    this.senderState = "",
    this.senderCity = "",
    this.senderCountry = "",
    this.originLatitude = 0.0,
    this.originLongitude = 0.0,

    // Receiver
    this.receiverName = "",
    this.receiverEmail = "",
    this.receiverAddress = "",
    this.receiverPhoneNo = "",
    this.receiverPostcodes = "",
    this.receiverState = "",
    this.receiverCity = "",
    this.receiverCountry = "",
    this.receiverLatitude = 0.0,
    this.receiverLongitude = 0.0,

    // Package Info
    this.packageName = "",
    this.itemCost = "",
    this.itemQuantity = "",
    this.itemWeight = "",
    this.itemModelNumber = "",
    this.itemDescription = "",
    this.itemType = "",
    this.packageType = "",
    this.selectedVehicle = "",
    this.selectedInterStateVehicle = "",
    this.imageUrls = const [],

    this.isLoading = false,
  });

  PackageOrderState copyWith({
    List<PackageOrderResponseModel>? listPackageOrder,
    PackageOrderResponseModel? singleData,
    int? page,
    int? pageSize,
    bool? hasLoadedInitially,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasNext,
    int? totalCount,
    String? error,
    String? successMessage,
    int? visitCount,

    // Filters
    String? anyItem,
    String? stateFilter,
    String? localityFilter,
    String? filterTypes,

    // Sender
    String? companyId,
    String? companyName,
    String? senderName,
    String? senderEmail,
    String? originAddress,
    String? originPhoneNo,
    String? originPostcodes,
    String? senderState,
    String? senderCity,
    String? senderCountry,
    double? originLatitude,
    double? originLongitude,

    // Receiver
    String? receiverName,
    String? receiverEmail,
    String? receiverAddress,
    String? receiverPhoneNo,
    String? receiverPostcodes,
    String? receiverState,
    String? receiverCity,
    String? receiverCountry,
    double? receiverLatitude,
    double? receiverLongitude,

    // Package Info
    String? packageName,
    String? itemCost,
    String? itemQuantity,
    String? itemWeight,
    String? itemModelNumber,
    String? itemDescription,
    String? itemType,
    String? packageType,
    String? selectedVehicle,
    String? selectedInterStateVehicle,
    List<String>? imageUrls,

    bool? isLoading,
  }) {
    return PackageOrderState(
      listPackageOrder: listPackageOrder ?? this.listPackageOrder,
      singleData: singleData ?? this.singleData,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasLoadedInitially: hasLoadedInitially ?? this.hasLoadedInitially,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      visitCount: visitCount ?? this.visitCount,

      // Filters
      anyItem: anyItem ?? this.anyItem,
      stateFilter: stateFilter ?? this.stateFilter,
      localityFilter: localityFilter ?? this.localityFilter,
      filterTypes: filterTypes ?? this.filterTypes,

      // Sender
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      originAddress: originAddress ?? this.originAddress,
      originPhoneNo: originPhoneNo ?? this.originPhoneNo,
      originPostcodes: originPostcodes ?? this.originPostcodes,
      senderState: senderState ?? this.senderState,
      senderCity: senderCity ?? this.senderCity,
      senderCountry: senderCountry ?? this.senderCountry,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,

      // Receiver
      receiverName: receiverName ?? this.receiverName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      receiverPhoneNo: receiverPhoneNo ?? this.receiverPhoneNo,
      receiverPostcodes: receiverPostcodes ?? this.receiverPostcodes,
      receiverState: receiverState ?? this.receiverState,
      receiverCity: receiverCity ?? this.receiverCity,
      receiverCountry: receiverCountry ?? this.receiverCountry,
      receiverLatitude: receiverLatitude ?? this.receiverLatitude,
      receiverLongitude: receiverLongitude ?? this.receiverLongitude,

      // Package Info
      packageName: packageName ?? this.packageName,
      itemCost: itemCost ?? this.itemCost,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      itemWeight: itemWeight ?? this.itemWeight,
      itemModelNumber: itemModelNumber ?? this.itemModelNumber,
      itemDescription: itemDescription ?? this.itemDescription,
      itemType: itemType ?? this.itemType,
      packageType: packageType ?? this.packageType,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedInterStateVehicle:
          selectedInterStateVehicle ?? this.selectedInterStateVehicle,
      imageUrls: imageUrls ?? this.imageUrls,

      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get canCreatePackageOrder {
    return senderName.trim().isNotEmpty &&
        senderEmail.trim().isNotEmpty &&
        originAddress.trim().isNotEmpty &&
        originPhoneNo.trim().isNotEmpty &&
        originPostcodes.trim().isNotEmpty &&
        senderState.trim().isNotEmpty &&
        senderCity.trim().isNotEmpty &&
        senderCountry.trim().isNotEmpty &&
        originLatitude != 0.0 &&
        originLongitude != 0.0 &&
        receiverName.trim().isNotEmpty &&
        receiverEmail.trim().isNotEmpty &&
        receiverAddress.trim().isNotEmpty &&
        receiverPhoneNo.trim().isNotEmpty &&
        receiverPostcodes.trim().isNotEmpty &&
        receiverState.trim().isNotEmpty &&
        receiverCity.trim().isNotEmpty &&
        receiverCountry.trim().isNotEmpty &&
        receiverLatitude != 0.0 &&
        receiverLongitude != 0.0 &&
        packageName.trim().isNotEmpty &&
        itemCost.trim().isNotEmpty &&
        itemQuantity.trim().isNotEmpty &&
        itemWeight.trim().isNotEmpty &&
        itemDescription.trim().isNotEmpty &&
        packageType.trim().isNotEmpty &&
        selectedVehicle.trim().isNotEmpty;
  }

  bool get hasSenderDetails {
    return senderName.trim().isNotEmpty &&
        senderEmail.trim().isNotEmpty &&
        originAddress.trim().isNotEmpty &&
        originPhoneNo.trim().isNotEmpty &&
        senderState.trim().isNotEmpty &&
        senderCity.trim().isNotEmpty &&
        senderCountry.trim().isNotEmpty;
  }

  bool get hasReceiverDetails {
    return receiverName.trim().isNotEmpty &&
        receiverEmail.trim().isNotEmpty &&
        receiverAddress.trim().isNotEmpty &&
        receiverPhoneNo.trim().isNotEmpty &&
        receiverState.trim().isNotEmpty &&
        receiverCity.trim().isNotEmpty &&
        receiverCountry.trim().isNotEmpty;
  }

  bool get hasPackageDetails {
    return packageName.trim().isNotEmpty &&
        itemCost.trim().isNotEmpty &&
        itemQuantity.trim().isNotEmpty &&
        itemWeight.trim().isNotEmpty &&
        itemDescription.trim().isNotEmpty &&
        packageType.trim().isNotEmpty;
  }
}
