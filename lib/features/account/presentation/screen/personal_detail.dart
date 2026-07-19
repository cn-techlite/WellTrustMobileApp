import 'dart:io';

import 'package:well_trust_mobile_app/core/services/upload_service.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class AccountDetailsPage extends ConsumerStatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _phoneNo = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  File? pickedImage;
  String imageFile = "";

  bool _hasFilledFields = false;
  bool _isUpdatingName = false;
  bool _isUploadingImage = false;

  static const String defaultAvatar =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Microsoft_Account.svg/512px-Microsoft_Account.svg.png?20170218203212";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(accountControllerProvider.notifier).getAccount();
    });
  }

  @override
  void dispose() {
    _phoneNo.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadProfileImage(RegisterResponseModel user) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        pickedImage = File(image.path);
        imageFile = image.path;
        _isUploadingImage = true;
      });

      final imageUrl = await ApiService.upload(image.path);

      final response = await ref
          .read(accountControllerProvider.notifier)
          .updateProfile(
            firstName: user.firstName ?? "",
            lastName: user.lastName ?? "",
            imageFile: imageUrl,
            phoneNo: user.phoneNo ?? "",
            availability: true,
          );

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      if (response.isSuccess == true) {
        showCustomSnackbar(
          context,
          title: "Profile Updated",
          content: response.message ?? "Profile picture updated successfully",
          type: SnackbarType.success,
          isTopPosition: false,
        );
      } else {
        showCustomSnackbar(
          context,
          title: "Update Failed",
          content: response.message ?? "Unable to update profile picture",
          type: SnackbarType.error,
          isTopPosition: false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      showCustomSnackbar(
        context,
        title: "Upload Failed",
        content: e.toString(),
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  Future<void> _updateName(RegisterResponseModel user) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isUpdatingName = true;
    });

    final response = await ref
        .read(accountControllerProvider.notifier)
        .updateProfile(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          imageFile: user.profilePicture ?? "",
          phoneNo: user.phoneNo ?? "",
          availability: true,
        );

    if (!mounted) return;

    setState(() {
      _isUpdatingName = false;
    });

    if (response.isSuccess == true) {
      showCustomSnackbar(
        context,
        title: "Profile Updated",
        content: response.message ?? "Profile updated successfully",
        type: SnackbarType.success,
        isTopPosition: false,
      );
    } else {
      showCustomSnackbar(
        context,
        title: "Update Failed",
        content: response.message ?? "Unable to update profile",
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  void _fillFieldsOnce(RegisterResponseModel user) {
    if (_hasFilledFields) return;

    _firstName.text = user.firstName ?? "";
    _lastName.text = user.lastName ?? "";
    _phoneNo.text = user.phoneNo ?? "";

    _hasFilledFields = true;
  }

  ImageProvider _profileImage(RegisterResponseModel user) {
    if (pickedImage != null) {
      return FileImage(pickedImage!);
    }

    final image = user.profilePicture?.trim() ?? "";

    if (image.isEmpty) {
      return const NetworkImage(defaultAvatar);
    }

    return NetworkImage(image);
  }

  Widget _buildContent(RegisterResponseModel user) {
    _fillFieldsOnce(user);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: _isUploadingImage
                        ? null
                        : () => _pickAndUploadProfileImage(user),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 47,
                        backgroundImage: _profileImage(user),
                        child: _isUploadingImage
                            ? CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 96,
                  left: 50,
                  right: 20,
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          addVerticalSpacing(2),

          ListTile(
            title: const AppText(
              text: "Email",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.bold,
            ),
            subtitle: AppText(
              text: user.email ?? "",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w600,
            ),
          ),

          ListTile(
            title: const AppText(
              text: "Phone Number",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.bold,
            ),
            subtitle: AppText(
              text: user.phoneNo ?? "",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w600,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 0, right: 0),
            child: ExpansionTile(
              backgroundColor: AppColors.white,
              collapsedBackgroundColor: AppColors.white,
              collapsedIconColor: AppColors.primary,
              iconColor: AppColors.primary,
              textColor: AppColors.primary,
              collapsedTextColor: AppColors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: "Name",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    fontWeight: FontWeight.bold,
                  ),
                  AppText(
                    text: "${user.firstName ?? ""} ${user.lastName ?? ""}",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlobalTextField(
                              fieldName: 'First Name',
                              keyBoardType: TextInputType.name,
                              removeSpace: false,
                              obscureText: false,
                              textController: _firstName,
                              onChanged: (value) {},
                            ),

                            addVerticalSpacing(5),

                            GlobalTextField(
                              fieldName: 'Last Name',
                              keyBoardType: TextInputType.name,
                              removeSpace: false,
                              obscureText: false,
                              textController: _lastName,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),

                      addVerticalSpacing(3),

                      Padding(
                        padding: const EdgeInsets.only(left: 35, right: 35),
                        child: AppButton(
                          text: "Update",
                          onPressed: _isUpdatingName
                              ? () {}
                              : () => _updateName(user),
                          widthPercent: 100,
                          heightPercent: 5,
                          btnColor: AppColors.primary,
                          isLoading: _isUpdatingName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountControllerProvider);
    final account = accountAsync.value;
    final user = account?.userData;

    final isLoading =
        accountAsync.isLoading && accountAsync.value?.userData == null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: AppText(
          text: isLoading ? "" : "Profile Updates",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(accountControllerProvider.notifier).refreshAccount();
            _hasFilledFields = false;
          },
          child: isLoading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: SizeConfig.heightAdjusted(35)),
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                )
              : user == null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: SizeConfig.heightAdjusted(30)),
                    const Center(
                      child: AppText(
                        text: "Unable to load profile",
                        textAlign: TextAlign.center,

                        color: AppColors.black,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : _buildContent(user),
        ),
      ),
    );
  }
}
