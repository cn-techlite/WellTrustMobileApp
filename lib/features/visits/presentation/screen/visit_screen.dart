import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/visit_details_screen.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/sheduled_visit_card.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

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
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "Today's Rota",
                          textAlign: TextAlign.start,
                          color: AppColors.muted,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w500,
                        ),

                        AppText(
                          text: DateFormat(
                            'EEEE d MMMM • h:mm a',
                          ).format(DateTime.now()),
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.navy, AppColors.navyDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: AppColors.primaryDark,
                    ),
                    alignment: Alignment.center,
                    child: const AppText(
                      text: "CN",
                      textAlign: TextAlign.start,
                      color: AppColors.black,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 10, 8, 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2D9C9)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryItem(value: "13", label: 'VISITS'),
                            ),
                            Expanded(
                              child: _SummaryItem(
                                value: "404",
                                label: 'TOTAL MIN',
                              ),
                            ),
                            Expanded(
                              child: _SummaryItem(value: "4/13", label: 'DONE'),
                            ),
                            Expanded(
                              child: _SummaryItem(
                                value: "163m",
                                label: 'TRAVEL',
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        tasks: const ['Lunch prompt', 'Lunch meds', 'Fluids'],
                        onTap: () {
                          navigateToRoute(context, VisitStartDetailsPage());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                        tasks: const ['Lunch prompt', 'Lunch meds', 'Fluids'],
                        onTap: () {
                          navigateToRoute(context, VisitStartDetailsPage());
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
                        tasks: const ['Lunch prompt', 'Lunch meds', 'Fluids'],
                        onTap: () {
                          navigateToRoute(context, VisitStartDetailsPage());
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
                        tasks: const ['Lunch prompt', 'Lunch meds', 'Fluids'],
                        onTap: () {
                          navigateToRoute(context, VisitStartDetailsPage());
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
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          text: value,
          textAlign: TextAlign.center,
          color: AppColors.navy,
          type: AppTextType.headlineSmall,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 5),
        AppText(
          text: label,
          textAlign: TextAlign.center,
          color: AppColors.muted,
          type: AppTextType.bodySmall,
          fontWeight: FontWeight.w400,
        ),
      ],
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
        AppText(
          text: title.toUpperCase(),
          textAlign: TextAlign.start,
          color: AppColors.muted,
          type: AppTextType.bodyMedium,
          fontWeight: FontWeight.w800,
        ),
        const SizedBox(width: 14),
        const Expanded(child: Divider(color: Color(0xFFE2D9C9), thickness: 1)),
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
        const AppText(
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
        const Expanded(child: Divider(color: Color(0xFFE2D9C9), thickness: 1)),
      ],
    );
  }
}
