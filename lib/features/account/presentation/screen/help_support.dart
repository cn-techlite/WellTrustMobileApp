// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/package_export.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<HelpAndSupportPage> {
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
        backgroundColor: AppColors.surface,
        title: AppText(
          text: "Help and Support",
          textAlign: TextAlign.center,
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          type: AppTextType.bodyMedium,
        ),
      ),

      key: key,
      backgroundColor: AppColors.bg,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: AppColors.surface,
        child: ListView(
          physics: const ScrollPhysics(),
          children: [
            addVerticalSpacing(20),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10),
              child: AppText(
                text: "FAQ",
                type: AppTextType.bodyMedium,
                textAlign: TextAlign.start,

                color: AppColors.black,

                fontWeight: FontWeight.w600,
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text: "How does BMG Work?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text: "All you need to do is create an account",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "All you need to do is create an account, then input your details and you are good to go.",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text:
                                  "How do i select the right logistics company?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text:
                                "Logistics Companies are Listed in the App, you can select the logistics company you want, we have verified, you can select any logistics company you want.",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "Logistics Companies are Listed in the App, you can select the logistics company you want, we have verified, you can select any logistics company you want.",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.textSize,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text:
                                  "How long will it take my gas to be delivered?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text: "It depends on the distance from your house",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "It depends on the distance from your house to the logistics company . The closer the selected location to you , the faster the delivery",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text:
                                  "How can I trust that my gas is complete as requested?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text:
                                "Our rider must return the receipt of purchase",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "Our rider must return the receipt of purchase or a video recording for you to verify",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text: "How can I make a payment for my order?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text:
                                "You can either make a payment by bank transfer or",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "You can either make a payment by bank transfer or by  card in the app via our secured payment gateway",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text: "How can I make an order?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text:
                                "Ensure you have selected the correct location ",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "Ensure you have selected the correct location in the app . If you still can’t find your preferred logistics company, it means they have not been registered on our app. Please encourage them to contact us to be added on our app",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text: "How can I make a complaint about a rider?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text: "You can report the rider on the app in",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "You can report the rider on the app in the review section  or you can contact our office directly on our phone lines",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            addVerticalSpacing(20),
            ExpandableNotifier(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    children: <Widget>[
                      ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                            padding: EdgeInsets.all(10),
                            child: AppText(
                              text: "How can I track my order?",
                              type: AppTextType.bodyMedium,
                              textAlign: TextAlign.start,

                              color: AppColors.black,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          collapsed: AppText(
                            text: "You can track your order on the track",
                            type: AppTextType.bodySmall,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.black,
                            fontSize: 15.textSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Source Sans 3',
                          ),
                          expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var _ in Iterable.generate(1))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppText(
                                    text:
                                        "You can track your order on the track order section in the app",
                                    type: AppTextType.bodySmall,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    color: AppColors.black,
                                    fontSize: 15.textSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Source Sans 3',
                                  ),
                                ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                  crossFadePoint: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
