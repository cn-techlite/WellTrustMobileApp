import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/add_handover_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/screen/today_visit_page.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/visit_design_page.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class HandoverClientScreen extends ConsumerWidget {
  final String clientId;

  const HandoverClientScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(handoverProvider);
    final clients =
        ref.watch(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];
    final client = clients.where((c) => c.id == clientId).firstOrNull;
    if (client == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final unread = state.unreadFor(clientId);
    final open = state.openFor(clientId);
    final openIds = open.map((entry) => entry.id).toSet();
    final rest = state
        .forClient(clientId)
        .where((entry) => !openIds.contains(entry.id))
        .toList();
    final readAt = state.readAt[clientId];
    final nextVisit = _visitFor(
      ref.watch(visitControllerProvider).value?.visits ?? const [],
      clientId,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: client.preferred, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              children: [
                _ClientSummary(
                  client: client,
                  nextVisit: nextVisit,
                  onAdd: () => navigateToRoute(
                    context,
                    AddHandoverPage(clientId: clientId),
                  ),
                  onOpenVisit: client.nextVisit.isEmpty
                      ? null
                      : () => navigateToRoute(
                          context,
                          nextVisit == null
                              ? _plannedVisitPage(client)
                              : TodayVisitPage(visit: nextVisit),
                        ),
                ),
                if (client.alerts.isNotEmpty) ...[
                  addVerticalSpacing(1.66),
                  _ThingsToKnow(alerts: client.alerts),
                ],
                addVerticalSpacing(1.66),
                if (unread > 0)
                  _UnreadNotice(
                    count: unread,
                    onRead: () =>
                        ref.read(handoverProvider.notifier).markRead(clientId),
                  )
                else
                  NoticeBox.ok(
                    readAt == null
                        ? 'You have read all of this.'
                        : 'You have read all of this (${handoverWhen(readAt)}).',
                  ),
                if (open.isNotEmpty) ...[
                  const _Section('Needs your attention'),
                  for (final entry in open)
                    _EntryCard(entry: entry, isNew: _isNew(entry, readAt)),
                ],
                const _Section('Handover'),
                if (rest.isEmpty)
                  AppText(
                    text: 'Nothing else has been handed over.',
                    type: AppTextType.bodySmall,
                    color: AppColors.muted,
                  )
                else
                  for (final entry in rest)
                    _EntryCard(entry: entry, isNew: _isNew(entry, readAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TodayVisit? _visitFor(List<TodayVisit> visits, String id) {
    for (final visit in visits) {
      if (visit.clientId == id) return visit;
    }
    return null;
  }

  Widget _plannedVisitPage(AssignedClient client) => VisitDesignPage(
    clientName: client.name,
    subtitle: 'Planned visit',
    dateTime: client.nextVisit,
    duration: 'Planned by management',
    address: client.address,
    phone: client.phone,
    accessType: 'Access details',
    accessCode: '',
    accessNote:
        'Access details will be available before the planned visit begins.',
    thingsToKnow: client.alerts,
    tasks: const [],
    clockInEnabled: false,
    clockInHint: 'Clock-in is not open for this visit yet.',
    preferredName: client.preferred,
  );

  bool _isNew(HandoverEntry entry, DateTime? readAt) =>
      entry.by != 'You' && (readAt == null || entry.at.isAfter(readAt));
}

class _ClientSummary extends StatelessWidget {
  final AssignedClient client;
  final TodayVisit? nextVisit;
  final VoidCallback onAdd;
  final VoidCallback? onOpenVisit;

  const _ClientSummary({
    required this.client,
    required this.nextVisit,
    required this.onAdd,
    required this.onOpenVisit,
  });

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: client.name,
            type: AppTextType.titleSmall,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          addVerticalSpacing(0.36),
          AppText(
            text: client.address,
            type: AppTextType.bodySmall,
            color: AppColors.muted,
          ),
          addVerticalSpacing(0.95),
          if (nextVisit != null)
            AppText(
              text:
                  'Next visit: ${DateFormat('EEE d MMM').format(nextVisit!.start)}, ${hhmm(nextVisit!.start)}',
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            )
          else
            AppText(
              text: client.nextVisit.isEmpty
                  ? 'No visit planned for you.'
                  : 'Next visit: ${client.nextVisit}',
              type: AppTextType.bodySmall,
              color: client.nextVisit.isEmpty ? AppColors.muted : AppColors.ink,
              fontWeight: client.nextVisit.isEmpty
                  ? FontWeight.w400
                  : FontWeight.w700,
            ),
          addVerticalSpacing(1.42),
          Row(
            children: [
              Expanded(
                child: DesignButton(
                  'Add handover',
                  small: true,
                  icon: Icons.edit_outlined,
                  onPressed: onAdd,
                ),
              ),
              if (onOpenVisit != null) ...[
                addHorizontalSpacing(2.56),
                Expanded(
                  child: DesignButton(
                    'Open the visit',
                    small: true,
                    secondary: true,
                    onPressed: onOpenVisit,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ThingsToKnow extends StatelessWidget {
  final List<String> alerts;

  const _ThingsToKnow({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 22),
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
                for (final alert in alerts)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: AppText(
                      text: '• $alert',
                      type: AppTextType.bodySmall,
                      color: AppColors.amber,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadNotice extends StatelessWidget {
  final int count;
  final VoidCallback onRead;

  const _UnreadNotice({required this.count, required this.onRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note_alt_outlined, color: AppColors.info, size: 22),
          addHorizontalSpacing(2.56),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text:
                      '$count new handover ${count == 1 ? 'note' : 'notes'} since you last checked.',
                  type: AppTextType.bodySmall,
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
                addVerticalSpacing(1.18),
                DesignButton(
                  'I have read this handover',
                  small: true,
                  onPressed: onRead,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 10),
    child: AppText(
      text: title,
      type: AppTextType.titleSmall,
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
  );
}

class _EntryCard extends ConsumerWidget {
  final HandoverEntry entry;
  final bool isNew;

  const _EntryCard({required this.entry, required this.isNew});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = this.entry;
    final urgent = entry.isOpen && entry.priority == HandoverPriority.urgent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DesignCard(
        borderColor: urgent ? AppColors.rose : null,
        borderWidth: urgent ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      kindPill(entry.kind),
                      if (entry.priority == HandoverPriority.urgent &&
                          !entry.resolved)
                        Pill.bad('Urgent')
                      else if (entry.priority == HandoverPriority.important &&
                          !entry.resolved)
                        Pill.warn('Important'),
                      if (entry.resolved && !entry.needsFollowUp)
                        Pill.ok('Done'),
                      if (isNew) Pill.gold('New'),
                      if (entry.by == 'You') Pill.neutral('You'),
                    ],
                  ),
                ),
                addHorizontalSpacing(2.05),
                AppText(
                  text: handoverWhen(entry.at),
                  type: AppTextType.labelLarge,
                  color: AppColors.muted,
                ),
              ],
            ),
            addVerticalSpacing(0.95),
            AppText(
              text: entry.text,
              type: AppTextType.bodySmall,
              color: AppColors.ink,
              height: 1.4,
            ),
            if (entry.details.isNotEmpty) ...[
              addVerticalSpacing(1.18),
              _EntryDetails(details: entry.details),
            ],
            if (entry.needsFollowUp) ...[
              addVerticalSpacing(1.18),
              entry.resolved
                  ? NoticeBox.ok(_doneText(entry))
                  : NoticeBox.warn(_followUpText(entry)),
            ],
            addVerticalSpacing(0.95),
            AppText(
              text: 'From ${entry.by}',
              type: AppTextType.labelLarge,
              color: AppColors.muted,
            ),
            if (entry.isOpen) ...[
              addVerticalSpacing(1.18),
              DesignButton(
                'Mark as done',
                small: true,
                secondary: true,
                onPressed: () => _markDone(context, ref, entry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _followUpText(HandoverEntry entry) {
    final due = entry.followUpDue;
    return 'Follow-up for ${entry.followUpFor.toLowerCase()}'
        '${due == null ? '' : ', by ${DateFormat('d MMM yyyy').format(due)}'}';
  }

  String _doneText(HandoverEntry entry) {
    final at = entry.resolvedAt;
    final note = entry.resolutionNote.trim();
    return 'Done by ${entry.resolvedBy ?? 'a colleague'}'
        '${at == null ? '' : ', ${handoverWhen(at)}'}'
        '${note.isEmpty ? '' : '. $note'}';
  }

  Future<void> _markDone(
    BuildContext context,
    WidgetRef ref,
    HandoverEntry entry,
  ) async {
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText(
          text: 'Mark follow-up as done?',
          type: AppTextType.titleSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text:
                  'The office and other carers will see that this has been completed.',
              type: AppTextType.bodySmall,
            ),
            addVerticalSpacing(1.42),
            GlobalTextField(
              fieldName: 'Completion note (optional)',
              keyBoardType: TextInputType.multiline,
              textController: note,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              isOptional: true,
              removeSpace: false,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.muted,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          AppButton(
            text: 'Mark as done',
            expand: false,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    final completionNote = note.text.trim();
    note.dispose();
    if (confirmed != true) return;
    ref
        .read(handoverProvider.notifier)
        .markDone(entry.id, 'You', note: completionNote);
  }
}

class _EntryDetails extends StatelessWidget {
  final Map<String, String> details;

  const _EntryDetails({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          for (final detail in details.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 124,
                    child: AppText(
                      text: detail.key,
                      type: AppTextType.labelLarge,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  addHorizontalSpacing(2.05),
                  Expanded(
                    child: AppText(
                      text: detail.value,
                      type: AppTextType.bodySmall,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
