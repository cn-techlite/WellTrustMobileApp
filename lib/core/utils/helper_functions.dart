import 'package:well_trust_mobile_app/core/utils/colors.dart';
// ignore_for_file: strict_top_level_inference, deprecated_member_use

import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:flutter/cupertino.dart';

import '../routes/routers.dart';

void dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void navigateToRoute(BuildContext context, dynamic routeClass) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => routeClass));
}

void navigateAndReplaceRoute(BuildContext context, dynamic routeClass) {
  Navigator.pushReplacement(
    context,
    CupertinoPageRoute(builder: (context) => routeClass),
  );
}

void navigateAndRemoveUntilRoute(BuildContext context, dynamic routeClass) {
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute(builder: (context) => routeClass),
    (route) => false,
  );
}

void navPush(BuildContext context, String route) {
  Navigator.push(context, generateRoute(RouteSettings(name: route)));
}

void displayBottomSheet(context, Widget bottomSheet) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
    ),
    builder: (context) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: GestureDetector(onTap: dismissKeyboard, child: bottomSheet),
    ),
  );
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning,';
  if (h < 18) return 'Good afternoon,';
  return 'Good evening,';
}
