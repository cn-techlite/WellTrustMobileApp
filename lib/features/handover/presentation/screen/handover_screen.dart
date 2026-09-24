import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/screen/handover_client_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/provider/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/add_handover_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class HandoverScreen extends ConsumerStatefulWidget {
  const HandoverScreen({super.key});

  @override
  ConsumerState<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends ConsumerState<HandoverScreen> {
  String tab = 'today';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(handoverProvider);
    final today = handoverClients.where((c) => c.visitToday).toList();
    final flagged = handoverClients
        .where(
          (c) => state.openFor(c.id).isNotEmpty || state.unreadFor(c.id) > 0,
        )
        .toList();
    final list = switch (tab) {
      'today' => today,
      'flagged' => flagged,
      _ => handoverClients,
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Care handover'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'What has happened and what to know for each person you support. Read it before your visit, and add your own for the next carer.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                DesignButton(
                  'Add handover',
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      displayBottomSheet(context, const AddHandoverSheet()),
                ),
                const SizedBox(height: 14),
                SegmentTabs(
                  active: tab,
                  onChanged: (v) => setState(() => tab = v),
                  options: [
                    ('today', 'Today (${today.length})'),
                    ('all', 'All (${handoverClients.length})'),
                    ('flagged', 'Flagged (${flagged.length})'),
                  ],
                ),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tab == 'flagged'
                              ? 'Nothing needs your attention'
                              : 'No visits today',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'People on your rota appear here.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                else
                  for (final c in list) ...[
                    _ClientRow(client: c, state: state),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final HandoverClient client;
  final HandoverState state;

  const _ClientRow({required this.client, required this.state});

  @override
  Widget build(BuildContext context) {
    final all = state.forClient(client.id);
    final unread = state.unreadFor(client.id);
    final open = state.openFor(client.id);
    final concern = open.any(
      (e) =>
          e.kind == HandoverKind.concern ||
          e.priority == HandoverPriority.urgent,
    );
    return DesignCard(
      onTap: () =>
          navigateToRoute(context, HandoverClientScreen(clientId: client.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.preferred,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${client.name}. Next visit: ${nextVisitLabel(client)}',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  all.isEmpty ? 'No handover yet' : all.first.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (unread > 0) Pill.gold('$unread new'),
              if (concern) ...[
                const SizedBox(height: 4),
                Pill.bad('Concern'),
              ] else if (open.isNotEmpty) ...[
                const SizedBox(height: 4),
                Pill.warn('To do'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
