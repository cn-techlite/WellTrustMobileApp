import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

/// Small rounded status pill (design `.pill`).
class Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const Pill(this.text, {super.key, required this.bg, required this.fg});

  factory Pill.neutral(String t) =>
      Pill(t, bg: AppColors.line, fg: AppColors.ink);
  factory Pill.gold(String t) =>
      Pill(t, bg: AppColors.goldBg, fg: AppColors.goldDeep);
  factory Pill.bad(String t) =>
      Pill(t, bg: AppColors.roseBg, fg: AppColors.rose);
  factory Pill.warn(String t) =>
      Pill(t, bg: AppColors.amberBg, fg: AppColors.amber);
  factory Pill.ok(String t) =>
      Pill(t, bg: AppColors.sageBg, fg: AppColors.sage);
  factory Pill.info(String t) =>
      Pill(t, bg: AppColors.infoBg, fg: AppColors.info);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.6,
        ),
      ),
    );
  }
}

Pill kindPill(HandoverKind k) => switch (k) {
  HandoverKind.concern => Pill.bad(k.label),
  HandoverKind.todo => Pill.warn(k.label),
  HandoverKind.change => Pill.gold(k.label),
  HandoverKind.visitSummary => Pill.info(k.label),
  HandoverKind.info => Pill.neutral(k.label),
};

String handoverWhen(DateTime t) => DateFormat('d MMM, HH:mm').format(t);

/// White design card used across the handover screens.
class DesignCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const DesignCard({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor ?? AppColors.line,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-width primary (navy) button from the design.
class DesignButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool small;
  final IconData? icon;

  const DesignButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.secondary = false,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = secondary ? AppColors.ink : AppColors.onPrimary;
    return SizedBox(
      width: small ? null : double.infinity,
      height: small ? 44 : 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: secondary ? Colors.transparent : AppColors.primary,
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.line,
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: secondary ? AppColors.line2 : AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: small ? 14 : 15,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented tabs (design `.tabs`).
class SegmentTabs extends StatelessWidget {
  final List<(String, String)> options; // value, label
  final String active;
  final ValueChanged<String> onChanged;

  const SegmentTabs({
    super.key,
    required this.options,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.$1),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o.$1 == active
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: o.$1 == active ? AppColors.ink : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Notice box (design `.notice`).
class NoticeBox extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final IconData icon;

  const NoticeBox(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  factory NoticeBox.ok(String t) => NoticeBox(
    t,
    bg: AppColors.sageBg,
    fg: AppColors.sage,
    icon: Icons.check_circle_outline,
  );
  factory NoticeBox.info(String t) => NoticeBox(
    t,
    bg: AppColors.infoBg,
    fg: AppColors.info,
    icon: Icons.info_outline,
  );
  factory NoticeBox.warn(String t) => NoticeBox(
    t,
    bg: AppColors.amberBg,
    fg: AppColors.amber,
    icon: Icons.warning_amber_rounded,
  );
  factory NoticeBox.danger(String t) => NoticeBox(
    t,
    bg: AppColors.roseBg,
    fg: AppColors.rose,
    icon: Icons.warning_amber_rounded,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
