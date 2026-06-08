// ignore_for_file: library_private_types_in_public_api

import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldMessengerState>();
    return Scaffold(
      appBar: buildFlexibleAppBar(
        context: context,

        title: AppText(
          text: "About Us",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      key: key,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const ScrollPhysics(),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10),
              child: AppText(
                text: "About  Us",
                textAlign: TextAlign.start,

                color: AppColors.black,

                fontWeight: FontWeight.bold,
              ),
            ),
            addVerticalSpacing(3),
            const Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10),
              child: AppText(
                text:
                    "At GINILOG, we believe travel and logistics shouldn’t be a source of stress ‘they should be seamless, efficient and tailored to your unique needs. Founded by a team of innovative minds, who recognized the growing complexity in coordinating both personal and professional journeys, shipments and booking  accommodations. We are creating a solution a one-stop-platform that simplifies everything from planning your dream vacation  to managing complex  logistics. We’re driven by a passion for connecting people and goods and we’re committed to delivering exceptional experiences every step of the way, while connecting every dots across every end. ",
                textAlign: TextAlign.start,

                color: AppColors.black,

                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
