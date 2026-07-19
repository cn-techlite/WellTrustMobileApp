// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/screen/open_visit_page.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/add_note_bottom_sheet.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/chat_message_widget.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/end_of_day_display_sheet.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/profile_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/quick_actions.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/raise_cocerns_bottomshet.dart';
import 'package:well_trust_mobile_app/features/home_screen.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/visit_details_screen.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/sheduled_visit_card.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_card.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_providers.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/visit_state_model.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/list_tile_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  String userPhone = "";
  String profilePicture = "";
  String allNames = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(accountControllerProvider.notifier).getAccount();

      final user = ref.read(accountControllerProvider).value?.userData;

      profilePicture = user?.profilePicture ?? globals.profilePicture;
      userPhone = user?.phoneNo ?? "";
      allNames =
          "${user?.firstName ?? globals.userName} ${user?.lastName ?? ""}"
              .trim();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitAsync = ref.watch(visitControllerProvider);
    // final state = ref.watch(visitControllerProvider.notifier);
    final visitState = visitAsync.value ?? const VisitState(visits: []);
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
                          text: greeting(),
                          textAlign: TextAlign.start,
                          color: AppColors.muted,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w500,
                        ),

                        const AppText(
                          text: "Chigozie",
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      displayBottomSheet(context, ProfileBottomSheet());
                    },
                    child: Container(
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
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(5),

                      _ShiftCard(state: visitState),

                      addVerticalSpacing(5),

                      SectionHead(
                        visitState.currentVisit != null
                            ? 'Visit in progress'
                            : 'Next visit',
                      ),
                      addVerticalSpacing(2),
                      ActiveVisitCard(
                        startedTime: '12:04',
                        elapsedTime: '8:00',
                        clientName: "Maeve O'Connor",
                        address: '11 Rosedale Walk, Burton Latimer NN15 5XB',
                        tasks: const [
                          'Lunch prep',
                          'Eating support',
                          'Lunch meds',
                          'Toilet',
                          'Bin out',
                        ],
                        onTap: () {
                          navigateToRoute(context, OpenVisitDetailsPage());
                        },
                      ),

                      addVerticalSpacing(2),

                      SectionHead(
                        "Coming Up",
                        trailing: GestureDetector(
                          onTap: () {
                            navigateToRoute(context, HomeScreenPage(imdex: 1));
                          },
                          child: const AppText(
                            text: "All Visit →",
                            textAlign: TextAlign.end,
                            color: AppColors.ink2,
                            type: AppTextType.bodyMedium,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      addVerticalSpacing(2),
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
                        startTime: '13:30',
                        endTime: '14:00',
                        duration: 30,
                        initials: 'TK',
                        clientName: 'Tadeusz Kowalski',
                        address: '29 Cedar Close',
                        visitType: '🍽 Lunch call',
                        tasks: const [
                          'Lunch prompt',
                          'Wound check (hip)',
                          'Lunch meds',
                        ],
                      ),

                      ScheduledVisitCard(
                        startTime: '14:30',
                        endTime: '15:00',
                        duration: 30,
                        initials: 'EH',
                        clientName: 'Edna Henderson',
                        address: '8 Mill Cottages',
                        visitType: '👋 Welfare check',
                        tasks: const [
                          'Welfare check',
                          'Toilet',
                          'Fluids',
                          'Change of position',
                        ],
                      ),

                      addVerticalSpacing(2),
                      SectionHead("Quick Actions"),

                      Row(
                        children: [
                          Expanded(
                            child: QuickActionButton(
                              icon: "📝",
                              title: "Add note",
                              onTap: () {
                                displayBottomSheet(
                                  context,
                                  AddCareNoteBottomSheet(),
                                );
                              },
                            ),
                          ),
                          addHorizontalSpacing(2),
                          Expanded(
                            child: QuickActionButton(
                              icon: "🚩",
                              title: "Raise concern",
                              onTap: () {
                                displayBottomSheet(
                                  context,
                                  RaiseConcernBottomSheet(),
                                );
                              },
                            ),
                          ),
                          addHorizontalSpacing(2),
                          Expanded(
                            child: QuickActionButton(
                              icon: "💬",
                              title: "Messages",
                              onTap: () {
                                displayBottomSheet(
                                  context,
                                  MessagesBottomSheet(),
                                );
                              },
                            ),
                          ),
                          addHorizontalSpacing(2),
                          Expanded(
                            child: QuickActionButton(
                              icon: "🗓",
                              title: "Visits",
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  HomeScreenPage(imdex: 1),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      addVerticalSpacing(1),
                      SectionHead("Todays So Far"),
                      Row(
                        children: [
                          Expanded(
                            child: StatBox(value: "4", label: "DONE"),
                          ),
                          addHorizontalSpacing(2),
                          Expanded(
                            child: StatBox(value: "8", label: "TO GO"),
                          ),
                          addHorizontalSpacing(2),
                          Expanded(
                            child: StatBox(value: "0", label: "MY NOTES"),
                          ),
                        ],
                      ),
                      addVerticalSpacing(5),
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

class _ShiftCard extends ConsumerWidget {
  final VisitState state;

  const _ShiftCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = state.isClockedIn;
    final total = state.visits.length;
    final hours = (state.totalScheduledMins / 60 * 10).round() / 10;

    String summary;
    String progress;

    if (on) {
      final since = state.clockedInAt == null
          ? '—'
          : '${state.clockedInAt!.hour.toString().padLeft(2, '0')}:${state.clockedInAt!.minute.toString().padLeft(2, '0')}';

      summary = 'Started $since · $total visits · ${hours}h';
      progress =
          '${state.visitsDone} done · ${state.visitsInProgress > 0 ? '1 in progress · ' : ''}${state.visitsToGo} to go';
    } else {
      summary = '$total visits · ${hours}h scheduled';
      progress = state.visitsDone > 0
          ? '${state.visitsDone} done · ${state.visitsToGo} to go'
          : 'Not started';
    }

    return Container(
      //margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyDeep, AppColors.navyDeepest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (on)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x2EFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulseDot(),
                  const SizedBox(width: 6),
                  AppText(
                    text: 'ON ROUND',
                    color: Colors.white,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            )
          else
            const AppText(
              text: 'YOUR ROTA TODAY',
              color: Color(0xCCFFFFFF),
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w700,
            ),

          addVerticalSpacing(1),

          AppText(
            text: summary,
            color: Colors.white,
            type: AppTextType.bodyMedium,
            fontWeight: FontWeight.w600,
          ),

          addVerticalSpacing(1),

          AppText(
            text: progress,
            color: const Color(0xCCFFFFFF),
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w500,
          ),

          addVerticalSpacing(1),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: on ? '⏱ End of day' : '⏱ Start of day',
                  onPressed: () {
                    displayBottomSheet(context, EndOfDaySummarySheet());
                  },
                  widthPercent: 100,
                  heightPercent: 6,
                  fontSize: 18,
                  btnColor: AppColors.gold,
                  isLoading: false,
                ),
              ),
              addHorizontalSpacing(2),
              Expanded(
                child: AppButton(
                  text: "Full Schedule",
                  onPressed: () {
                    navigateToRoute(context, HomeScreenPage(imdex: 1));
                  },
                  widthPercent: 100,
                  heightPercent: 6,
                  fontSize: 18,
                  btnColor: AppColors.darkBlue,
                  isLoading: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_c),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color(0xFF9FED8A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
