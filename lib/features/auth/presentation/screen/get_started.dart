import 'dart:async';
import 'package:well_trust_mobile_app/core/routes/route.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

import '../../../../core/utils/package_export.dart';
import '../../data/model/onbaording_data.dart';
import '../../data/model/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String routeName = "/Onboard";
  @override
  State<OnboardingScreen> createState() => OnboardingScreenController();
}

class OnboardingScreenController extends State<OnboardingScreen> {
  late PageController pageController;
  int currentIndex = 0;
  // List<String> title = [title_1, title_2, title_3];
  // List<String> subtitle = [subtitle_1, subtitle_2, subtitle_3];
  // List<String> images = [onboard_1, onboard_2, onboard_3];
  Timer? timer;
  List<OnboardingModel> onboardingList = [];
  void nextPage() {
    if (currentIndex < 2) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        currentIndex = 0;
      });
    }

    pageController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeIn,
    );
  }

  Future<void> storeOnboardInfo() async {
    //  customLogger("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    // customLogger(prefs.getInt('onBoard'));
  }

  @override
  void initState() {
    pageController = PageController(initialPage: 0);

    pageController.addListener(() {
      setState(() {
        currentIndex = pageController.page!.toInt();
      });
    });
    super.initState();
    setState(() {
      onboardingList = formattedOnboardingList;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: PageView.builder(
              controller: pageController,
              itemCount: onboardingList.length,
              itemBuilder: (_, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    image: DecorationImage(
                      image: AssetImage(onboardingList[index].image.toString()),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      addVerticalSpacing(9.9),
                      AppText(
                        text: onboardingList[index].text.toString(),
                        textAlign: TextAlign.center,

                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        type: AppTextType.titleLarge,
                      ),
                      addVerticalSpacing(2),
                      AppText(
                        text: onboardingList[index].pre.toString(),
                        textAlign: TextAlign.center,

                        color: AppColors.white,
                        fontWeight: FontWeight.w400,
                        type: AppTextType.bodySmall,
                      ),
                      addVerticalSpacing(14.2),
                      Center(
                        child: SmoothPageIndicator(
                          controller: pageController, // PageController
                          count: onboardingList.length,
                          effect: const ExpandingDotsEffect(
                            radius: 10,
                            expansionFactor: 2,
                            dotColor: Color(0xffC5CAE8),
                            activeDotColor: AppColors.red,
                            dotHeight: 10,
                            dotWidth: 10,
                          ), // your preferred effect
                        ),
                      ),
                      addVerticalSpacing(3),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 6.heightAdjusted,
            left: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                addHorizontalSpacing(10),
                Image.asset("assets/images/logo_path.png", height: 30),
                addHorizontalSpacing(10),
                const AppText(
                  text: "Ginilog",
                  textAlign: TextAlign.start,
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  type: AppTextType.titleLarge,
                ),
              ],
            ),
          ),
          Positioned(
            top: 85.heightAdjusted,
            left: 40,
            child: SmallButton(
              text: "Skip",

              isCircular: false,
              textColor: AppColors.black,
              backgroundColor: AppColors.grey,
              onPressed: () async {
                navPush(context, RootRoutes.login);
                await storeOnboardInfo();
              },
            ),
          ),
          Positioned(
            top: 85.heightAdjusted,
            right: 40,
            child: SmallButton(
              backgroundColor: AppColors.primary,
              text: "Next",
              isCircular: false,
              textColor: AppColors.white,
              // widthPercent: 15,
              // heightPercent: 4,
              onPressed: () async {
                currentIndex == 2
                    ? navPush(context, RootRoutes.login)
                    : nextPage();
                await storeOnboardInfo();
              },
            ),
          ),
        ],
      ),
    );
  }
}
