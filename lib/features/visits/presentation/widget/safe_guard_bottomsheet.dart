import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class SafeguardingBottomSheet extends StatefulWidget {
  const SafeguardingBottomSheet({super.key});

  @override
  State<SafeguardingBottomSheet> createState() =>
      _SafeguardingBottomSheetState();
}

class _SafeguardingBottomSheetState extends State<SafeguardingBottomSheet> {
  final clients = [
    "Anita Patel",
    "George Davies",
    "Edna Henderson",
    "Oluwaseun Akinola",
    "Maeve O'Connor",
    "Tadeusz Kowalski",
  ];
  final safeguardingTypes = [
    "Suspected abuse (client → other person in home)",
    "Suspected abuse (family / friend → client)",
    "Suspected abuse (staff → client)",
    "Suspected neglect (self-neglect or by family)",
    "Financial concern",
    "DoLS / capacity concern",
    "Whistleblowing (about the agency)",
    "Other",
  ];
  final concernTypeController = TextEditingController();
  final clientController = TextEditingController(
    text: "Select (if applicable)...",
  );
  final observationController = TextEditingController();

  Future<void> selectConcernType() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .55,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: CustomDropdownBottomSheet(
          title: "Concern Type",
          options: safeguardingTypes,
          showSearch: true,
        ),
      ),
    );

    if (result != null) {
      concernTypeController.text = result;
      setState(() {});
    }
  }

  Future<void> selectClient() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .55,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: CustomDropdownBottomSheet(
          title: "Client",
          options: clients,
          showSearch: true,
        ),
      ),
    );

    if (result != null) {
      clientController.text = result;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .92,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          addVerticalSpacing(1),

          Container(
            width: 65,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.roseBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.roseBg),
                    ),
                    child: AppText(
                      text:
                          "⚠️ For immediate danger: call 999. This form alerts your manager within minutes; it is not a replacement for emergency services.",
                      color: AppColors.rose,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  addVerticalSpacing(3),

                  AppText(
                    text: "CONCERN TYPE *",
                    color: AppColors.black,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w800,
                  ),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    textController: concernTypeController,
                    fieldName: "Select...",
                    readOnly: true,
                    suffix: const Icon(Icons.keyboard_arrow_down),
                    keyBoardType: TextInputType.name,
                    onTap: selectConcernType,
                  ),

                  addVerticalSpacing(3),

                  AppText(
                    text: "CLIENT INVOLVED",
                    color: AppColors.black,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w800,
                  ),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    textController: clientController,
                    fieldName: "Select (if applicable)...",
                    readOnly: true,
                    suffix: const Icon(Icons.keyboard_arrow_down),
                    keyBoardType: TextInputType.name,
                    onTap: selectClient,
                  ),

                  addVerticalSpacing(3),

                  AppText(
                    text: "WHAT DID YOU OBSERVE? *",
                    color: AppColors.black,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w800,
                  ),

                  addVerticalSpacing(1),

                  GlobalTextField(
                    textController: observationController,
                    fieldName:
                        "Be factual. Stick to what you saw or heard, when, and where.",
                    keyBoardType: TextInputType.multiline,
                    isNotePad: true,
                  ),

                  addVerticalSpacing(3),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: AppText(
                      text:
                          "📌 Confidentiality: Whistleblowing reports are protected. Your name will not be shared with the person concerned.",
                      color: AppColors.black,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  addVerticalSpacing(4),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          btnColor: Colors.white,
                          textColor: AppColors.black,
                          borderColor: AppColors.line,
                        ),
                      ),

                      addHorizontalSpacing(2),

                      Expanded(
                        flex: 3,
                        child: AppButton(
                          text: "🚨 Send alert to manager",
                          onPressed: () {},
                          btnColor: AppColors.rose,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
