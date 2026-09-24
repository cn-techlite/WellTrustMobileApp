import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/provider/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/add_handover_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class HandoverClientScreen extends ConsumerWidget {
  final String clientId;

  const HandoverClientScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(handoverProvider);
    final client = handoverClients.firstWhere((c) => c.id == clientId);
    final unread = state.unreadFor(clientId);
    final open = state.openFor(clientId);
    final openIds = open.map((e) => e.id).toSet();
    final rest = state
        .forClient(clientId)
        .where((e) => !openIds.contains(e.id))
        .toList();
    final readAt = state.readAt[clientId];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: client.preferred, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DesignCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Next visit: ${nextVisitLabel(client)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DesignButton(
                        'Add handover',
                        small: true,
                        icon: Icons.edit_outlined,
                        onPressed: () => displayBottomSheet(
                          context,
                          AddHandoverSheet(clientId: clientId),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unread new handover ${unread == 1 ? 'note' : 'notes'} since you last checked.',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DesignButton(
                          'I have read this handover',
                          small: true,
                          onPressed: () {
                            ref
                                .read(handoverProvider.notifier)
                                .markRead(clientId);
                          },
                        ),
                      ],
                    ),
                  )
                else
                  NoticeBox.ok(
                    readAt == null
                        ? 'You have read all of this.'
                        : 'You have read all of this (${handoverWhen(readAt)}).',
                  ),
                if (open.isNotEmpty) ...[
                  const _Section('Needs your attention'),
                  for (final e in open) _EntryCard(entry: e),
                ],
                const _Section('Handover'),
                if (rest.isEmpty)
                  Text(
                    'Nothing else has been handed over.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  for (final e in rest) _EntryCard(entry: e),
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
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: AppColors.ink,
      ),
    ),
  );
}

class _EntryCard extends ConsumerWidget {
  final HandoverEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = entry;
    final urgent = e.isOpen && e.priority == HandoverPriority.urgent;
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
                      kindPill(e.kind),
                      if (e.priority == HandoverPriority.urgent && !e.resolved)
                        Pill.bad('Urgent'),
                      if (e.priority == HandoverPriority.important &&
                          !e.resolved)
                        Pill.warn('Important'),
                      if (e.resolved) Pill.ok('Done'),
                      if (e.by == 'You') Pill.neutral('You'),
                    ],
                  ),
                ),
                Text(
                  handoverWhen(e.at),
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              e.text,
              style: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.4),
            ),
            if (e.needsFollowUp) ...[
              const SizedBox(height: 8),
              e.resolved
                  ? NoticeBox.ok('Done by ${e.resolvedBy ?? 'a colleague'}')
                  : NoticeBox.warn(
                      'Follow-up for ${e.followUpFor.toLowerCase()}',
                    ),
            ],
            const SizedBox(height: 6),
            Text(
              'From ${e.by}',
              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
            if (e.isOpen) ...[
              const SizedBox(height: 8),
              DesignButton(
                'Mark as done',
                small: true,
                secondary: true,
                onPressed: () =>
                    ref.read(handoverProvider.notifier).markDone(e.id, 'You'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
