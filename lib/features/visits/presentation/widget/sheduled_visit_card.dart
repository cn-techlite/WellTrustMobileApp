import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';

class ScheduledVisitCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final int duration;
  final String initials;
  final String clientName;
  final String address;
  final String visitType;
  final List<String> tasks;
  final String status;
  final VoidCallback? onTap;

  const ScheduledVisitCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.initials,
    required this.clientName,
    required this.address,
    required this.visitType,
    required this.tasks,
    this.status = "SCHEDULED",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final Pill? pill = switch (upper) {
      'DONE' || 'COMPLETE' => Pill.ok('Done'),
      'IN PROGRESS' || 'LIVE' => Pill.info('In progress'),
      'MISSED' => Pill.bad('Not recorded'),
      'SCHEDULED' => null,
      _ => Pill.gold(status),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startTime,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '$duration min',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.muted,
                        ),
                      ),
                      if (visitType.isNotEmpty)
                        Text(
                          visitType,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.muted,
                          ),
                        ),
                      if (tasks.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tasks.join(' \u00b7 '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (pill != null) ...[const SizedBox(width: 8), pill],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
