import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class RaiseConcernBottomSheet extends StatefulWidget {
  const RaiseConcernBottomSheet({super.key});

  @override
  State<RaiseConcernBottomSheet> createState() =>
      _RaiseConcernBottomSheetState();
}

class _RaiseConcernBottomSheetState extends State<RaiseConcernBottomSheet> {
  final noticedController = TextEditingController();
  final actionController = TextEditingController();
  final clientController = TextEditingController();

  String selectedSeverity = "Watch";
  String? selectedClient;
  final Set<String> selectedCategories = {};

  final clients = [
    "Anita Patel",
    "George Davies",
    "Edna Henderson",
    "Oluwaseun Akinola",
    "Maeve O'Connor",
    "Tadeusz Kowalski",
  ];

  final categories = [
    "Welfare / wellbeing",
    "Home environment",
    "Family / social",
    "Mental state",
    "Physical health",
    "Hygiene",
    "Nutrition",
    "Safeguarding-adjacent",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          addVerticalSpacing(1),
          Container(
            width: 62,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xffd7d0bf),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "🚩 Raise a concern",
                        color: AppColors.black,
                        type: AppTextType.titleMedium,
                        fontWeight: FontWeight.w800,
                      ),
                      SizedBox(height: 6),
                      AppText(
                        text: "Early warning to the co-ordinator",
                        color: Color(0xff8a877f),
                        type: AppTextType.bodySmall,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xfffaf8f3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xffded6c7)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConcernInfoBox(),

                  addVerticalSpacing(3),

                  const _ConcernLabel("HOW WORRIED ARE YOU? *"),

                  addVerticalSpacing(1.5),

                  Row(
                    children: [
                      Expanded(
                        child: _SeverityCard(
                          icon: "👀",
                          title: "Watch",
                          subtitle: "FYI · review next\nweek",
                          selected: selectedSeverity == "Watch",
                          titleColor: const Color(0xff9a711f),
                          onTap: () {
                            setState(() => selectedSeverity = "Watch");
                          },
                        ),
                      ),
                      addHorizontalSpacing(1.5),
                      Expanded(
                        child: _SeverityCard(
                          icon: "⚠",
                          title: "Worried",
                          subtitle: "Look at within 48h",
                          selected: selectedSeverity == "Worried",
                          titleColor: const Color(0xffdd7900),
                          onTap: () {
                            setState(() => selectedSeverity = "Worried");
                          },
                        ),
                      ),
                      addHorizontalSpacing(1.5),
                      Expanded(
                        child: _SeverityCard(
                          icon: "🚨",
                          title: "Urgent",
                          subtitle: "Today, please",
                          selected: selectedSeverity == "Urgent",
                          titleColor: const Color(0xffbf4b45),
                          onTap: () {
                            setState(() => selectedSeverity = "Urgent");
                          },
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(3),

                  const _ConcernLabel("CLIENT *"),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    fieldName: "Select Client",
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    readOnly: true,
                    textController: clientController,
                    isEyeVisible: false,
                    suffix: const Icon(Icons.arrow_drop_down),
                    onChanged: (value) {
                      setState(() {
                        selectedClient = value;
                        clientController.text = value!;
                      });
                    },
                    onTap: () async {
                      final result = await showDropDownSheet(
                        title: "Select Client",
                        options: clients,
                      );

                      if (result != null) {
                        setState(() {
                          selectedClient = result;
                          clientController.text = result;
                        });
                      }
                    },
                  ),

                  addVerticalSpacing(3),

                  const _ConcernLabel("CATEGORY *"),

                  addVerticalSpacing(1.2),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((category) {
                      final selected = selectedCategories.contains(category);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected
                                ? selectedCategories.remove(category)
                                : selectedCategories.add(category);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xff24447f)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xff24447f)
                                  : const Color(0xffd0c8b4),
                            ),
                          ),
                          child: AppText(
                            text: category,
                            color: selected
                                ? Colors.white
                                : const Color(0xff4c5048),
                            type: AppTextType.labelSmall,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  addVerticalSpacing(3),

                  const _ConcernLabel("WHAT DID YOU NOTICE? *"),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    textController: noticedController,
                    fieldName:
                        "Be specific. What did you see, hear, or sense that's different from usual?",
                    isNotePad: true,
                    keyBoardType: TextInputType.multiline,
                  ),

                  addVerticalSpacing(3),

                  const _ConcernLabel("WHAT DID YOU DO AT THE TIME?"),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    textController: actionController,
                    fieldName:
                        "e.g. Called the daughter · made sure they ate before I left · checked the fridge stock",
                    isNotePad: true,
                    keyBoardType: TextInputType.multiline,
                  ),

                  addVerticalSpacing(3),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fb),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffd5dbe6)),
                    ),
                    child: const AppText(
                      text:
                          "📌 What happens next: Goes to the care co-ordinator's concerns queue. They'll review by the deadline set by severity. You'll get a message back when they've actioned it.",
                      color: AppColors.black,
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  addVerticalSpacing(4),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: AppButton(
                          text: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          btnColor: Colors.white,
                          textColor: AppColors.black,
                          borderColor: const Color(0xffded6c7),
                          borderRadius: 4,
                        ),
                      ),
                      addHorizontalSpacing(2),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: "Send concern",
                          onPressed: () {},
                          btnColor: const Color(0xff24447f),
                          textColor: Colors.white,
                          borderRadius: 4,
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> showDropDownSheet({
    required String title,
    required List<String> options,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isTablet = mediaQuery.size.shortestSide >= 600;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Container(
            height: mediaQuery.size.height * 0.5,
            width: isTablet ? mediaQuery.size.width : double.infinity,
            constraints: BoxConstraints(
              maxWidth: isTablet ? mediaQuery.size.width : double.infinity,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: CustomDropdownBottomSheet(
              title: title,
              options: options,
              showSearch: true,
            ),
          ),
        );
      },
    );
  }
}

class _ConcernInfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfffff8f8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xfff0c7c7)),
      ),
      child: const AppText(
        text:
            "When to use this — early signals worth flagging. Not an emergency or safeguarding. Examples: client seems more confused than usual, fridge looks empty, family haven't visited in weeks, low mood, hygiene declining, environment looks unsafe.",
        color: AppColors.black,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ConcernLabel extends StatelessWidget {
  final String text;

  const _ConcernLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      color: const Color(0xff4c5048),
      type: AppTextType.bodySmall,
      fontWeight: FontWeight.w800,
    );
  }
}

class _SeverityCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color titleColor;
  final VoidCallback onTap;

  const _SeverityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? titleColor : const Color(0xffded6c7),
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: icon,
              color: titleColor,
              type: AppTextType.titleLarge,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            addVerticalSpacing(1),
            AppText(
              text: title,
              color: titleColor,
              type: AppTextType.bodyMedium,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            addVerticalSpacing(.5),
            AppText(
              text: subtitle,
              color: const Color(0xff8a877f),
              type: AppTextType.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
