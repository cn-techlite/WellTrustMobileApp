import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/account_state_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

enum _Area { supervisions, probation, declarations }

/// The carer's own supervisions, probation sign-off and declarations. The
/// office writes these, so they are read only here.
class OfficeRecordsScreen extends ConsumerStatefulWidget {
  const OfficeRecordsScreen({super.key});

  @override
  ConsumerState<OfficeRecordsScreen> createState() =>
      _OfficeRecordsScreenState();
}

class _OfficeRecordsScreenState extends ConsumerState<OfficeRecordsScreen> {
  _Area _area = _Area.supervisions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // The records are looked up by the carer's own id, so the profile comes first.
      final account = ref.read(accountControllerProvider.notifier);
      await account.getAccount();
      await _load();
    });
  }

  Future<void> _load() async {
    final error = await ref
        .read(accountControllerProvider.notifier)
        .loadOfficeRecords();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  static const _labels = {
    _Area.supervisions: 'Supervisions',
    _Area.probation: 'Probation',
    _Area.declarations: 'Declarations',
  };

  static const _empty = {
    _Area.supervisions: 'Your supervisions and appraisals appear here.',
    _Area.probation: 'Your probation sign-off appears here.',
    _Area.declarations: 'The declarations you have confirmed appear here.',
  };

  List<Widget> _cards(AccountStateModel a) => switch (_area) {
    _Area.supervisions => [for (final s in a.supervisions) _supervision(s)],
    _Area.probation => [for (final p in a.probation) _probation(p)],
    _Area.declarations => [for (final d in a.declarations) _declaration(d)],
  };

  Widget _supervision(StaffSupervision s) => _ReadCard(
    title: applicable(s.supervisionType) == null
        ? 'Supervision'
        : humanize(s.supervisionType!),
    pills: [if (applicable(s.status) != null) statusPill(s.status)],
    lines: [
      if (s.supervisionDate != null) fmtDate(s.supervisionDate)!,
      if (applicable(s.supervisorName) != null) 'With ${s.supervisorName}',
      if (s.nextSupervisionDueDate != null)
        'Next due ${fmtDate(s.nextSupervisionDueDate)}',
    ],
    notes: [
      ('Outcome', s.outcome),
      ('How you were', s.howAreYou),
      ('What has gone well', s.whatHasGoneWell),
      ('What has not gone well', s.whatHasNotGoneWell),
      ('Areas to improve', s.mainAreasForImprovement),
      ('Training and development', s.trainingAndDevelopmentProgress),
      ('Actions', s.actionsToBeTaken),
      ('Your comments', s.staffComments),
      ('Supervisor comments', s.supervisorComments),
    ],
  );

  Widget _probation(StaffProbation p) => _ReadCard(
    title: 'Probation',
    pills: [if (applicable(p.status) != null) statusPill(p.status)],
    lines: [
      if (p.startDate != null) 'Started ${fmtDate(p.startDate)}',
      if (p.signOffDate != null) 'Signed off ${fmtDate(p.signOffDate)}',
      if (applicable(p.duration) != null) 'Length ${p.duration}',
      if (applicable(p.signedOffBy) != null) 'Signed off by ${p.signedOffBy}',
    ],
    notes: [
      ('Final review', p.finalReviewNotes),
      if (p.milestones.isNotEmpty)
        ('Milestones', p.milestones.map((m) => '• $m').join('\n')),
    ],
  );

  Widget _declaration(StaffDeclaration d) => _ReadCard(
    title: applicable(d.declarationType) == null
        ? 'Declaration'
        : humanize(d.declarationType!),
    pills: [if (applicable(d.status) != null) statusPill(d.status)],
    lines: [
      if (d.dateDeclared != null) 'Declared ${fmtDate(d.dateDeclared)}',
      if (d.reviewDate != null) 'Review by ${fmtDate(d.reviewDate)}',
    ],
    notes: [
      ('Declaration', d.declarationText),
      ('Your answer', d.response),
      ('Notes', d.notes),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountControllerProvider).value;
    final cards = account == null ? <Widget>[] : _cards(account);

    Widget body;
    if (_loading && cards.isEmpty) {
      body = Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    } else {
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Text(
            'Written by the office about you. You can read these but not change them.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          if (_error != null) ...[
            NoticeBox.warn(
              'Some of this could not be loaded. Pull down to try again.',
            ),
            const SizedBox(height: 14),
          ],
          if (cards.isEmpty)
            EmptyBox('Nothing here yet', body: _empty[_area])
          else
            for (final c in cards) ...[c, const SizedBox(height: 12)],
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'From the office', showBack: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final a in _Area.values) ...[
                    _AreaChip(
                      label: _labels[a]!,
                      selected: _area == a,
                      onTap: () => setState(() => _area = a),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: body),
          ),
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.goldBg : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.line2,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.goldDeep : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// A read-only record: title, pills, short lines, then labelled paragraphs
/// (only those with something in them).
class _ReadCard extends StatelessWidget {
  final String title;
  final List<Widget> pills;
  final List<String> lines;
  final List<(String, String?)> notes;

  const _ReadCard({
    required this.title,
    required this.pills,
    required this.lines,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final filled = [
      for (final n in notes)
        if (applicable(n.$2) != null) (n.$1, n.$2!.trim()),
    ];
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.ink,
            ),
          ),
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: pills),
          ],
          if (lines.isNotEmpty) const SizedBox(height: 6),
          for (final l in lines)
            Text(l, style: TextStyle(color: AppColors.muted, fontSize: 14.5)),
          for (final n in filled) ...[
            const SizedBox(height: 10),
            Text(
              n.$1,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.ink,
              ),
            ),
            Text(n.$2, style: TextStyle(color: AppColors.ink, height: 1.35)),
          ],
        ],
      ),
    );
  }
}
