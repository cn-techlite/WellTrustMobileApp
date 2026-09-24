import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/visit_details_screen.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/sheduled_visit_card.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {});

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {}
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: Column(
        children: [
          const WellTrustAppBar(title: 'Visits (Rota)'),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _WeekStrip(),
                            const _DaySummary(),
                            addVerticalSpacing(.5),
                            _ScheduleSectionHeader(title: 'Morning · 4 VISITS'),
                            addVerticalSpacing(1.3),
                            ScheduledVisitCard(
                              startTime: '12:30',
                              endTime: '12:45',
                              duration: 15,
                              initials: 'AP',
                              clientName: 'Anita Patel',
                              address: '14 Linden Avenue',
                              visitType: '🍽 Lunch call',
                              tasks: const [
                                'Lunch prompt',
                                'Lunch meds',
                                'Fluids',
                              ],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  VisitStartDetailsPage(),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8,
                              ),
                              child: TravelDivider(minutes: 19),
                            ),
                            ScheduledVisitCard(
                              startTime: '12:30',
                              endTime: '12:45',
                              duration: 15,
                              initials: 'AP',
                              clientName: 'Anita Patel',
                              address: '14 Linden Avenue',
                              visitType: '🍽 Lunch call',
                              tasks: const [
                                'Lunch prompt',
                                'Lunch meds',
                                'Fluids',
                              ],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  VisitStartDetailsPage(),
                                );
                              },
                            ),
                            ScheduledVisitCard(
                              startTime: '12:30',
                              endTime: '12:45',
                              duration: 15,
                              initials: 'AP',
                              clientName: 'Anita Patel',
                              address: '14 Linden Avenue',
                              visitType: '🍽 Lunch call',
                              tasks: const [
                                'Lunch prompt',
                                'Lunch meds',
                                'Fluids',
                              ],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  VisitStartDetailsPage(),
                                );
                              },
                            ),
                            ScheduledVisitCard(
                              startTime: '12:30',
                              endTime: '12:45',
                              duration: 15,
                              initials: 'AP',
                              clientName: 'Anita Patel',
                              address: '14 Linden Avenue',
                              visitType: '🍽 Lunch call',
                              tasks: const [
                                'Lunch prompt',
                                'Lunch meds',
                                'Fluids',
                              ],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  VisitStartDetailsPage(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mon to Sun buttons; today has the gold outline and dots mark days with visits.
class _WeekStrip extends StatefulWidget {
  const _WeekStrip();

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  late DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Builder(
                  builder: (_) {
                    final d = monday.add(Duration(days: i));
                    final isToday = same(d, now);
                    final isSel = same(d, selected);
                    return GestureDetector(
                      onTap: () => setState(() => selected = d),
                      child: Container(
                        height: 62,
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.goldBg : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday || isSel
                                ? AppColors.gold
                                : AppColors.line,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(d).substring(0, 1),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: d.weekday <= 6
                                    ? AppColors.gold
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today: 6 h 44 min of care and 2 h 43 min travel',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill.neutral('13 visits'),
              Pill.neutral('404 min care'),
              Pill.ok('4 done'),
              Pill.neutral('163 min travel'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleSectionHeader extends StatelessWidget {
  final String title;

  const _ScheduleSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Divider(color: AppColors.line, thickness: 1)),
      ],
    );
  }
}

class TravelDivider extends StatelessWidget {
  final int minutes;

  const TravelDivider({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          text: '🚗',
          textAlign: TextAlign.start,
          color: AppColors.ink2,
          type: AppTextType.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 12),
        AppText(
          text: '$minutes min travel',
          textAlign: TextAlign.start,
          color: AppColors.muted,
          type: AppTextType.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 28),
        Expanded(child: Divider(color: AppColors.line, thickness: 1)),
      ],
    );
  }
}
