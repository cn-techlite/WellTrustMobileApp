import 'dart:async';

import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/add_note_bottom_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/body_map_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/med_visit_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/raise_cocerns_bottomshet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/report_incident_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/safe_guard_bottomsheet.dart';
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
  final Set<int> initialCompletedTasks;
  final bool clockInEnabled;
  final String? clockInHint;

  /// True once the carer has clocked in.
  final bool started;
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
  final bool Function(ClockInDetails)? onClockIn;
  final ValueChanged<Set<int>>? onTasksChanged;
  final VoidCallback? onFinish;

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
    this.initialCompletedTasks = const {},
    this.clockInEnabled = true,
    this.clockInHint,
    this.started = false,
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
    final recorded = widget.onClockIn?.call(details) ?? true;
    if (!recorded) return;
    setState(() {
      started = true;
      startedAt = details.at;
      _tick();
    });
  }

  void _toggleTask(int i) {
    if (!started) return;
    final t = widget.tasks[i];
    if (t.medication && !done.contains(i)) {
      displayBottomSheet(context, MedsForVisitBottomSheet());
    }
    setState(() => done.contains(i) ? done.remove(i) : done.add(i));
    widget.onTasksChanged?.call(Set.unmodifiable(done));
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: w.clientName.split(' ').first, showBack: true),
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
                    const SizedBox(height: 4),
                    Text(
                      w.dateTime,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${w.duration}${w.subtitle.isEmpty ? '' : ', ${w.subtitle}'}',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              started ? Pill.info('In progress') : Pill.gold('Due soon'),
            ],
          ),
        ),
        if (started) ...[const SizedBox(height: 14), _timerCard()],
        const SizedBox(height: 14),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _h2('Where'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 20, color: AppColors.ink),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      w.address,
                      style: TextStyle(color: AppColors.ink, fontSize: 15.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                  const SizedBox(width: 10),
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
              const SizedBox(height: 8),
              Text(
                'Phone: ${w.phone}',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _h2('Getting in'),
              const SizedBox(height: 6),
              Text(w.accessType, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => showCode = !showCode),
                child: Text(
                  showCode ? w.accessCode : 'Tap to show code',
                  style: showCode
                      ? TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4.2,
                          color: AppColors.ink,
                        )
                      : TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          color: AppColors.ink,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(w.accessNote, style: TextStyle(color: AppColors.ink)),
            ],
          ),
        ),
        if (w.thingsToKnow.isNotEmpty) ...[
          const SizedBox(height: 14),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Things to know',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final t in w.thingsToKnow)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            '• $t',
                            style: TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
        _h2('Care plan tasks', size: 19),
        const SizedBox(height: 4),
        Text(
          started
              ? 'Tap each task when it is done.'
              : 'You can tick tasks once you clock in.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < w.tasks.length; i++) ...[
          _task(i),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        _quickActions(context),
        const SizedBox(height: 22),
        if (started)
          DesignButton(
            'Finish visit and write your note',
            onPressed: () {
              widget.onFinish?.call();
              displayBottomSheet(context, AddCareNoteBottomSheet());
            },
          )
        else ...[
          DesignButton(
            'Clock in',
            icon: Icons.access_time,
            onPressed: w.clockInEnabled ? _clockIn : null,
          ),
          if (w.clockInHint != null) ...[
            const SizedBox(height: 6),
            Text(
              w.clockInHint!,
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DesignButton(
                  'Running late',
                  secondary: true,
                  icon: Icons.access_time,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DesignButton(
                  'Cannot get in',
                  secondary: true,
                  icon: Icons.lock_outline,
                  onPressed: () {},
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
          Text(
            elapsed,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 34,
              color: AppColors.sage,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            'Clocked in at ${_hhmm(startedAt ?? DateTime.now())}${widget.plannedLabel.isEmpty ? '' : ', ${widget.plannedLabel}'}',
            style: TextStyle(color: AppColors.muted),
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
              const SizedBox(width: 12),
              if (t.medication) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Medication',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  t.label,
                  style: TextStyle(color: AppColors.ink, fontSize: 15.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    Widget b(String label, IconData icon, Widget sheet, {bool danger = false}) {
      return SizedBox(
        height: 52,
        child: TextButton.icon(
          onPressed: () => displayBottomSheet(context, sheet),
          icon: Icon(
            icon,
            size: 20,
            color: danger ? AppColors.rose : AppColors.ink,
          ),
          label: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: danger ? AppColors.rose : AppColors.ink,
            ),
          ),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: danger ? AppColors.rose : AppColors.line2,
                width: 1.5,
              ),
            ),
          ),
        ),
      );
    }

    final items = [
      b('Add care note', Icons.edit_outlined, AddCareNoteBottomSheet()),
      b(
        'Meds this visit',
        Icons.medication_outlined,
        MedsForVisitBottomSheet(),
      ),
      b('Body map', Icons.accessibility_new, BodyMapBottomSheet()),
      b(
        'Raise concern',
        Icons.flag_outlined,
        RaiseConcernBottomSheet(),
        danger: true,
      ),
      b(
        'Report incident',
        Icons.warning_amber_rounded,
        ReportIncidentBottomSheet(),
        danger: true,
      ),
      b(
        'Safeguarding',
        Icons.shield_outlined,
        SafeguardingBottomSheet(),
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

  Widget _h2(String t, {double size = 19}) => Text(
    t,
    style: TextStyle(
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: AppColors.ink,
    ),
  );
}
