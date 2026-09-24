import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_design_page.dart';

/// The visit page for one visit on today's round.
class TodayVisitPage extends ConsumerWidget {
  final TodayVisit visit;

  const TodayVisitPage({super.key, required this.visit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(todayRunProvider);
    final v = visit;
    final clockedAt = run.clockedIn[v.id];
    final timing = ClockInTiming(start: v.start, now: DateTime.now());
    return VisitDesignPage(
      clientName: v.name,
      subtitle: v.type,
      dateTime: 'Today, ${hhmm(v.start)} to ${hhmm(v.end)}',
      duration: '${v.minutes} min',
      address: v.address,
      phone: v.phone,
      accessType: v.accessType,
      accessCode: v.accessCode,
      accessNote: v.accessNote,
      thingsToKnow: v.thingsToKnow,
      tasks: v.tasks,
      initialCompletedTasks: run.completedTasks[v.id] ?? const {},
      clockInEnabled: timing.isOpen,
      clockInHint: timing.hasClosed
          ? 'This visit started more than ${formatMinutes(clockInWindowMins)} ago, so you cannot clock in. Tell the office what happened.'
          : !timing.isOpen
          ? 'Clock-in opens at ${hhmm(timing.opensAt)}, ${formatMinutes(clockInWindowMins)} before the start.'
          : timing.needsReason
          ? 'You will be asked why you are starting ${timing.isEarly ? 'early' : 'late'}.'
          : null,
      started: clockedAt != null,
      startedAt: clockedAt,
      plannedLabel: 'planned ${hhmm(v.start)}',
      preferredName: v.preferred,
      plannedStart: v.start,
      clientLatitude: v.latitude,
      clientLongitude: v.longitude,
      onBeforeClockIn: () => _guardAgainstAnotherVisit(context, ref, v),
      onClockIn: (details) =>
          ref.read(todayRunProvider.notifier).clockIn(v.id, details: details),
      onTasksChanged: (tasks) =>
          ref.read(todayRunProvider.notifier).setCompletedTasks(v.id, tasks),
      onFinish: () => ref.read(todayRunProvider.notifier).finish(v.id),
    );
  }

  Future<bool> _guardAgainstAnotherVisit(
    BuildContext context,
    WidgetRef ref,
    TodayVisit requested,
  ) async {
    final activeId = ref.read(todayRunProvider).activeVisitId;
    if (activeId == null || activeId == requested.id) return true;
    final active = todayVisits.firstWhere((v) => v.id == activeId);
    final openActive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish your current visit first'),
        content: Text(
          'You are still clocked in to ${active.preferred}. Finish that visit before you clock in to ${requested.preferred}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Open that visit'),
          ),
        ],
      ),
    );
    if (openActive == true && context.mounted) {
      navigateToRoute(context, TodayVisitPage(visit: active));
    }
    return false;
  }
}
