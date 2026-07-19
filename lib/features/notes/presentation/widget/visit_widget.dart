import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class ClientListTile extends StatelessWidget {
  final String initials;
  final String name;
  final String info;
  final String note;
  final List<String> tags;

  const ClientListTile({
    super.key,
    required this.initials,
    required this.name,
    required this.info,
    required this.note,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xffE2D8C7), width: 1.4),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xffBF9747),
            child: AppText(
              text: initials,
              textAlign: TextAlign.center,
              color: Colors.white,
              type: AppTextType.labelSmall,
              fontWeight: FontWeight.w800,
            ),
          ),

          addHorizontalSpacing(3),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  textAlign: TextAlign.start,
                  color: AppColors.black,
                  type: AppTextType.bodyLarge,
                  fontWeight: FontWeight.w800,
                ),
                addVerticalSpacing(1),
                AppText(
                  text: info,
                  textAlign: TextAlign.start,
                  color: const Color(0xff8E8A82),
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w400,
                ),
                if (note.isNotEmpty) ...[
                  addVerticalSpacing(1),
                  AppText(
                    text: note,
                    textAlign: TextAlign.start,
                    color: const Color(0xff454A43),
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w400,
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  addVerticalSpacing(1),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.map((tag) => ClientFlagChip(tag)).toList(),
                  ),
                ],
              ],
            ),
          ),

          addHorizontalSpacing(1),

          const Icon(Icons.chevron_right, color: Color(0xff8E8A82), size: 24),
        ],
      ),
    );
  }
}

class ClientFlagChip extends StatelessWidget {
  final String label;

  const ClientFlagChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xffF8EEE6);
    Color fg = const Color(0xffC9783D);

    if (label == "DEMENTIA") {
      bg = const Color(0xffEEF1F6);
      fg = AppColors.black;
    }

    if (label == "DNAR") {
      bg = const Color(0xffF8E8E5);
      fg = const Color(0xffB85048);
    }

    if (label.contains("ALLERGY")) {
      bg = const Color(0xffF4EEE2);
      fg = const Color(0xff9B7626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        text: label,
        textAlign: TextAlign.center,
        color: fg,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
