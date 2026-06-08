// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/states/account_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  String userPhone = "";
  String profilePicture = "";
  String allNames = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      final user = ref.read(accountProvider).value?.userData;

      profilePicture = user?.profilePicture ?? globals.profilePicture;
      userPhone = user?.phoneNo ?? "";
      allNames =
          "${user?.firstName ?? globals.userName} ${user?.lastName ?? ""}"
              .trim();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void pageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: greeting(),
                              textAlign: TextAlign.start,
                              color: AppColors.muted,
                              type: AppTextType.bodyMedium,
                              fontWeight: FontWeight.w500,
                            ),

                            const AppText(
                              text: "Chigozie",
                              textAlign: TextAlign.start,
                              color: AppColors.black,
                              type: AppTextType.bodyMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.navy, AppColors.navyDeep],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: AppColors.primaryDark,
                        ),
                        alignment: Alignment.center,
                        child: const AppText(
                          text: "CN",
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
