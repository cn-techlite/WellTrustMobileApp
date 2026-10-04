import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';

/// Compact visit row from the uploaded rota design.
class ScheduledVisitCard extends StatelessWidget {
  final String startTime;
  final int duration;
  final String clientName;
  final String address;
  final String withStaff;
  final String status;
  final bool hasNewHandover;
  final bool changed;
  final VoidCallback? onTap;

  const ScheduledVisitCard({
    super.key,
    required this.startTime,
    required this.duration,
    required this.clientName,
    required this.address,
    this.withStaff = '',
    this.status = 'SCHEDULED',
    this.hasNewHandover = false,
    this.changed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final completed = upper == 'DONE' || upper == 'COMPLETE';
    final missed = upper == 'MISSED' || upper == 'NOT RECORDED';
    final Pill? statusPill = switch (upper) {
      'DONE' || 'COMPLETE' => Pill.ok('Done'),
      'IN PROGRESS' || 'LIVE' => Pill.info('In progress'),
      'MISSED' || 'NOT RECORDED' => Pill.bad('Not recorded'),
      'DUE NOW' => Pill.gold('Due now'),
      'SCHEDULED' => null,
      _ => Pill.gold(status),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: completed || missed ? AppColors.bg : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: changed ? AppColors.gold : AppColors.line,
              ),
              boxShadow: changed
                  ? [
                      BoxShadow(
                        color: AppColors.gold,
                        offset: const Offset(-3, 0),
                        spreadRadius: -1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: startTime,
                        type: AppTextType.bodySmall,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      AppText(
                        text: _formatMinutes(duration),
                        type: AppTextType.labelLarge,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
                addHorizontalSpacing(3.08),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: clientName,
                        type: AppTextType.bodySmall,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        decoration: missed ? TextDecoration.lineThrough : null,
                      ),
                      AppText(
                        text: address,
                        type: AppTextType.labelLarge,
                        color: AppColors.muted,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (withStaff.isNotEmpty)
                        AppText(
                          text: 'With $withStaff',
                          type: AppTextType.labelLarge,
                          color: AppColors.muted,
                        ),
                    ],
                  ),
                ),
                if (changed || statusPill != null || hasNewHandover) ...[
                  addHorizontalSpacing(2.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (changed) Pill.gold('Changed'),
                      if (changed && statusPill != null)
                        addVerticalSpacing(0.59),
                      ?statusPill,
                      if ((changed || statusPill != null) && hasNewHandover)
                        addVerticalSpacing(0.59),
                      if (hasNewHandover) Pill.gold('New handover'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    return remainder == 0 ? '$hours h' : '$hours h $remainder min';
  }
}
