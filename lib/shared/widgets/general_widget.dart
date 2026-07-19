import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/data/model/service_user_response_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/visit_response_model.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

/// A small coloured pill used for resident flags (falls / DNAR / allergy …).
class FlagChip extends StatelessWidget {
  final Flag flag;

  const FlagChip(this.flag, {super.key});

  static const _palette = <String, (Color, Color)>{
    'dnar': (Color(0x1FB85048), AppColors.rose),
    'falls': (Color(0x1FC97B3F), AppColors.amber),
    'allergy': (Color(0x1FB85048), AppColors.rose),
    'dementia': (Color(0x1F1E3A6F), AppColors.navy),
  };

  @override
  Widget build(BuildContext context) {
    final c = _palette[flag.type] ?? (AppColors.cream, AppColors.ink2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.$1,
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(
        text: flag.label.toUpperCase(),
        textAlign: TextAlign.center,
        color: c.$2,
        type: AppTextType.bodySmall,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Circular avatar with initials.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? bg;

  const InitialsAvatar(this.initials, {super.key, this.size = 42, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: bg,
      ),
      alignment: Alignment.center,
      child: AppText(
        text: initials,
        textAlign: TextAlign.center,
        color: Colors.white,
        type: AppTextType.bodyMedium,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// White rounded card matching the web `.visit-card` / `.vd-info-card` look.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? background;
  final BoxBorder? border;
  final double radius;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(18, 0, 18, 10),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.onTap,
    this.background,
    this.border,
    this.radius = 14,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.line),
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Empty-state block.
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        children: [
          AppText(
            text: icon,
            textAlign: TextAlign.center,
            color: AppColors.black,
            type: AppTextType.headlineSmall,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          AppText(
            text: title,
            textAlign: TextAlign.center,
            color: AppColors.ink,
            type: AppTextType.bodyLarge,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 4),
          AppText(
            text: subtitle,
            textAlign: TextAlign.center,
            color: AppColors.muted,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

/// A status pill for a visit.
Widget visitStatusPill(VisitStatus status) {
  late Color bg;
  late Color fg;
  late String label;

  switch (status) {
    case VisitStatus.inProgress:
      bg = const Color(0x1F5D7A58);
      fg = AppColors.sage;
      label = '● Live';
      break;

    case VisitStatus.complete:
      bg = const Color(0x1F5D7A58);
      fg = AppColors.sage;
      label = '✓ Done';
      break;

    case VisitStatus.missed:
      bg = const Color(0x1FB85048);
      fg = AppColors.rose;
      label = '⚠ Missed';
      break;

    case VisitStatus.scheduled:
      bg = AppColors.cream;
      fg = AppColors.ink2;
      label = 'Scheduled';
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: AppText(
      text: label,
      textAlign: TextAlign.center,
      color: fg,
      type: AppTextType.bodySmall,
      fontWeight: FontWeight.w700,
    ),
  );
}
