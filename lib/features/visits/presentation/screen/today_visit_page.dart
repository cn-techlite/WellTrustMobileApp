import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/screen/handover_client_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/add_handover_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/today_run_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/clock_in_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_design_page.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/screen/new_care_note_page.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/more_screens.dart';

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
    final handover = ref.watch(handoverProvider);
    final allHandover = handover.forClient(v.clientId);
    final openHandover = handover.openFor(v.clientId);
    final openIds = openHandover.map((entry) => entry.id).toSet();
    final handoverPreview = <HandoverEntry>[
      ...openHandover,
      ...allHandover.where((entry) => !openIds.contains(entry.id)),
    ].take(2).toList();
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
      handoverCard: _VisitHandoverCard(
        entries: handoverPreview,
        unread: handover.unreadFor(v.clientId),
        onSeeFull: () => navigateToRoute(
          context,
          HandoverClientScreen(clientId: v.clientId),
        ),
        onAdd: () =>
            navigateToRoute(context, AddHandoverPage(clientId: v.clientId)),
      ),
      initialCompletedTasks: run.completedTasks[v.id] ?? const {},
      clockInEnabled: v.canStart && timing.isOpen,
      clockInHint: timing.hasClosed
          ? 'This visit started more than ${formatMinutes(clockInWindowMins)} ago, so you cannot clock in. Tell the office what happened.'
          : !timing.isOpen
          ? 'Clock-in opens at ${hhmm(timing.opensAt)}, ${formatMinutes(clockInWindowMins)} before the start.'
          : timing.needsReason
          ? 'You will be asked why you are starting ${timing.isEarly ? 'early' : 'late'}.'
          : null,
      started:
          v.isInProgress || (clockedAt != null && !run.finished.contains(v.id)),
      completed: v.isCompleted || run.finished.contains(v.id),
      startedAt: clockedAt,
      plannedLabel: 'planned ${hhmm(v.start)}',
      preferredName: v.preferred,
      plannedStart: v.start,
      clientLatitude: v.latitude,
      clientLongitude: v.longitude,
      onBeforeClockIn: () => _guardAgainstAnotherVisit(context, ref, v),
      onClockIn: (details) =>
          ref.read(visitControllerProvider.notifier).clockIn(v, details),
      onTasksChanged: (tasks) async {
        final before =
            ref.read(todayRunProvider).completedTasks[v.id] ?? const <int>{};
        for (var index = 0; index < v.tasks.length; index++) {
          if (before.contains(index) != tasks.contains(index)) {
            await ref
                .read(visitControllerProvider.notifier)
                .setTask(v, index, tasks.contains(index));
          }
        }
      },
      onFinish: (tasks) async {
        final saved = await ref
            .read(visitControllerProvider.notifier)
            .clockOut(v, tasks);
        if (!saved || !context.mounted) return;
        navigateAndReplaceRoute(context, NewCareNotePage(clientId: v.clientId));
      },
      onReportIssue: (issueType, details) => ref
          .read(visitControllerProvider.notifier)
          .reportIssue(v.id, issueType: issueType, details: details),
      onAddCareNote: () =>
          navigateToRoute(context, NewCareNotePage(clientId: v.clientId)),
      onReportIncident: () => navigateToRoute(
        context,
        IncidentReportScreen(initialClientId: v.clientId),
      ),
    );
  }

  Future<bool> _guardAgainstAnotherVisit(
    BuildContext context,
    WidgetRef ref,
    TodayVisit requested,
  ) async {
    final activeId = ref.read(todayRunProvider).activeVisitId;
    if (activeId == null || activeId == requested.id) return true;
    final active =
        (ref.read(visitControllerProvider).value?.visits ??
                const <TodayVisit>[])
            .where((v) => v.id == activeId)
            .firstOrNull;
    if (active == null) return true;
    final openActive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText(
          text: 'Finish your current visit first',
          type: AppTextType.bodySmall,
        ),
        content: AppText(
          text:
              'You are still clocked in to ${active.preferred}. Finish that visit before you clock in to ${requested.preferred}.',
          type: AppTextType.bodySmall,
        ),
        actions: [
          AppButton(
            text: 'Close',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.muted,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          AppButton(
            text: 'Open that visit',
            expand: false,
            onPressed: () => Navigator.pop(dialogContext, true),
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

class _VisitHandoverCard extends StatelessWidget {
  final List<HandoverEntry> entries;
  final int unread;
  final VoidCallback onSeeFull;
  final VoidCallback onAdd;

  const _VisitHandoverCard({
    required this.entries,
    required this.unread,
    required this.onSeeFull,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: 'Handover',
                  type: AppTextType.bodySmall,
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  color: AppColors.ink,
                ),
              ),
              unread > 0 ? Pill.gold('$unread new') : Pill.ok('Read'),
            ],
          ),
          if (entries.isEmpty) ...[
            addVerticalSpacing(0.95),
            AppText(
              text: 'Nothing has been handed over yet.',
              type: AppTextType.bodySmall,
              color: AppColors.muted,
            ),
          ] else
            for (final entry in entries) ...[
              addVerticalSpacing(1.18),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  kindPill(entry.kind),
                  AppText(
                    text: handoverWhen(entry.at),
                    type: AppTextType.bodySmall,
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ],
              ),
              addVerticalSpacing(0.47),
              AppText(
                text: entry.text,
                type: AppTextType.bodySmall,
                color: AppColors.ink,
                height: 1.35,
              ),
            ],
          addVerticalSpacing(1.42),
          if (entries.isEmpty)
            DesignButton(
              'Add handover',
              secondary: true,
              small: true,
              onPressed: onAdd,
            )
          else
            Row(
              children: [
                Expanded(
                  child: DesignButton(
                    'See the full handover',
                    secondary: true,
                    small: true,
                    onPressed: onSeeFull,
                  ),
                ),
                addHorizontalSpacing(2.56),
                Expanded(
                  child: DesignButton(
                    'Add handover',
                    secondary: true,
                    small: true,
                    onPressed: onAdd,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
