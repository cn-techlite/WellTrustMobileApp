import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/today_visit_page.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/today_run_state.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/sheduled_visit_card.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  int _weekOffset = 0;
  late DateTime _selectedDay = _dateOnly(DateTime.now());
  final Map<String, GlobalKey> _dayKeys = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(visitControllerProvider.notifier)
          .refresh(
            from: _weekStart,
            to: _weekStart.add(const Duration(days: 7)),
          );
    });
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _mondayOf(DateTime date) =>
      _dateOnly(date).subtract(Duration(days: date.weekday - 1));

  DateTime get _weekStart =>
      _mondayOf(DateTime.now()).add(Duration(days: _weekOffset * 7));

  List<DateTime> get _weekDays =>
      List.generate(7, (index) => _weekStart.add(Duration(days: index)));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final run = ref.watch(todayRunProvider);
    final handover = ref.watch(handoverProvider);
    final entries = [
      for (final visit
          in ref.watch(visitControllerProvider).value?.visits ??
              const <TodayVisit>[])
        _RotaEntry(visit),
    ];
    final weekEntries = entries
        .where(
          (entry) =>
              !entry.visit.start.isBefore(_weekStart) &&
              entry.visit.start.isBefore(
                _weekStart.add(const Duration(days: 7)),
              ),
        )
        .toList();
    final careMinutes = weekEntries.fold<int>(
      0,
      (total, entry) => total + entry.visit.minutes,
    );
    final travelMinutes = weekEntries.fold<int>(
      0,
      (total, entry) => total + entry.visit.travelMins,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Visits (Rota)'),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: [
                  _WeekNavigation(
                    start: _weekStart,
                    isCurrentWeek: _weekOffset == 0,
                    onPrevious: () => _changeWeek(-1),
                    onNext: () => _changeWeek(1),
                    onCurrent: () => _setCurrentWeek(now),
                  ),
                  addVerticalSpacing(1.66),
                  AppText(
                    text:
                        'Set by management and loaded from the live rota. You cannot edit the rota. Use the buttons on a visit to tell the office about a problem.',
                    type: AppTextType.labelLarge,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                  addVerticalSpacing(1.66),
                  _DayStrip(
                    days: _weekDays,
                    selected: _selectedDay,
                    visitsOn: (day) => _forDay(weekEntries, day).length,
                    onSelected: (day) => _selectDay(day),
                  ),
                  if (weekEntries.isNotEmpty) ...[
                    addVerticalSpacing(1.66),
                    _WeekSummary(
                      careMinutes: careMinutes,
                      travelMinutes: travelMinutes,
                    ),
                  ],
                  if (weekEntries.isEmpty) ...[
                    addVerticalSpacing(2.37),
                    _EmptyWeek(isPast: _weekStart.isBefore(_mondayOf(now))),
                  ] else
                    for (final day in _weekDays)
                      if (_showDay(day, weekEntries, now)) ...[
                        addVerticalSpacing(2.61),
                        KeyedSubtree(
                          key: _keyFor(day),
                          child: _DaySection(
                            day: day,
                            entries: _forDay(weekEntries, day),
                            now: now,
                            run: run,
                            unreadFor: handover.unreadFor,
                            onVisit: (visit) => navigateToRoute(
                              context,
                              TodayVisitPage(visit: visit),
                            ),
                          ),
                        ),
                      ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeWeek(int amount) {
    setState(() {
      _weekOffset += amount;
      _selectedDay = _weekStart;
    });
    ref
        .read(visitControllerProvider.notifier)
        .refresh(from: _weekStart, to: _weekStart.add(const Duration(days: 7)));
  }

  void _setCurrentWeek(DateTime now) {
    setState(() {
      _weekOffset = 0;
      _selectedDay = _dateOnly(now);
    });
    ref
        .read(visitControllerProvider.notifier)
        .refresh(from: _weekStart, to: _weekStart.add(const Duration(days: 7)));
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keyFor(day).currentContext;
      if (target == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AppText(
              text: 'No visits that day.',
              type: AppTextType.bodySmall,
            ),
          ),
        );
        return;
      }
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: .05,
      );
    });
  }

  GlobalKey _keyFor(DateTime day) =>
      _dayKeys.putIfAbsent(DateFormat('yyyy-MM-dd').format(day), GlobalKey.new);

  List<_RotaEntry> _forDay(List<_RotaEntry> entries, DateTime day) =>
      entries.where((entry) => _sameDay(entry.visit.start, day)).toList();

  bool _showDay(DateTime day, List<_RotaEntry> entries, DateTime now) {
    final hasVisits = _forDay(entries, day).isNotEmpty;
    return hasVisits || !day.isBefore(_dateOnly(now));
  }
}

class _RotaEntry {
  final TodayVisit visit;

  const _RotaEntry(this.visit);
}

class _WeekNavigation extends StatelessWidget {
  final DateTime start;
  final bool isCurrentWeek;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCurrent;

  const _WeekNavigation({
    required this.start,
    required this.isCurrentWeek,
    required this.onPrevious,
    required this.onNext,
    required this.onCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final end = start.add(const Duration(days: 6));
    return Row(
      children: [
        _WeekArrow(
          icon: Icons.arrow_back_rounded,
          label: 'Previous week',
          onPressed: onPrevious,
        ),
        Expanded(
          child: Column(
            children: [
              AppText(
                text:
                    '${DateFormat('d MMM').format(start)} to ${DateFormat('d MMM yyyy').format(end)}',
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                textAlign: TextAlign.center,
              ),
              if (isCurrentWeek)
                AppText(
                  text: 'This week',
                  type: AppTextType.labelLarge,
                  color: AppColors.muted,
                )
              else
                AppButton(
                  text: 'Back to this week',
                  expand: false,
                  btnColor: Colors.transparent,
                  textColor: AppColors.info,
                  onPressed: onCurrent,
                ),
            ],
          ),
        ),
        _WeekArrow(
          icon: Icons.arrow_forward_rounded,
          label: 'Next week',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _WeekArrow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _WeekArrow({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton.outlined(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.ink,
            side: BorderSide(color: AppColors.line2, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon, size: 21),
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selected;
  final int Function(DateTime day) visitsOn;
  final ValueChanged<DateTime> onSelected;

  const _DayStrip({
    required this.days,
    required this.selected,
    required this.visitsOn,
    required this.onSelected,
  });

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                button: true,
                label:
                    '${DateFormat('EEEE d MMMM').format(day)}, ${visitsOn(day)} visits',
                child: InkWell(
                  onTap: () => onSelected(day),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: _sameDay(day, today)
                          ? AppColors.goldBg
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _sameDay(day, today) || _sameDay(day, selected)
                            ? AppColors.gold
                            : AppColors.line,
                        width: _sameDay(day, selected) ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: DateFormat('E').format(day).substring(0, 1),
                          type: AppTextType.labelMedium,
                          color: AppColors.muted,
                        ),
                        AppText(
                          text: '${day.day}',
                          type: AppTextType.bodySmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: visitsOn(day) > 0
                                ? AppColors.gold
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekSummary extends StatelessWidget {
  final int careMinutes;
  final int travelMinutes;

  const _WeekSummary({required this.careMinutes, required this.travelMinutes});

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: AppText(
        text:
            'This week: ${formatMinutes(careMinutes)} of care and ${formatMinutes(travelMinutes)} travel',
        type: AppTextType.bodySmall,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<_RotaEntry> entries;
  final DateTime now;
  final TodayRun run;
  final int Function(String clientId) unreadFor;
  final ValueChanged<TodayVisit> onVisit;

  const _DaySection({
    required this.day,
    required this.entries,
    required this.now,
    required this.run,
    required this.unreadFor,
    required this.onVisit,
  });

  bool get _isToday =>
      day.year == now.year && day.month == now.month && day.day == now.day;

  @override
  Widget build(BuildContext context) {
    final care = entries.fold<int>(
      0,
      (total, entry) => total + entry.visit.minutes,
    );
    final travel = entries.fold<int>(
      0,
      (total, entry) => total + entry.visit.travelMins,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            AppText(
              text: DateFormat('EEEE d MMMM').format(day),
              type: AppTextType.titleSmall,
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            if (_isToday) Pill.gold('Today'),
          ],
        ),
        if (entries.isEmpty) ...[
          addVerticalSpacing(0.95),
          AppText(
            text: 'No visits.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
          ),
        ] else ...[
          addVerticalSpacing(0.95),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill.neutral('${entries.length} visits'),
              Pill.neutral('${formatMinutes(care)} care'),
              if (travel > 0) Pill.neutral('${formatMinutes(travel)} travel'),
              Pill.neutral(
                '${hhmm(entries.first.visit.start)} to ${hhmm(entries.last.visit.end)}',
              ),
            ],
          ),
          addVerticalSpacing(1.18),
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0 && entries[index].visit.travelMins > 0)
              TravelDivider(minutes: entries[index].visit.travelMins),
            _VisitRow(
              entry: entries[index],
              status: _statusOf(entries[index].visit),
              unreadHandover: unreadFor(entries[index].visit.clientId),
              onTap: () => onVisit(entries[index].visit),
            ),
          ],
        ],
      ],
    );
  }

  String _statusOf(TodayVisit visit) {
    if (!_isToday) return 'SCHEDULED';
    return switch (run.stateOf(visit, now)) {
      TodayVisitState.done => 'DONE',
      TodayVisitState.active => 'IN PROGRESS',
      TodayVisitState.overdue => 'MISSED',
      TodayVisitState.due => 'DUE NOW',
      TodayVisitState.upcoming => 'SCHEDULED',
    };
  }
}

class _VisitRow extends StatelessWidget {
  final _RotaEntry entry;
  final String status;
  final int unreadHandover;
  final VoidCallback onTap;

  const _VisitRow({
    required this.entry,
    required this.status,
    required this.unreadHandover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visit = entry.visit;
    return ScheduledVisitCard(
      startTime: hhmm(visit.start),
      duration: visit.minutes,
      clientName: visit.preferred,
      address: visit.address,
      withStaff: visit.withStaff,
      status: status,
      hasNewHandover: unreadHandover > 0,
      onTap: onTap,
    );
  }
}

class TravelDivider extends StatelessWidget {
  final int minutes;

  const TravelDivider({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 0, 8),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          addHorizontalSpacing(2.05),
          AppText(
            text: '${formatMinutes(minutes)} travel',
            type: AppTextType.labelLarge,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class _EmptyWeek extends StatelessWidget {
  final bool isPast;

  const _EmptyWeek({required this.isPast});

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, color: AppColors.muted, size: 30),
          addVerticalSpacing(0.95),
          AppText(
            text: 'No visits this week',
            type: AppTextType.titleSmall,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: isPast
                ? 'There are no recorded visits in this week.'
                : 'Nothing has been planned for you yet.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
