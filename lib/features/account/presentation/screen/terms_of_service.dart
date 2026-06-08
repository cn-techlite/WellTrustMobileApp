// ignore_for_file: library_private_types_in_public_api

import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<TermsOfServiceScreen> {
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
          text: "Terms of Service",
          textAlign: TextAlign.start,

          color: AppColors.black,

          fontWeight: FontWeight.w800,
        ),
      ),
      key: key,
      backgroundColor: Colors.white,
      body: ListView(
        physics: const ScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Terms of Services",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.bold,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Acceptance of Terms",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "By accessing and using the services provided by GINILOG, you agree to comply with and be bound by the terms and conditions outlined in this document. If you do not agree with any part of these terms, you must discontinue use of our services immediately.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Services Provided",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "GINILOG offers various digital services including but not limited to data management, cloud storage, application hosting, and analytics. These services are subject to the terms and conditions detailed herein.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "User Responsibilities",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "Users must provide accurate and complete information during the registration process.\n\nUsers are responsible for maintaining the confidentiality of their login credentials and are accountable for all activities under their account\n\nUsers must comply with all applicable laws and regulations while using GINILOG services.",
              textAlign: TextAlign.start,
              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "User Responsibilities",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "Users must provide accurate and complete information during the registration process.\n\nUsers are responsible for maintaining the confidentiality of their login credentials and are accountable for all activities under their account\n\nUsers must comply with all applicable laws and regulations while using GINILOG services.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Prohibited Activities ",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "Users are prohibited from engaging in any of the following activities:",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "Using GINILOG services for any unlawful purposes.\n\nUploading or transmitting harmful, offensive, or illegal content.\n\nAttempting to disrupt or interfere with the security or functionality of GINILOG services.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Intellectual Property",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "All content, trademarks, and data on GINILOG's platform are the intellectual property of GINILOG or its licensors. Unauthorized use of such intellectual property is strictly prohibited. ",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Privacy Policy",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "Your use of GINILOG services is also governed by our Privacy Policy. By using our services, you consent to the collection, use, and sharing of your information as described in the Privacy Policy. ",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Limitation of Liability",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "To the fullest extent permitted by law, GINILOG shall not be liable for any damages arising out of or in connection with the use of our services, including but not limited to direct, indirect, incidental, or consequential damages.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Termination",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "GINILOG reserves the right to terminate or suspend your access to our services at any time, without prior notice, for conduct that we believe violates these Terms of Services or is otherwise harmful to GINILOG or other users.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Changes to Terms of Services ",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "We may update these Terms of Services from time to time. We will notify you of any significant changes by posting the revised terms on our website and indicating the effective date. Your continued use of our services after the effective date constitutes your acceptance of the updated terms.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text: "Contact Information",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w800,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10),
            child: AppText(
              text:
                  "If you have any questions or concerns regarding these Terms of Services, please contact us using the information provided on our website.\n\nThank you for choosing GINILOG. We appreciate your trust and are committed to providing you with the best service possible.",
              textAlign: TextAlign.start,

              color: AppColors.black,

              fontWeight: FontWeight.w400,
            ),
          ),
          addVerticalSpacing(5),
        ],
      ),
    );
  }
}
