import 'dart:async';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/home/presentation/screen/meetings_screen.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/meeting_provider.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/today_visit_page.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/state_model/today_run_state.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/more_screens.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// How long before a visit starts the reminder card appears.
const _reminderLeadMins = 30;

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenVisits;

  const HomeScreen({super.key, this.onOpenVisits});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // Keep "Starts in 27 min" honest.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    // Feeds the bell badge in the app bar.
    Future.microtask(_loadNotifications);
  }

  Future<void> _loadNotifications() async {
    try {
      await ref
          .read(notificationControllerProvider.notifier)
          .getAllNotificationExploreData();
    } catch (_) {
      // Offline or signed out: the bell just shows no badge.
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  String get _firstName {
    final name = globals.userName.trim();
    return name.isEmpty ? 'there' : name.split(' ').first;
  }

  void _openVisit(TodayVisit v) =>
      navigateToRoute(context, TodayVisitPage(visit: v));

  Future<void> _clockIn(TodayVisit v) async {
    final details = await showClockInSheet(
      context,
      preferred: v.preferred,
      start: v.start,
      clientLatitude: v.latitude,
      clientLongitude: v.longitude,
    );
    if (details == null || !mounted) return;
    late final bool recorded;
    try {
      recorded = await ref
          .read(visitControllerProvider.notifier)
          .clockIn(v, details);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }
    if (!recorded || !mounted) return;
    _openVisit(v);
  }

  void _runningLate(TodayVisit v) {
    displayBottomSheet(context, _RunningLateSheet(visit: v));
  }

  void _reportIncident(TodayVisit v) => navigateToRoute(
    context,
    IncidentReportScreen(initialClientId: v.clientId),
  );

  Future<void> _callOffice() async {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: AppText(
          text:
              'The office telephone number is not supplied by the mobile API. Use Messages to contact the office.',
          type: AppTextType.bodySmall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final run = ref.watch(todayRunProvider);
    final handover = ref.watch(handoverProvider);
    final visits =
        (ref.watch(visitControllerProvider).value?.visits ??
                const <TodayVisit>[])
            .where((visit) => DateUtils.isSameDay(visit.start, now))
            .toList();
    final focus = run.focus(visits, now);
    final meeting = meetingToday(
      ref.watch(meetingsProvider).value?.meetings ?? const <TeamMeeting>[],
    );

    final reminder =
        focus != null &&
            run.stateOf(focus, now) == TodayVisitState.upcoming &&
            _minsUntil(focus.start, now) <= _reminderLeadMins
        ? focus
        : null;

    final care = visits.fold<int>(0, (n, v) => n + v.minutes);
    final travel = visits.fold<int>(0, (n, v) => n + v.travelMins);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Masthead(name: _firstName, now: now),
                  Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 46,
                        child: ColoredBox(color: AppColors.navy),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Hero(
                              visit: focus,
                              run: run,
                              now: now,
                              anyToday: visits.isNotEmpty,
                              onTap: focus == null
                                  ? null
                                  : () => _openVisit(focus),
                            ),
                            if (focus != null) ..._actions(focus, run, now),
                            if (reminder != null) ...[
                              addVerticalSpacing(1.66),
                              _ReminderCard(
                                visit: reminder,
                                handoverNotes: handover.unreadFor(
                                  reminder.clientId,
                                ),
                                minutes: _minsUntil(
                                  reminder.start,
                                  now,
                                ).clamp(1, 999),
                                onOpen: () => _openVisit(reminder),
                              ),
                            ],
                            if (meeting != null) ...[
                              addVerticalSpacing(1.66),
                              _MeetingNotice(meeting: meeting),
                            ],
                            addVerticalSpacing(3.08),
                            AppText(
                              text: "Today's visits",
                              type: AppTextType.bodySmall,
                              fontFamily: 'Playfair Display',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.4,
                              color: AppColors.ink,
                            ),
                            addVerticalSpacing(1.66),
                            if (visits.isEmpty)
                              _NoVisits(onOpenRota: widget.onOpenVisits)
                            else ...[
                              AppText(
                                text:
                                    '${_plural(visits.length, 'visit', 'visits')}, ${formatMinutes(care)} of care${travel > 0 ? ', ${formatMinutes(travel)} travel' : ''}.',
                                type: AppTextType.bodySmall,
                                color: AppColors.muted,
                                fontSize: 16,
                              ),
                              addVerticalSpacing(1.66),
                              for (var i = 0; i < visits.length; i++) ...[
                                if (i > 0)
                                  _TravelGap(minutes: visits[i].travelMins),
                                _VisitRow(
                                  visit: visits[i],
                                  state: run.stateOf(visits[i], now),
                                  newHandover:
                                      handover.unreadFor(visits[i].clientId) >
                                      0,
                                  onTap: () => _openVisit(visits[i]),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clock in, running late and call the office, under the hero card.
  List<Widget> _actions(TodayVisit v, TodayRun run, DateTime now) {
    final state = run.stateOf(v, now);
    final timing = ClockInTiming(start: v.start, now: now);
    final canClock =
        (state == TodayVisitState.upcoming ||
            state == TodayVisitState.due ||
            state == TodayVisitState.overdue) &&
        timing.isOpen;
    final canLate =
        (state == TodayVisitState.upcoming ||
            state == TodayVisitState.due ||
            state == TodayVisitState.overdue) &&
        v.end.isAfter(now);

    return [
      if (canClock) ...[
        addVerticalSpacing(1.42),
        DesignButton(
          'Clock in to ${v.preferred}',
          icon: Icons.access_time,
          onPressed: () => _clockIn(v),
        ),
      ],
      addVerticalSpacing(1.18),
      Row(
        children: [
          Expanded(
            child: DesignButton(
              canLate ? 'Running late' : 'Report incident',
              secondary: true,
              icon: canLate ? Icons.access_time : Icons.warning_amber_rounded,
              onPressed: canLate
                  ? () => _runningLate(v)
                  : () => _reportIncident(v),
            ),
          ),
          addHorizontalSpacing(2.56),
          Expanded(
            child: DesignButton(
              'Call the office',
              secondary: true,
              icon: Icons.phone_outlined,
              onPressed: _callOffice,
            ),
          ),
        ],
      ),
    ];
  }
}

String _plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// Greeting and date under the app bar (design `.masthead`).
class _Masthead extends StatelessWidget {
  final String name;
  final DateTime now;

  const _Masthead({required this.name, required this.now});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: '${greeting().replaceAll(',', '')}, $name',
            type: AppTextType.displayMedium,
            fontFamily: 'Playfair Display',
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.2,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: DateFormat('EEEE d MMMM').format(now),
            type: AppTextType.bodySmall,
            color: AppColors.brandMuted,
            fontSize: 18,
          ),
        ],
      ),
    );
  }
}

/// The "Your next visit" card (design `.hero`): gold edge on the left,
/// green while a visit is in progress.
class _Hero extends StatelessWidget {
  final TodayVisit? visit;
  final TodayRun run;
  final DateTime now;
  final bool anyToday;
  final VoidCallback? onTap;

  const _Hero({
    required this.visit,
    required this.run,
    required this.now,
    required this.anyToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final v = visit;
    final state = v == null ? null : run.stateOf(v, now);
    final live = state == TodayVisitState.active;
    final clockedAt = v == null ? null : run.clockedIn[v.id];

    final String label;
    final String title;
    final String line;
    String? note;
    final pills = <Widget>[];

    if (v == null) {
      label = 'Your next visit';
      title = anyToday ? 'All done for today' : 'Nothing planned';
      line = anyToday
          ? 'Thank you. Your visits are recorded.'
          : 'Check the rota or the open shifts.';
    } else if (live) {
      label = 'Visit in progress';
      title = v.preferred;
      line = 'Clocked in at ${hhmm(clockedAt ?? now)}';
      pills.add(
        Pill.ok(
          '${run.completedTaskCount(v.id)} of ${v.tasks.length} tasks done',
        ),
      );
      pills.add(
        Pill.info(
          '${formatMinutes(now.difference(clockedAt ?? now).inMinutes)} so far',
        ),
      );
    } else {
      label = 'Your next visit';
      title = v.preferred;
      line = '${hhmm(v.start)} to ${hhmm(v.end)}, ${v.address}';
      final leave = v.start.subtract(Duration(minutes: v.travelMins));
      if (v.travelMins > 0 && leave.isAfter(now)) {
        note =
            'Leave by ${hhmm(leave)} (${formatMinutes(v.travelMins)} travel)';
      }
      pills.add(
        state == TodayVisitState.overdue
            ? Pill.bad('Not recorded')
            : Pill.gold(
                !v.start.isAfter(now)
                    ? 'Due now'
                    : 'Starts in ${formatMinutes(_minsUntil(v.start, now))}',
              ),
      );
    }

    final edge = live ? AppColors.sage : AppColors.gold;

    return Semantics(
      button: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x240A142D),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 1, 1, 1),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
              topRight: Radius.circular(19),
              bottomRight: Radius.circular(19),
            ),
            child: Material(
              color: AppColors.surface,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: edge, width: 5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: label,
                        type: AppTextType.bodySmall,
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                      addVerticalSpacing(0.24),
                      AppText(
                        text: title,
                        type: AppTextType.bodySmall,
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 25.6,
                        height: 1.2,
                        color: AppColors.ink,
                      ),
                      addVerticalSpacing(0.24),
                      AppText(
                        text: line,
                        type: AppTextType.bodySmall,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: AppColors.ink,
                      ),
                      if (note != null)
                        AppText(
                          text: note,
                          type: AppTextType.bodySmall,
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      if (pills.isNotEmpty) ...[
                        addVerticalSpacing(1.18),
                        Wrap(spacing: 6, runSpacing: 6, children: pills),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int _minsUntil(DateTime t, DateTime now) =>
    (t.difference(now).inSeconds / 60).ceil();

/// A reminder for the next live rota visit.
class _ReminderCard extends StatelessWidget {
  final TodayVisit visit;
  final int handoverNotes;
  final int minutes;
  final VoidCallback onOpen;

  const _ReminderCard({
    required this.visit,
    required this.handoverNotes,
    required this.minutes,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final v = visit;
    final alerts = v.thingsToKnow.length;
    final parts = <String>[_plural(v.tasks.length, 'task', 'tasks')];
    if (alerts > 0) {
      parts.add(_plural(alerts, 'thing to know', 'things to know'));
    }
    if (handoverNotes > 0) {
      parts.add(
        _plural(handoverNotes, 'new handover note', 'new handover notes'),
      );
    }
    final fg = AppColors.info;

    Widget count(IconData icon, int n) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: fg),
        addHorizontalSpacing(1.54),
        AppText(
          text: '$n',
          type: AppTextType.bodySmall,
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ],
    );

    return _NoticeShell(
      bg: AppColors.infoBg,
      fg: fg,
      icon: Icons.access_time,
      children: [
        AppText(
          text: '${v.name}: starts in ${formatMinutes(minutes)}',
          type: AppTextType.bodySmall,
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        addVerticalSpacing(0.71),
        Wrap(
          spacing: 18,
          children: [
            count(Icons.warning_amber_rounded, alerts),
            count(Icons.check, v.tasks.length),
            count(Icons.description_outlined, handoverNotes),
          ],
        ),
        addVerticalSpacing(0.71),
        AppText(
          text: '${parts.join(', ')}.',
          type: AppTextType.bodySmall,
          color: fg,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        addVerticalSpacing(1.18),
        DesignButton('Open the visit', small: true, onPressed: onOpen),
      ],
    );
  }
}

class _MeetingNotice extends StatelessWidget {
  final TeamMeeting meeting;

  const _MeetingNotice({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final live = meeting.isLive;
    final fg = live ? AppColors.sage : AppColors.info;
    return _NoticeShell(
      bg: live ? AppColors.sageBg : AppColors.infoBg,
      fg: fg,
      icon: Icons.groups_outlined,
      children: [
        AppText(
          text: live
              ? 'A team meeting is on now: ${meeting.title}'
              : 'Team meeting today at ${hhmm(meeting.start)}: ${meeting.title}',
          type: AppTextType.bodySmall,
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        addVerticalSpacing(1.18),
        DesignButton(
          live ? 'Listen now' : 'Open meeting',
          small: true,
          onPressed: () =>
              navigateToRoute(context, MeetingDetailsScreen(meeting: meeting)),
        ),
      ],
    );
  }
}

/// Coloured box with a leading icon (design `.notice`).
class _NoticeShell extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final List<Widget> children;

  const _NoticeShell({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, color: fg, size: 22),
          ),
          addHorizontalSpacing(2.56),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoVisits extends StatelessWidget {
  final VoidCallback? onOpenRota;

  const _NoVisits({required this.onOpenRota});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line2, width: 1.5),
      ),
      child: Column(
        children: [
          AppText(
            text: 'No visits today',
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: 'Nothing is planned for you yet.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
          ),
          addVerticalSpacing(1.66),
          DesignButton('Open the rota', small: true, onPressed: onOpenRota),
        ],
      ),
    );
  }
}

/// "12 min travel" between two visits (design `.travel`).
class _TravelGap extends StatelessWidget {
  final int minutes;

  const _TravelGap({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 0, 6),
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
            text: minutes > 0 ? '${formatMinutes(minutes)} travel' : '',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

/// One row of today's round (design `.visit`).
class _VisitRow extends StatelessWidget {
  final TodayVisit visit;
  final TodayVisitState state;
  final bool newHandover;
  final VoidCallback onTap;

  const _VisitRow({
    required this.visit,
    required this.state,
    required this.newHandover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final v = visit;
    final finished = state == TodayVisitState.done;
    final statePill = switch (state) {
      TodayVisitState.done => Pill.ok('Done'),
      TodayVisitState.active => Pill.info('In progress'),
      TodayVisitState.overdue => Pill.bad('Not recorded'),
      TodayVisitState.due => Pill.gold('Due now'),
      TodayVisitState.upcoming => null,
    };
    final showHandover =
        newHandover &&
        state != TodayVisitState.done &&
        state != TodayVisitState.overdue;

    return Material(
      color: finished ? AppColors.bg : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
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
                    AppText(
                      text: hhmm(v.start),
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.25,
                      color: AppColors.ink,
                    ),
                    AppText(
                      text: formatMinutes(v.minutes),
                      type: AppTextType.bodySmall,
                      fontSize: 12.8,
                      height: 1.25,
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
                      text: v.preferred,
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                    AppText(
                      text: v.address,
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    if (v.withStaff.isNotEmpty)
                      AppText(
                        text: 'With ${v.withStaff}',
                        type: AppTextType.bodySmall,
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                  ],
                ),
              ),
              if (statePill != null || showHandover) ...[
                addHorizontalSpacing(3.08),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ?statePill,
                    if (statePill != null && showHandover)
                      addVerticalSpacing(0.47),
                    if (showHandover) Pill.gold('New handover'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RunningLateSheet extends ConsumerStatefulWidget {
  final TodayVisit visit;

  const _RunningLateSheet({required this.visit});

  @override
  ConsumerState<_RunningLateSheet> createState() => _RunningLateSheetState();
}

class _RunningLateSheetState extends ConsumerState<_RunningLateSheet> {
  static const _choices = ['10 min', '20 min', '30 min', '45 min', '1 hour'];

  final _reason = TextEditingController();
  String? _eta;
  bool _showError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_eta == null) {
      setState(() => _showError = true);
      return;
    }
    try {
      await ref
          .read(visitControllerProvider.notifier)
          .reportIssue(
            widget.visit.id,
            issueType: 'Running late',
            details: [
              'Expected delay: $_eta.',
              if (_reason.text.trim().isNotEmpty) _reason.text.trim(),
            ].join(' '),
          );
    } catch (e) {
      if (mounted) {
        setState(() => _showError = true);
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.pop(context);
    messenger?.showSnackBar(
      SnackBar(
        content: AppText(
          text:
              'The office knows you will be about ${_eta == '1 hour' ? '60 minutes' : _eta} late.',
          type: AppTextType.bodySmall,
        ),
      ),
    );
  }

  Future<void> _callClient() async {
    final uri = Uri(
      scheme: 'tel',
      path: widget.visit.phone.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Running late',
              type: AppTextType.bodySmall,
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.ink,
            ),
            addVerticalSpacing(0.95),
            AppText(
              text:
                  'This tells the office. Please also let ${widget.visit.preferred} know if you can.',
              type: AppTextType.bodySmall,
              color: AppColors.muted,
              fontSize: 16,
              height: 1.4,
            ),
            addVerticalSpacing(2.13),
            AppText(
              text: 'How late will you be?',
              type: AppTextType.bodySmall,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
            addVerticalSpacing(0.95),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final choice in _choices)
                  ChoiceChip(
                    label: AppText(text: choice, type: AppTextType.bodySmall),
                    selected: _eta == choice,
                    onSelected: (_) => setState(() {
                      _eta = choice;
                      _showError = false;
                    }),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: _eta == choice
                          ? AppColors.primary
                          : AppColors.line2,
                      width: 1.5,
                    ),
                    labelStyle: TextStyle(
                      color: _eta == choice
                          ? AppColors.onPrimary
                          : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                  ),
              ],
            ),
            if (_showError) ...[
              addVerticalSpacing(0.71),
              AppText(
                text: 'Choose how late you will be.',
                type: AppTextType.bodySmall,
                color: AppColors.rose,
                fontWeight: FontWeight.w600,
              ),
            ],
            addVerticalSpacing(1.90),
            GlobalTextField(
              fieldName: 'Reason (optional)',
              hintText: 'For example: traffic on the A14',
              keyBoardType: TextInputType.text,
              textController: _reason,
              maxLength: 120,
              isOptional: true,
              removeSpace: false,
              textCapitalization: TextCapitalization.sentences,
            ),
            addVerticalSpacing(1.42),
            Row(
              children: [
                Expanded(
                  child: DesignButton('Tell the office', onPressed: _submit),
                ),
                addHorizontalSpacing(2.56),
                Expanded(
                  child: DesignButton(
                    'Call ${widget.visit.preferred}',
                    secondary: true,
                    icon: Icons.phone_outlined,
                    onPressed: _callClient,
                  ),
                ),
              ],
            ),
            addVerticalSpacing(0.95),
            AppText(
              text: '${widget.visit.preferred}: ${widget.visit.phone}',
              type: AppTextType.bodySmall,
              color: AppColors.muted,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}
