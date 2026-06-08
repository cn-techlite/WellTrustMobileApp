// ignore_for_file: deprecated_member_use

import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';

AppBar buildFlexibleAppBar({
  required BuildContext context,
  String backIconAsset = 'assets/svgs/back_button.svg',
  double iconWidth = 15.0,
  VoidCallback? onBack,
  Color backgroundColor = AppColors.white,
  Color surfaceTintColor = AppColors.white,
  Color foregroundColor = AppColors.white,
  bool showBackButton = true,
  Widget? title,
  List<Widget>? actions,
  Widget? bottomWidget, // e.g. Search bar, filter chips
  double bottomHeight = 56.0,
  bool automaticallyImplyLeading = false,
  bool centerTitle = false,
}) {
  return AppBar(
    automaticallyImplyLeading: automaticallyImplyLeading,
    backgroundColor: backgroundColor,
    surfaceTintColor: surfaceTintColor,
    foregroundColor: foregroundColor,
    elevation: 0,
    centerTitle: centerTitle,
    leading: showBackButton
        ? IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: SvgPicture.asset(backIconAsset, width: iconWidth),
          )
        : null,
    title: title,
    actions: actions,
    bottom: bottomWidget != null
        ? PreferredSize(
            preferredSize: Size.fromHeight(bottomHeight),
            child: bottomWidget,
          )
        : null,
  );
}
