import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class BodyMapBottomSheet extends StatefulWidget {
  const BodyMapBottomSheet({super.key});

  @override
  State<BodyMapBottomSheet> createState() => _BodyMapBottomSheetState();
}

class _BodyMapBottomSheetState extends State<BodyMapBottomSheet> {
  final clientController = TextEditingController(text: "Anita Patel");
  final locationController = TextEditingController(text: "Sacrum");
  final markTypeController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedClient = "Anita Patel";
  String? selectedLocation = "Sacrum";
  String? selectedMarkType;

  final clients = [
    "Anita Patel",
    "George Davies",
    "Edna Henderson",
    "Oluwaseun Akinola",
    "Maeve O'Connor",
    "Tadeusz Kowalski",
  ];

  final bodyLocations = [
    "Sacrum",
    "Left heel",
    "Right heel",
    "Left hip",
    "Right hip",
    "Left elbow",
    "Right elbow",
    "Back",
    "Shoulder blade L",
    "Shoulder blade R",
    "Other",
  ];

  final markTypes = [
    "Bruise",
    "Pressure area · Cat 1 (redness)",
    "Pressure area · Cat 2 (broken skin)",
    "Skin tear",
    "Wound",
    "Rash",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * .92,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            addVerticalSpacing(1),
            Container(
              width: 62,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "🩹 Body map / skin check",
                          color: AppColors.black,
                          type: AppTextType.titleMedium,
                          fontWeight: FontWeight.w800,
                        ),
                        SizedBox(height: 6),
                        AppText(
                          text: "Record marks, wounds, pressure areas",
                          color: AppColors.muted,
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
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: AppColors.line),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BodyMapLabel("CLIENT *"),
                    addVerticalSpacing(1),
                    _DropDownField(
                      controller: clientController,
                      hint: "Select...",
                      options: clients,
                      onSelected: (value) {
                        setState(() {
                          selectedClient = value;
                          clientController.text = value;
                        });
                      },
                    ),

                    addVerticalSpacing(3),

                    const _BodyMapLabel("LOCATION ON BODY *"),
                    addVerticalSpacing(1),
                    _DropDownField(
                      controller: locationController,
                      hint: "Select...",
                      options: bodyLocations,
                      borderColor: AppColors.navy,
                      onSelected: (value) {
                        setState(() {
                          selectedLocation = value;
                          locationController.text = value;
                        });
                      },
                    ),

                    addVerticalSpacing(3),

                    const _BodyMapLabel("MARK TYPE *"),
                    addVerticalSpacing(1),
                    _DropDownField(
                      controller: markTypeController,
                      hint: "Select...",
                      options: markTypes,
                      onSelected: (value) {
                        setState(() {
                          selectedMarkType = value;
                          markTypeController.text = value;
                        });
                      },
                    ),

                    addVerticalSpacing(3),

                    const _BodyMapLabel("DESCRIPTION"),
                    addVerticalSpacing(1),
                    GlobalTextField(
                      textController: descriptionController,
                      fieldName: "Size, colour, any pain reported, etc.",
                      isNotePad: true,
                      keyBoardType: TextInputType.multiline,
                    ),

                    addVerticalSpacing(3),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.goldBg),
                      ),
                      child: AppText(
                        text:
                            "📷 Photo: attach a photo if appropriate — would open camera in production. Photos auto-saved to the client's record.",
                        color: AppColors.goldDeep,
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
                            borderColor: AppColors.line,
                            borderRadius: 8,
                          ),
                        ),
                        addHorizontalSpacing(2),
                        Expanded(
                          flex: 3,
                          child: AppButton(
                            text: "Save body map",
                            onPressed: () {},
                            btnColor: AppColors.primary,
                            textColor: Colors.white,
                            borderRadius: 8,
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
      ),
    );
  }
}

class _BodyMapLabel extends StatelessWidget {
  final String text;

  const _BodyMapLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      color: AppColors.muted,
      type: AppTextType.bodySmall,
      fontWeight: FontWeight.w800,
    );
  }
}

class _DropDownField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final Color? borderColor;

  const _DropDownField({
    required this.controller,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalTextField(
      fieldName: hint,
      keyBoardType: TextInputType.name,
      obscureText: false,
      readOnly: true,
      textController: controller,
      isEyeVisible: false,
      suffix: const Icon(Icons.keyboard_arrow_down),
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            final mediaQuery = MediaQuery.of(context);

            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
              child: Container(
                height: mediaQuery.size.height * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: CustomDropdownBottomSheet(
                  title: hint,
                  options: options,
                  showSearch: true,
                ),
              ),
            );
          },
        );

        if (result != null) {
          onSelected(result);
        }
      },
    );
  }
}
