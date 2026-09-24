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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.gold,
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
                  color: AppColors.muted,
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w400,
                ),
                if (note.isNotEmpty) ...[
                  addVerticalSpacing(1),
                  AppText(
                    text: note,
                    textAlign: TextAlign.start,
                    color: AppColors.ink,
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

          Icon(Icons.chevron_right, color: AppColors.muted, size: 24),
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
    Color bg = AppColors.roseBg;
    Color fg = AppColors.amber;

    if (label == "DEMENTIA") {
      bg = AppColors.bg;
      fg = AppColors.black;
    }

    if (label == "DNAR") {
      bg = AppColors.roseBg;
      fg = AppColors.rose;
    }

    if (label.contains("ALLERGY")) {
      bg = AppColors.bg;
      fg = AppColors.goldDeep;
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
