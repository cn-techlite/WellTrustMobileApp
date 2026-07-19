import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class AddCareNoteBottomSheet extends StatefulWidget {
  const AddCareNoteBottomSheet({super.key});

  @override
  State<AddCareNoteBottomSheet> createState() => _AddCareNoteBottomSheetState();
}

class _AddCareNoteBottomSheetState extends State<AddCareNoteBottomSheet> {
  final PageController pageController = PageController();
  final TextEditingController noteController = TextEditingController();

  int currentPage = 0;
  String selectedResident = "Anita Patel";
  String selectedResidentInitials = "AP";
  String selectedType = "";
  String selectedTypeIcon = "";
  final Set<String> selectedTags = {"Nutrition"};

  final residents = [
    ("Anita Patel", "AP"),
    ("George Davies", "GD"),
    ("Edna Henderson", "EH"),
    ("Oluwaseun Akinola", "OA"),
    ("Maeve O'Connor", "MO"),
    ("Tadeusz Kowalski", "TK"),
  ];

  final noteTypes = [
    ("🌅", "Personal care", "Bathing, dressing, hygiene, dignity"),
    ("🍽️", "Nutrition & hydration", "Meals, drinks, intake, appetite"),
    ("🚶", "Mobility", "Transfers, walking, equipment use"),
    ("💊", "Medication / PRN", "Specific med events, PRN given, side-effects"),
    ("😊", "Mood & wellbeing", "Emotional state, engagement, conversation"),
    ("🛏️", "Sleep", "Night-time, settling, rest quality"),
    ("🧠", "Memory & cognition", "Confusion, lucid moments, orientation"),
    ("👥", "Family contact", "Visits, calls, family events"),
    ("🎨", "Activities", "Group events, hobbies, outings"),
    ("🩹", "Skin & body", "Skin checks, marks, pressure care"),
    ("😟", "Behaviour", "Distress, agitation, unusual behaviour"),
    ("📝", "General observation", "Anything that doesn't fit above"),
  ];

  final tags = [
    "Nutrition",
    "Mood",
    "Medication",
    "Mobility",
    "Sleep",
    "Family",
    "Activities",
    "Skin integrity",
    "Behaviour",
    "Pain",
    "Personal care",
    "Memory",
    "Risk flag",
  ];

  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          addVerticalSpacing(2),
          Container(
            width: 62,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xffd7d0bf),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          _SheetHeader(
            title: currentPage == 2
                ? "$selectedTypeIcon$selectedType"
                : "✏️ Add care note",
            subtitle: currentPage == 0
                ? "Step 1 of 3 · Pick a client"
                : currentPage == 1
                ? "Step 2 of 3 · Choose note type"
                : "Step 3 of 3 · Write the note",
            onClose: () => Navigator.pop(context),
          ),

          Container(height: 1, color: const Color(0xffded6c7)),

          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) {
                setState(() => currentPage = value);
              },
              children: [
                _PickClientPage(
                  residents: residents,
                  onSelect: (name, initials) {
                    setState(() {
                      selectedResident = name;
                      selectedResidentInitials = initials;
                    });
                    goToPage(1);
                  },
                  onCancel: () => Navigator.pop(context),
                ),
                _PickNoteTypePage(
                  resident: selectedResident,
                  noteTypes: noteTypes,
                  onChangeResident: () => goToPage(0),
                  onSelectType: (icon, title) {
                    setState(() {
                      selectedTypeIcon = icon;
                      selectedType = title;
                    });
                    goToPage(2);
                  },
                  onBack: () => goToPage(0),
                ),
                _WriteNotePage(
                  resident: selectedResident,
                  selectedTypeIcon: selectedTypeIcon,
                  selectedType: selectedType,
                  noteController: noteController,
                  tags: tags,
                  selectedTags: selectedTags,
                  onChangeResident: () => goToPage(0),
                  onChangeType: () => goToPage(1),
                  onTagTap: (tag) {
                    setState(() {
                      selectedTags.contains(tag)
                          ? selectedTags.remove(tag)
                          : selectedTags.add(tag);
                    });
                  },
                  onBack: () => goToPage(1),
                  onSave: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  color: Colors.black,
                  type: AppTextType.titleLarge,
                  fontWeight: FontWeight.w800,
                ),
                addVerticalSpacing(.5),
                AppText(
                  text: subtitle,
                  color: const Color(0xff8a877f),
                  type: AppTextType.bodyMedium,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xfffaf8f3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int index;

  const _StepDots({required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: i == index
                ? const Color(0xff24447f)
                : i < index
                ? const Color(0xff5d825c)
                : const Color(0xffd7d0bf),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _PickClientPage extends StatelessWidget {
  final List<(String, String)> residents;
  final void Function(String name, String initials) onSelect;
  final VoidCallback onCancel;

  const _PickClientPage({
    required this.residents,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
      child: Column(
        children: [
          const _StepDots(index: 0),
          addVerticalSpacing(2),

          ...residents.map((resident) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => onSelect(resident.$1, resident.$2),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffded6c7)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xff24447f),
                        child: AppText(
                          text: resident.$2,
                          color: Colors.white,
                          type: AppTextType.bodyLarge,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      addHorizontalSpacing(2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: resident.$1,
                              color: AppColors.black,
                              type: AppTextType.bodyMedium,
                              fontWeight: FontWeight.w800,
                            ),
                            addVerticalSpacing(2),
                            const AppText(
                              text: "Rm",
                              color: Color(0xff8a877f),
                              type: AppTextType.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xff8a877f)),
                    ],
                  ),
                ),
              ),
            );
          }),

          addVerticalSpacing(2),

          AppButton(
            text: "Cancel",
            onPressed: onCancel,
            btnColor: Colors.white,
            textColor: Colors.black,
            borderColor: const Color(0xffded6c7),
            borderRadius: 16,
          ),
          addVerticalSpacing(2),
        ],
      ),
    );
  }
}

class _PickNoteTypePage extends StatelessWidget {
  final String resident;
  final List<(String, String, String)> noteTypes;
  final VoidCallback onChangeResident;
  final void Function(String icon, String title) onSelectType;
  final VoidCallback onBack;

  const _PickNoteTypePage({
    required this.resident,
    required this.noteTypes,
    required this.onChangeResident,
    required this.onSelectType,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
      child: Column(
        children: [
          const _StepDots(index: 1),
          const SizedBox(height: 28),

          _InfoSelectBox(
            label: "RESIDENT",
            value: resident,
            onChange: onChangeResident,
          ),

          const SizedBox(height: 22),

          GridView.builder(
            itemCount: noteTypes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 6,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final item = noteTypes[index];

              return GestureDetector(
                onTap: () => onSelectType(item.$1, item.$2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffded6c7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: item.$1,
                        color: Colors.black,
                        type: AppTextType.titleSmall,
                      ),

                      addVerticalSpacing(1),
                      AppText(
                        text: item.$2,
                        color: Colors.black,
                        type: AppTextType.bodyLarge,
                        fontWeight: FontWeight.w800,
                      ),

                      addVerticalSpacing(.5),
                      AppText(
                        text: item.$3,
                        color: const Color(0xff8a877f),
                        type: AppTextType.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 34),

          SizedBox(
            width: double.infinity,
            height: 64,
            child: AppButton(
              text: "← Back",
              onPressed: onBack,
              btnColor: Colors.white,
              textColor: Colors.black,
              borderColor: const Color(0xffded6c7),
              borderRadius: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteNotePage extends StatelessWidget {
  final String resident;
  final String selectedTypeIcon;
  final String selectedType;
  final TextEditingController noteController;
  final List<String> tags;
  final Set<String> selectedTags;
  final VoidCallback onChangeResident;
  final VoidCallback onChangeType;
  final ValueChanged<String> onTagTap;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _WriteNotePage({
    required this.resident,
    required this.selectedTypeIcon,
    required this.selectedType,
    required this.noteController,
    required this.tags,
    required this.selectedTags,
    required this.onChangeResident,
    required this.onChangeType,
    required this.onTagTap,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepDots(index: 2),
          addVerticalSpacing(2),

          _InfoSelectBox(
            label: "RESIDENT",
            value: resident,
            onChange: onChangeResident,
          ),

          addVerticalSpacing(2),

          _InfoSelectBox(
            label: "TYPE",
            value: "$selectedTypeIcon$selectedType",
            onChange: onChangeType,
          ),

          addVerticalSpacing(2),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffeef3fb),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffc3cfe3)),
            ),
            child: const AppText(
              text:
                  "✓ CQC EFFECTIVE  Auto-evidenced as: Effective · How staff support people to eat and drink well",
              color: Color(0xff24447f),
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w700,
            ),
          ),

          addVerticalSpacing(2),

          Row(
            children: [
              const Expanded(
                child: AppText(
                  text: "YOUR NOTE *",
                  color: Color(0xff4c5048),
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: AppButton(
                  text: "✨ Polish",
                  onPressed: () {},
                  btnColor: const Color(0xff24447f),
                  textColor: Colors.white,
                  borderRadius: 14,
                  widthPercent: 50,
                ),
              ),
              addHorizontalSpacing(2),
              Expanded(
                child: AppButton(
                  text: "🎤 Speak",
                  onPressed: () {},
                  btnColor: Colors.white,
                  textColor: const Color(0xff4c5048),
                  borderColor: const Color(0xffded6c7),
                  borderRadius: 14,
                  widthPercent: 50,
                ),
              ),
            ],
          ),

          addVerticalSpacing(2),

          GlobalTextField(
            textController: noteController,
            fieldName:
                "What did they eat or drink? How much? Did they need help? Any preferences or concerns?",

            isNotePad: true,
            keyBoardType: TextInputType.multiline,
          ),

          addVerticalSpacing(2),

          const AppText(
            text:
                "🎙️ Tap Speak to dictate · ✨ Polish tidies your writing while keeping the facts you wrote",
            color: Color(0xff8a877f),
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w500,
          ),

          addVerticalSpacing(2),

          const AppText(
            text: "TAGS (AUTO-SET, EDIT IF NEEDED)",
            color: Color(0xff4c5048),
            type: AppTextType.titleSmall,
            fontWeight: FontWeight.w800,
          ),

          addVerticalSpacing(2),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tags.map((tag) {
              final selected = selectedTags.contains(tag);

              return GestureDetector(
                onTap: () => onTagTap(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xff24447f) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xffd0c8b4)),
                  ),
                  child: AppText(
                    text: tag,
                    color: selected ? Colors.white : const Color(0xff4c5048),
                    type: AppTextType.labelSmall,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),

          addVerticalSpacing(2),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "← Back",
                  onPressed: onBack,
                  btnColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: const Color(0xffded6c7),
                  borderRadius: 6,
                ),
              ),
              addHorizontalSpacing(3),
              Expanded(
                child: AppButton(
                  text: "Save note",
                  onPressed: onSave,
                  btnColor: const Color(0xff24447f),
                  textColor: Colors.white,
                  borderRadius: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSelectBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onChange;

  const _InfoSelectBox({
    required this.label,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffded6c7)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  color: const Color(0xff8a877f),
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: value,
                  color: Colors.black,
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: const AppText(
              text: "Change ›",
              color: Color(0xff24447f),
              type: AppTextType.bodyMedium,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
