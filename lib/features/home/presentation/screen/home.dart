import 'dart:async';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/provider/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/screen/meetings_screen.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/today_visit_page.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/report_incident_bottomsheet.dart';
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
    final recorded = ref
        .read(todayRunProvider.notifier)
        .clockIn(v.id, details: details);
    if (!recorded || !mounted) return;
    _openVisit(v);
  }

  void _runningLate(TodayVisit v) {
    displayBottomSheet(context, _RunningLateSheet(visit: v));
  }

  void _reportIncident(TodayVisit v) => displayBottomSheet(
    context,
    ReportIncidentBottomSheet(initialClient: v.name),
  );

  Future<void> _callOffice() async {
    final uri = Uri(scheme: 'tel', path: sampleOfficePhone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Unable to open the phone app.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final run = ref.watch(todayRunProvider);
    final handover = ref.watch(handoverProvider);
    final visits = todayVisits;
    final focus = run.focus(visits, now);
    final meeting = meetingToday();

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
                              const SizedBox(height: 14),
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
                              const SizedBox(height: 14),
                              _MeetingNotice(meeting: meeting),
                            ],
                            const SizedBox(height: 26),
                            Text(
                              "Today's visits",
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontWeight: FontWeight.w700,
                                fontSize: 18.4,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (visits.isEmpty)
                              _NoVisits(onOpenRota: widget.onOpenVisits)
                            else ...[
                              Text(
                                '${_plural(visits.length, 'visit', 'visits')}, ${formatMinutes(care)} of care${travel > 0 ? ', ${formatMinutes(travel)} travel' : ''}.',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 14),
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
        const SizedBox(height: 12),
        DesignButton(
          'Clock in to ${v.preferred}',
          icon: Icons.access_time,
          onPressed: () => _clockIn(v),
        ),
      ],
      const SizedBox(height: 10),
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
          const SizedBox(width: 10),
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
          Text(
            '${greeting().replaceAll(',', '')}, $name',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE d MMMM').format(now),
            style: TextStyle(color: AppColors.brandMuted, fontSize: 18),
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
                      Text(
                        label,
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w700,
                          fontSize: 25.6,
                          height: 1.2,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        line,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: AppColors.ink,
                        ),
                      ),
                      if (note != null)
                        Text(
                          note,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      if (pills.isNotEmpty) ...[
                        const SizedBox(height: 10),
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

/// "Mr Harold Fisher: starts in 27 min" (design `.notice.info.reminder`).
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
        const SizedBox(width: 6),
        Text(
          '$n',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );

    return _NoticeShell(
      bg: AppColors.infoBg,
      fg: fg,
      icon: Icons.access_time,
      children: [
        Text(
          '${v.name}: starts in ${formatMinutes(minutes)}',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 18,
          children: [
            count(Icons.warning_amber_rounded, alerts),
            count(Icons.check, v.tasks.length),
            count(Icons.description_outlined, handoverNotes),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${parts.join(', ')}.',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
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
        Text(
          live
              ? 'A team meeting is on now: ${meeting.title}'
              : 'Team meeting today at ${hhmm(meeting.start)}: ${meeting.title}',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
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
          const SizedBox(width: 10),
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
          Text(
            'No visits today',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Nothing is planned for you yet.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(width: 8),
          Text(
            minutes > 0 ? '${formatMinutes(minutes)} travel' : '',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
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
                    Text(
                      hhmm(v.start),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.25,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      formatMinutes(v.minutes),
                      style: TextStyle(
                        fontSize: 12.8,
                        height: 1.25,
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
                      v.preferred,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      v.address,
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                    if (v.withStaff.isNotEmpty)
                      Text(
                        'With ${v.withStaff}',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                  ],
                ),
              ),
              if (statePill != null || showHandover) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ?statePill,
                    if (statePill != null && showHandover)
                      const SizedBox(height: 4),
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

class _RunningLateSheet extends StatefulWidget {
  final TodayVisit visit;

  const _RunningLateSheet({required this.visit});

  @override
  State<_RunningLateSheet> createState() => _RunningLateSheetState();
}

class _RunningLateSheetState extends State<_RunningLateSheet> {
  static const _choices = ['10 min', '20 min', '30 min', '45 min', '1 hour'];

  final _reason = TextEditingController();
  String? _eta;
  bool _showError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_eta == null) {
      setState(() => _showError = true);
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.pop(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          'The office knows you will be about ${_eta == '1 hour' ? '60 minutes' : _eta} late.',
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
            Text(
              'Running late',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This tells the office. Please also let ${widget.visit.preferred} know if you can.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'How late will you be?',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final choice in _choices)
                  ChoiceChip(
                    label: Text(choice),
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
              const SizedBox(height: 6),
              Text(
                'Choose how late you will be.',
                style: TextStyle(
                  color: AppColors.rose,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'For example: traffic on the A14',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.line2, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.line2, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DesignButton('Tell the office', onPressed: _submit),
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 8),
            Text(
              '${widget.visit.preferred}: ${widget.visit.phone}',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
