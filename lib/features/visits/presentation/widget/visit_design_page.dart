import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// The visit page from the design: header card, where, getting in, things to
/// know, care plan tasks, quick actions and the clock-in / finish actions.
class VisitDesignPage extends StatefulWidget {
  final String clientName;
  final String subtitle;
  final String dateTime;
  final String duration;
  final String address;
  final String phone;
  final String accessType;
  final String accessCode;
  final String accessNote;
  final List<String> thingsToKnow;
  final List<VisitTask> tasks;
  final Widget? handoverCard;
  final Set<int> initialCompletedTasks;
  final bool clockInEnabled;
  final String? clockInHint;

  /// True once the carer has clocked in.
  final bool started;
  final bool completed;
  final DateTime? startedAt;
  final String plannedLabel;

  /// The first name to use in the clock-in sheet; falls back to [clientName].
  final String? preferredName;

  /// The planned start, so the clock-in sheet can ask why they are early.
  final DateTime? plannedStart;

  /// The client's home, so the clock-in sheet can check the carer is nearby.
  final double? clientLatitude;
  final double? clientLongitude;

  /// Called with what the carer confirmed in the clock-in sheet, and when they
  /// tap finish.
  final FutureOr<bool> Function()? onBeforeClockIn;
  final FutureOr<bool> Function(ClockInDetails)? onClockIn;
  final FutureOr<void> Function(Set<int>)? onTasksChanged;
  final FutureOr<void> Function(Set<int>)? onFinish;
  final FutureOr<void> Function(String issueType, String details)?
  onReportIssue;
  final VoidCallback? onAddCareNote;
  final VoidCallback? onReportIncident;

  const VisitDesignPage({
    super.key,
    required this.clientName,
    required this.subtitle,
    required this.dateTime,
    required this.duration,
    required this.address,
    required this.phone,
    required this.accessType,
    required this.accessCode,
    required this.accessNote,
    required this.thingsToKnow,
    required this.tasks,
    this.handoverCard,
    this.initialCompletedTasks = const {},
    this.clockInEnabled = true,
    this.clockInHint,
    this.started = false,
    this.completed = false,
    this.startedAt,
    this.plannedLabel = '',
    this.preferredName,
    this.plannedStart,
    this.clientLatitude,
    this.clientLongitude,
    this.onBeforeClockIn,
    this.onClockIn,
    this.onTasksChanged,
    this.onFinish,
    this.onReportIssue,
    this.onAddCareNote,
    this.onReportIncident,
  });

  @override
  State<VisitDesignPage> createState() => _VisitDesignPageState();
}

class _VisitDesignPageState extends State<VisitDesignPage> {
  late bool started = widget.started;
  late DateTime? startedAt = widget.startedAt;
  bool showCode = false;
  late final Set<int> done;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    done = {...widget.initialCompletedTasks};
    if (started) _tick();
  }

  void _tick() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get elapsed {
    final d = DateTime.now().difference(startedAt ?? DateTime.now());
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '${d.inMinutes}:$s';
  }

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _clockIn() async {
    if (!widget.clockInEnabled) return;
    final canContinue = await widget.onBeforeClockIn?.call() ?? true;
    if (!canContinue || !mounted) return;
    final details = await showClockInSheet(
      context,
      preferred: widget.preferredName ?? widget.clientName,
      start: widget.plannedStart,
      clientLatitude: widget.clientLatitude,
      clientLongitude: widget.clientLongitude,
    );
    if (details == null || !mounted) return;
    late final bool recorded;
    try {
      recorded = await widget.onClockIn?.call(details) ?? true;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
    if (!recorded) return;
    setState(() {
      started = true;
      startedAt = details.at;
      _tick();
    });
  }

  Future<void> _toggleTask(int i) async {
    if (!started) return;
    setState(() => done.contains(i) ? done.remove(i) : done.add(i));
    try {
      await widget.onTasksChanged?.call(Set.unmodifiable(done));
    } catch (e) {
      if (!mounted) return;
      setState(() => done.contains(i) ? done.remove(i) : done.add(i));
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _reportIssue(String issueType) async {
    final controller = TextEditingController();
    final details = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(issueType),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Tell the office what happened',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (details == null || !mounted) return;
    try {
      await widget.onReportIssue?.call(issueType, details);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('The office has been notified.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(
            title: w.preferredName ?? w.clientName,
            showBack: true,
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final w = widget;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _card(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _h2(w.clientName),
                    addVerticalSpacing(0.47),
                    AppText(
                      text: w.dateTime,
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    AppText(
                      text:
                          '${w.duration}${w.subtitle.isEmpty ? '' : ', ${w.subtitle}'}',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
              widget.completed
                  ? Pill.ok('Completed')
                  : started
                  ? Pill.info('In progress')
                  : Pill.gold('Due soon'),
            ],
          ),
        ),
        if (started) ...[addVerticalSpacing(1.66), _timerCard()],
        addVerticalSpacing(1.66),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _h2('Where'),
              addVerticalSpacing(0.95),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 20, color: AppColors.ink),
                  addHorizontalSpacing(1.54),
                  Expanded(
                    child: AppText(
                      text: w.address,
                      type: AppTextType.bodySmall,
                      color: AppColors.ink,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(1.42),
              Row(
                children: [
                  Expanded(
                    child: DesignButton(
                      'Directions',
                      secondary: true,
                      icon: Icons.place_outlined,
                      onPressed: () => _open(
                        Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(w.address)}',
                        ),
                      ),
                    ),
                  ),
                  addHorizontalSpacing(2.56),
                  Expanded(
                    child: DesignButton(
                      'Call',
                      secondary: true,
                      icon: Icons.phone_outlined,
                      onPressed: () => _open(
                        Uri(scheme: 'tel', path: w.phone.replaceAll(' ', '')),
                      ),
                    ),
                  ),
                ],
              ),
              addVerticalSpacing(0.95),
              AppText(
                text: 'Phone: ${w.phone}',
                type: AppTextType.bodySmall,
                color: AppColors.muted,
                fontSize: 13,
              ),
            ],
          ),
        ),
        addVerticalSpacing(1.66),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _h2('Getting in'),
              addVerticalSpacing(0.71),
              AppText(
                text: w.accessType,
                type: AppTextType.bodySmall,
                color: AppColors.muted,
              ),
              addVerticalSpacing(0.47),
              GestureDetector(
                onTap: () => setState(() => showCode = !showCode),
                child: AppText(
                  text: showCode ? w.accessCode : 'Tap to show code',
                  type: showCode
                      ? AppTextType.displayMedium
                      : AppTextType.bodySmall,
                  fontFamily: showCode ? 'Playfair Display' : null,
                  fontSize: showCode ? 30 : null,
                  fontWeight: FontWeight.w700,
                  letterSpacing: showCode ? 4.2 : null,
                  decoration: showCode ? null : TextDecoration.underline,
                  color: AppColors.ink,
                ),
              ),
              addVerticalSpacing(0.71),
              AppText(
                text: w.accessNote,
                type: AppTextType.bodySmall,
                color: AppColors.ink,
              ),
            ],
          ),
        ),
        if (w.thingsToKnow.isNotEmpty) ...[
          addVerticalSpacing(1.66),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.amber),
                addHorizontalSpacing(2.56),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Things to know',
                        type: AppTextType.bodySmall,
                        color: AppColors.amber,
                        fontWeight: FontWeight.w700,
                      ),
                      addVerticalSpacing(0.47),
                      for (final t in w.thingsToKnow)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: AppText(
                            text: '• $t',
                            type: AppTextType.bodySmall,
                            color: AppColors.amber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (w.handoverCard != null) ...[
          addVerticalSpacing(1.66),
          w.handoverCard!,
        ],
        addVerticalSpacing(3.08),
        _h2('Care plan tasks', size: 19),
        addVerticalSpacing(0.47),
        AppText(
          text: started
              ? 'Tap each task when it is done.'
              : 'You can tick tasks once you clock in.',
          type: AppTextType.bodySmall,
          color: AppColors.muted,
        ),
        addVerticalSpacing(1.18),
        for (var i = 0; i < w.tasks.length; i++) ...[
          _task(i),
          addVerticalSpacing(1.42),
        ],
        addVerticalSpacing(0.95),
        _quickActions(context),
        addVerticalSpacing(2.61),
        if (widget.completed)
          NoticeBox.ok('This visit has been completed.')
        else if (started)
          DesignButton(
            'Finish visit and write your note',
            onPressed: () async {
              try {
                await widget.onFinish?.call(Set.unmodifiable(done));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.maybeOf(
                  context,
                )?.showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          )
        else ...[
          DesignButton(
            'Clock in',
            icon: Icons.access_time,
            onPressed: w.clockInEnabled ? _clockIn : null,
          ),
          if (w.clockInHint != null) ...[
            addVerticalSpacing(0.71),
            AppText(
              text: w.clockInHint!,
              type: AppTextType.bodySmall,
              color: AppColors.muted,
              fontSize: 14,
            ),
          ],
          addVerticalSpacing(1.18),
          Row(
            children: [
              Expanded(
                child: DesignButton(
                  'Running late',
                  secondary: true,
                  icon: Icons.access_time,
                  onPressed: () => _reportIssue('Running late'),
                ),
              ),
              addHorizontalSpacing(2.56),
              Expanded(
                child: DesignButton(
                  'Cannot get in',
                  secondary: true,
                  icon: Icons.lock_outline,
                  onPressed: () => _reportIssue('Cannot get in'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _timerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sage, width: 2),
      ),
      child: Column(
        children: [
          AppText(
            text: elapsed,
            type: AppTextType.bodySmall,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: AppColors.sage,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          AppText(
            text:
                'Clocked in at ${_hhmm(startedAt ?? DateTime.now())}${widget.plannedLabel.isEmpty ? '' : ', ${widget.plannedLabel}'}',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _task(int i) {
    final t = widget.tasks[i];
    final isDone = done.contains(i);
    return Material(
      color: isDone ? AppColors.sageBg : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: started ? () => _toggleTask(i) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDone ? AppColors.sage : AppColors.line2,
              width: 1.5,
              style: started ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.sage : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone ? AppColors.sage : AppColors.line2,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.dark
                            ? const Color(0xFF0B1322)
                            : Colors.white,
                      )
                    : null,
              ),
              addHorizontalSpacing(3.08),
              if (t.medication) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    text: 'Medication',
                    type: AppTextType.bodySmall,
                    color: AppColors.info,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                addHorizontalSpacing(1.54),
              ],
              Expanded(
                child: AppText(
                  text: t.label,
                  type: AppTextType.bodySmall,
                  color: AppColors.ink,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    Widget b(
      String label,
      IconData icon,
      VoidCallback? onPressed, {
      bool danger = false,
    }) {
      return SizedBox(
        height: 52,
        child: AppButton(
          text: label,
          onPressed: onPressed,
          btnColor: Colors.transparent,
          textColor: danger ? AppColors.rose : AppColors.ink,
          borderColor: danger ? AppColors.rose : AppColors.line2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: danger ? AppColors.rose : AppColors.ink,
              ),
              addHorizontalSpacing(1),
              Flexible(
                child: AppText(
                  text: label,
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w700,
                  color: danger ? AppColors.rose : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = [
      b('Add care note', Icons.edit_outlined, widget.onAddCareNote),
      b(
        'Report incident',
        Icons.warning_amber_rounded,
        widget.onReportIncident,
        danger: true,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.7,
      children: items,
    );
  }

  Widget _card(Widget child) => DesignCard(child: child);

  Widget _h2(String t, {double size = 19}) => AppText(
    text: t,
    type: AppTextType.bodySmall,
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w700,
    fontSize: size,
    color: AppColors.ink,
  );
}
