// ignore_for_file: use_build_context_synchronously

import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class ReportIncidentBottomSheet extends StatefulWidget {
  const ReportIncidentBottomSheet({super.key});

  @override
  State<ReportIncidentBottomSheet> createState() =>
      _ReportIncidentBottomSheetState();
}

class _ReportIncidentBottomSheetState extends State<ReportIncidentBottomSheet> {
  final typeController = TextEditingController();
  final clientController = TextEditingController(text: "Edna Henderson");
  final dateController = TextEditingController(text: "16/06/2026, 09:20");
  final descriptionController = TextEditingController();
  final actionController = TextEditingController();

  final incidentTypes = [
    "Fall",
    "Medication error",
    "Near-miss",
    "Injury",
    "Manual handling",
    "Property damage",
    "Client unwell",
    "Other",
  ];

  final clients = [
    "Anita Patel",
    "George Davies",
    "Edna Henderson",
    "Oluwaseun Akinola",
    "Maeve O'Connor",
    "Tadeusz Kowalski",
  ];

  Future<String?> showDropDownSheet({
    required String title,
    required List<String> options,
  }) async {
    return showModalBottomSheet<String>(
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

  Future<void> pickIncidentDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    dateController.text =
        "${selected.day.toString().padLeft(2, '0')}/"
        "${selected.month.toString().padLeft(2, '0')}/"
        "${selected.year}, "
        "${selected.hour.toString().padLeft(2, '0')}:"
        "${selected.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * .92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "⚠️ Report an incident",
                          color: AppColors.black,
                          type: AppTextType.titleMedium,
                          fontWeight: FontWeight.w800,
                        ),
                        SizedBox(height: 6),
                        AppText(
                          text: "Co-ordinator will be notified immediately",
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
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _IncidentLabel("TYPE *"),
                    addVerticalSpacing(1),
                    _IncidentDropdownField(
                      controller: typeController,
                      hint: "Select type...",
                      onTap: () async {
                        final result = await showDropDownSheet(
                          title: "Select type",
                          options: incidentTypes,
                        );

                        if (result != null) {
                          setState(() => typeController.text = result);
                        }
                      },
                    ),

                    addVerticalSpacing(3),

                    const _IncidentLabel("CLIENT INVOLVED *"),
                    addVerticalSpacing(1),
                    _IncidentDropdownField(
                      controller: clientController,
                      hint: "Select client...",
                      onTap: () async {
                        final result = await showDropDownSheet(
                          title: "Select client",
                          options: clients,
                        );

                        if (result != null) {
                          setState(() => clientController.text = result);
                        }
                      },
                    ),

                    addVerticalSpacing(3),

                    const _IncidentLabel("WHEN DID IT HAPPEN? *"),
                    addVerticalSpacing(1),
                    GlobalTextField(
                      fieldName: "Select date and time",
                      keyBoardType: TextInputType.datetime,
                      obscureText: false,
                      readOnly: true,
                      textController: dateController,
                      isEyeVisible: false,
                      suffix: const Icon(Icons.calendar_today_outlined),
                      onTap: pickIncidentDate,
                    ),

                    addVerticalSpacing(3),

                    const _IncidentLabel("DESCRIPTION *"),
                    addVerticalSpacing(1),
                    GlobalTextField(
                      textController: descriptionController,
                      fieldName:
                          "Be factual and specific. Who, what, when, where, witnessed by.",
                      isNotePad: true,
                      keyBoardType: TextInputType.multiline,
                    ),

                    addVerticalSpacing(3),

                    const _IncidentLabel("IMMEDIATE ACTION TAKEN"),
                    addVerticalSpacing(1),
                    GlobalTextField(
                      textController: actionController,
                      fieldName:
                          "What did you do at the time? Did you call anyone (family, 999, GP)?",
                      isNotePad: true,
                      keyBoardType: TextInputType.multiline,
                    ),

                    addVerticalSpacing(3),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff8f8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xfff0c7c7)),
                      ),
                      child: const AppText(
                        text:
                            "Notifiable? If this involves DoLS breach, abuse, serious injury, or death, the manager must notify CQC within 24h. The system will flag this automatically.",
                        color: Color(0xffbf4b45),
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
                            borderRadius: 8,
                          ),
                        ),
                        addHorizontalSpacing(2),
                        Expanded(
                          flex: 3,
                          child: AppButton(
                            text: "Submit incident report",
                            onPressed: () {},
                            btnColor: const Color(0xff24447f),
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

class _IncidentLabel extends StatelessWidget {
  final String text;

  const _IncidentLabel(this.text);

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

class _IncidentDropdownField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _IncidentDropdownField({
    required this.controller,
    required this.hint,
    required this.onTap,
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
      onTap: onTap,
    );
  }
}
