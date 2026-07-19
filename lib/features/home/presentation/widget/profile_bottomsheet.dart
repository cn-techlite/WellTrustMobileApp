import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({super.key});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  final nameController = TextEditingController(text: "Samir Okonjo");
  final roleController = TextEditingController(
    text: "Senior Domiciliary Carer · Kettering round",
  );
  final emailController = TextEditingController(
    text: "samir.okonjo@welltrust.example",
  );
  final phoneController = TextEditingController(text: "07700 900 142");

  int selectedAvatar = 3;
  int selectedColor = 0;

  final avatars = ["👨‍⚕️", "👩‍⚕️", "👨‍🦳", "👤", "😊", "🌟"];

  final colors = [
    Color(0xff1f3f7a),
    Color(0xffb58c3a),
    Color(0xff4f714f),
    Color(0xffad4942),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.91,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              width: 42,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xffd7d0bf),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        AppText(
                          text: "👤 Your profile",
                          color: AppColors.black,
                          type: AppTextType.headlineSmall,
                          fontWeight: FontWeight.w800,
                        ),
                        SizedBox(height: 8),
                        AppText(
                          text: "Edit your photo and contact details",
                          color: Color(0xff8a877f),
                          type: AppTextType.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
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
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: colors[selectedColor],
                        child: const AppText(
                          text: "SO",
                          color: Colors.white,
                          type: AppTextType.displaySmall,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: AppButton(
                        widthPercent: 40,
                        heightPercent: 5,
                        text: "📷 Upload photo",
                        onPressed: () {},
                        btnColor: const Color(0xff24447f),
                        textColor: Colors.white,
                        borderRadius: 16,
                      ),
                    ),
                    addVerticalSpacing(2),

                    _SectionTitle("OR PICK AN EMOJI AVATAR"),
                    addVerticalSpacing(2),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(avatars.length, (index) {
                          final isSelected = selectedAvatar == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedAvatar = index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 14),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(0xffd6ceb8),
                                  width: isSelected ? 3 : 2,
                                ),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: AppText(
                                  text: avatars[index],
                                  color: Colors.black,
                                  type: AppTextType.headlineSmall,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    addVerticalSpacing(2),

                    _SectionTitle("BACKGROUND COLOUR"),
                    addVerticalSpacing(2),

                    Row(
                      children: List.generate(colors.length, (index) {
                        final isSelected = selectedColor == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedColor = index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 18),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[index],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : const Color(0xffd6ceb8),
                                width: isSelected ? 5 : 4,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    addVerticalSpacing(2),

                    _SectionTitle("NAME (SET BY MANAGER)"),
                    addVerticalSpacing(2),
                    GlobalTextField(
                      fieldName: "Name",
                      keyBoardType: TextInputType.name,
                      obscureText: false,
                      textController: nameController,
                      onChanged: (String? value) {},
                    ),

                    addVerticalSpacing(2),

                    _SectionTitle("ROLE & AREA (SET BY MANAGER)"),
                    addVerticalSpacing(2),

                    GlobalTextField(
                      fieldName: "Role",
                      keyBoardType: TextInputType.name,
                      obscureText: false,
                      textController: roleController,
                      onChanged: (String? value) {},
                    ),

                    addVerticalSpacing(2),

                    _SectionTitle("WORK EMAIL"),
                    const SizedBox(height: 12),
                    GlobalTextField(
                      fieldName: 'Email',
                      keyBoardType: TextInputType.emailAddress,
                      obscureText: false,
                      textController: emailController,
                      onChanged: (String? value) {},
                    ),

                    addVerticalSpacing(2),

                    _SectionTitle(
                      "PERSONAL PHONE (VISIBLE ONLY TO YOUR MANAGER)",
                    ),
                    const SizedBox(height: 12),
                    GlobalPhoneTextField(
                      fieldName: 'Phone Number',
                      textController: phoneController,
                      onChanged: (value) {
                        //  final completeNumber = value?.completeNumber ?? '';
                      },
                    ),

                    addVerticalSpacing(2),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8f9fb),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xffd5dbe6)),
                      ),
                      child: const AppText(
                        text:
                            "📌 Privacy: Photos and phone numbers are visible only to your manager and HR. They are not shown to clients or their families.",
                        color: Colors.black,
                        type: AppTextType.bodyMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    addVerticalSpacing(2),

                    Row(
                      children: [
                        SizedBox(
                          width: 130,
                          height: 64,
                          child: AppButton(
                            text: "Cancel",
                            onPressed: () => Navigator.pop(context),
                            btnColor: AppColors.white,
                            textColor: Colors.black,
                            borderColor: const Color(0xffded6c7),
                            borderRadius: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 64,
                            child: AppButton(
                              text: "Save",
                              onPressed: () {},
                              btnColor: AppColors.blue,
                              textColor: AppColors.white,
                              borderRadius: 16,
                            ),
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
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      color: const Color(0xff4c5048),
      type: AppTextType.bodyMedium,
      fontWeight: FontWeight.w800,
    );
  }
}
