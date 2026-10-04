import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/clients/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/screen/handover_client_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/state_model/handover_state.dart';
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
    final clients =
        ref.watch(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];
    final visits =
        ref.watch(visitControllerProvider).value?.visits ??
        const <TodayVisit>[];
    final todayIds = visits
        .where((visit) => DateUtils.isSameDay(visit.start, DateTime.now()))
        .map((visit) => visit.clientId)
        .toSet();
    final today = clients.where((c) => todayIds.contains(c.id)).toList()
      ..sort((a, b) => _visitOrder(a.id).compareTo(_visitOrder(b.id)));
    final all = [...clients]
      ..sort((a, b) => a.preferred.compareTo(b.preferred));
    final flagged =
        clients
            .where(
              (c) =>
                  state.openFor(c.id).isNotEmpty || state.unreadFor(c.id) > 0,
            )
            .toList()
          ..sort((a, b) => a.preferred.compareTo(b.preferred));
    final list = switch (tab) {
      'today' => today,
      'flagged' => flagged,
      _ => all,
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
                AppText(
                  text:
                      'What has happened and what to know for each person you support. Read it before your visit, and add your own for the next carer. Handover is kept in its own document. You only see people on your rota.',
                  type: AppTextType.bodySmall,
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.4,
                ),
                addVerticalSpacing(1.66),
                DesignButton(
                  'Add handover',
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      navigateToRoute(context, const AddHandoverPage()),
                ),
                addVerticalSpacing(1.66),
                SegmentTabs(
                  active: tab,
                  onChanged: (v) => setState(() => tab = v),
                  options: [
                    ('today', 'Today (${today.length})'),
                    ('all', 'All (${clients.length})'),
                    ('flagged', 'Flagged (${flagged.length})'),
                  ],
                ),
                addVerticalSpacing(1.66),
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
                        AppText(
                          text: tab == 'flagged'
                              ? 'Nothing needs your attention'
                              : 'No visits today',
                          type: AppTextType.bodySmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        addVerticalSpacing(0.47),
                        AppText(
                          text: 'People on your rota appear here.',
                          type: AppTextType.bodySmall,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  )
                else
                  for (final c in list) ...[
                    _ClientRow(
                      client: c,
                      state: state,
                      nextVisit: visits
                          .where((visit) => visit.clientId == c.id)
                          .firstOrNull,
                    ),
                    addVerticalSpacing(1.42),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _visitOrder(String clientId) {
    for (final visit
        in ref.read(visitControllerProvider).value?.visits ??
            const <TodayVisit>[]) {
      if (visit.clientId == clientId) return visit.start;
    }
    return DateTime(9999);
  }
}

class _ClientRow extends StatelessWidget {
  final AssignedClient client;
  final HandoverState state;
  final TodayVisit? nextVisit;

  const _ClientRow({
    required this.client,
    required this.state,
    required this.nextVisit,
  });

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
                AppText(
                  text: client.preferred,
                  type: AppTextType.bodySmall,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
                AppText(
                  text: nextVisit == null
                      ? client.name
                      : '${client.name}. Next visit: ${DateFormat('EEE d MMM, HH:mm').format(nextVisit!.start)}',
                  type: AppTextType.bodySmall,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
                addVerticalSpacing(0.47),
                AppText(
                  text: all.isEmpty ? 'No handover yet' : all.first.text,
                  type: AppTextType.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ],
            ),
          ),
          addHorizontalSpacing(2.05),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (unread > 0) Pill.gold('$unread new'),
              if (concern) ...[
                addVerticalSpacing(0.47),
                Pill.bad('Concern'),
              ] else if (open.isNotEmpty) ...[
                addVerticalSpacing(0.47),
                Pill.warn('To do'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
