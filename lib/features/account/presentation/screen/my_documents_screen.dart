import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/state_model/account_state_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_sheets.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// The carer's own documents, certificates, qualifications and competencies.
/// They can add, edit and delete their own. Files go through the app's upload
/// service and the URL is saved with the record.
class DocumentsScreen extends ConsumerStatefulWidget {
  /// Which list to open first.
  final StaffRecordKind initialTab;

  const DocumentsScreen({
    super.key,
    this.initialTab = StaffRecordKind.documents,
  });

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  late StaffRecordKind _tab = widget.initialTab;

  static const _tabs = [
    (StaffRecordKind.documents, 'Documents'),
    (StaffRecordKind.certificates, 'Certificates'),
    (StaffRecordKind.qualifications, 'Qualifications'),
    (StaffRecordKind.competencies, 'Competencies'),
    (StaffRecordKind.references, 'References'),
  ];

  final _chipKeys = {for (final t in _tabs) t.$1: GlobalKey()};

  /// Scrolls the chip row so the selected chip is in view.
  void _reveal() {
    final chip = _chipKeys[_tab]?.currentContext;
    if (chip != null) {
      Scrollable.ensureVisible(
        chip,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    Future.microtask(() async {
      final account = ref.read(accountControllerProvider.notifier);
      await account.getAccount();
      await account.loadReferences();
    });
  }

  int _count(AccountStateModel? a, StaffRecordKind k) {
    final u = a?.userData;
    return switch (k) {
      StaffRecordKind.documents => u?.documents.length ?? 0,
      StaffRecordKind.certificates => u?.certificates.length ?? 0,
      StaffRecordKind.qualifications => u?.qualifications.length ?? 0,
      StaffRecordKind.competencies => u?.competencies.length ?? 0,
      StaffRecordKind.references => a?.references.length ?? 0,
      _ => 0,
    };
  }

  Widget _sheetFor(StaffRecordKind kind, {Object? existing}) => switch (kind) {
    StaffRecordKind.documents => DocumentSheet(
      document: existing as StaffDocument?,
    ),
    StaffRecordKind.certificates => CertificateSheet(
      certificate: existing as StaffCertificate?,
    ),
    StaffRecordKind.qualifications => QualificationSheet(
      qualification: existing as StaffQualification?,
    ),
    StaffRecordKind.references => ReferenceSheet(
      reference: existing as StaffReference?,
    ),
    _ => CompetencySheet(competency: existing as StaffCompetency?),
  };

  Future<void> _delete(StaffRecordKind kind, String? id, String name) async {
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete ${kind.label.toLowerCase()}?',
          style: TextStyle(color: AppColors.ink),
        ),
        content: Text(
          '"$name" will be removed from your record.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Delete', style: TextStyle(color: AppColors.rose)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final result = await ref
        .read(accountControllerProvider.notifier)
        .deleteStaffRecord(kind, id);
    if (!mounted) return;
    showCustomSnackbar(
      context,
      title: result.isSuccess ? 'Deleted' : 'Not deleted',
      content: result.message ?? '',
      type: result.isSuccess ? SnackbarType.success : SnackbarType.error,
      isTopPosition: false,
    );
  }

  Future<void> _sendRequest(StaffReference r) async {
    final id = r.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Ask for the reference?',
          style: TextStyle(color: AppColors.ink),
        ),
        content: Text(
          'We will email ${r.refereeName ?? 'them'} at ${r.email} with a link to give your reference.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Send', style: TextStyle(color: AppColors.ink)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final result = await ref
        .read(accountControllerProvider.notifier)
        .sendReferenceRequest(id);
    if (!mounted) return;
    showCustomSnackbar(
      context,
      title: result.isSuccess ? 'Request sent' : 'Not sent',
      content: result.message ?? '',
      type: result.isSuccess ? SnackbarType.success : SnackbarType.error,
      isTopPosition: false,
    );
  }

  Future<void> _view(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      showCustomSnackbar(
        context,
        title: 'Cannot open the file',
        content: 'Try again later.',
        type: SnackbarType.error,
        isTopPosition: false,
      );
    }
  }

  _RecordCard _card({
    required String title,
    required StaffRecordKind kind,
    required String? id,
    required Object record,
    String? url,
    List<Widget> pills = const [],
    List<String?> lines = const [],
    List<Widget> extraActions = const [],
  }) => _RecordCard(
    title: title,
    pills: pills,
    lines: [
      for (final l in lines)
        if (l != null && l.trim().isNotEmpty) l,
    ],
    extraActions: extraActions,
    onView: url == null || url.isEmpty ? null : () => _view(url),
    onEdit: () => openStaffSheet(context, _sheetFor(kind, existing: record)),
    onDelete: () => _delete(kind, id, title),
  );

  List<Widget> _cards(AccountStateModel account) {
    final u = account.userData!;
    switch (_tab) {
      case StaffRecordKind.documents:
        return [
          for (final d in u.documents)
            _card(
              title: d.name ?? 'Document',
              kind: _tab,
              id: d.id,
              record: d,
              url: d.url,
              pills: [
                if (applicable(d.category) != null) Pill.neutral(d.category!),
                if (d.confidentiality != null &&
                    d.confidentiality != 'Standard')
                  Pill.warn(d.confidentiality!),
              ],
              lines: [
                if (d.documentDate != null) 'Dated ${fmtDate(d.documentDate)}',
                if (d.uploadedAt != null) 'Added ${fmtDate(d.uploadedAt)}',
                d.notes,
              ],
            ),
        ];
      case StaffRecordKind.certificates:
        return [
          for (final c in u.certificates)
            _card(
              title: c.name ?? 'Certificate',
              kind: _tab,
              id: c.id,
              record: c,
              url: c.certificateUrl,
              pills: [
                if (applicable(c.type) != null) Pill.neutral(c.type!),
                ?expiryPill(c.expiryDate),
              ],
              lines: [
                c.issuingBody,
                if (c.issueDate != null) 'Issued ${fmtDate(c.issueDate)}',
                if (c.expiryDate != null) 'Expires ${fmtDate(c.expiryDate)}',
                if (applicable(c.referenceNumber) != null)
                  'Ref ${c.referenceNumber}',
                c.notes,
              ],
            ),
        ];
      case StaffRecordKind.qualifications:
        return [
          for (final q in u.qualifications)
            _card(
              title: q.title ?? 'Qualification',
              kind: _tab,
              id: q.id,
              record: q,
              url: q.documentUrl,
              pills: [
                if (applicable(q.category) != null) Pill.neutral(q.category!),
                ?expiryPill(q.expiryDate),
              ],
              lines: [
                q.awardingBody,
                if (q.dateAchieved != null)
                  'Achieved ${fmtDate(q.dateAchieved)}',
                q.expiryDate == null
                    ? 'Does not expire'
                    : 'Expires ${fmtDate(q.expiryDate)}',
                q.notes,
              ],
            ),
        ];
      case StaffRecordKind.references:
        return [
          for (final r in account.references)
            _card(
              title: r.refereeName ?? 'Referee',
              kind: _tab,
              id: r.id,
              record: r,
              url: r.jobDescriptionUrl,
              pills: [
                if (applicable(r.referenceType) != null)
                  Pill.neutral(humanize(r.referenceType!)),
                if (applicable(r.status) != null) statusPill(r.status),
              ],
              lines: [
                if (applicable(r.jobTitle) != null ||
                    applicable(r.organisationName) != null)
                  [
                    applicable(r.jobTitle),
                    applicable(r.organisationName),
                  ].whereType<String>().join(', '),
                r.relationshipToStaff,
                r.email,
                r.phoneNumber,
                if (r.requestedAt != null)
                  'Requested ${fmtDate(r.requestedAt)}',
                if (r.receivedAt != null) 'Received ${fmtDate(r.receivedAt)}',
                r.notes,
              ],
              extraActions: [
                if ((r.email ?? '').isNotEmpty && r.status != 'Received')
                  DesignButton(
                    r.status == 'NotRequested' || r.status == null
                        ? 'Send request'
                        : 'Send again',
                    small: true,
                    icon: Icons.mail_outline,
                    onPressed: () => _sendRequest(r),
                  ),
              ],
            ),
        ];
      default:
        return [
          for (final c in u.competencies)
            _card(
              title: c.name ?? 'Competency',
              kind: _tab,
              id: c.id,
              record: c,
              pills: [
                if (applicable(c.status) != null) statusPill(c.status),
                if (applicable(c.category) != null) Pill.neutral(c.category!),
              ],
              lines: [
                if (c.assessedDate != null)
                  'Assessed ${fmtDate(c.assessedDate)}',
                if (applicable(c.assessor) != null) 'By ${c.assessor}',
                c.notes,
              ],
            ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(accountControllerProvider);
    final account = async.value;
    final user = account?.userData;
    final noun = _tab.label.toLowerCase();

    Widget body;
    if (user != null) {
      final cards = _cards(account!);
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          DesignButton(
            'Add a $noun',
            icon: Icons.add,
            onPressed: () => openStaffSheet(context, _sheetFor(_tab)),
          ),
          const SizedBox(height: 14),
          if (cards.isEmpty)
            EmptyBox(
              'No ${_tab == StaffRecordKind.competencies ? 'competencies' : '${noun}s'} yet',
              body: 'Anything you add appears here and the office can see it.',
            )
          else
            for (final c in cards) ...[c, const SizedBox(height: 12)],
        ],
      );
    } else if (!async.hasError) {
      body = Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyBox('Could not load your records', body: async.error.toString()),
          const SizedBox(height: 14),
          DesignButton(
            'Try again',
            onPressed: () =>
                ref.read(accountControllerProvider.notifier).refreshAccount(),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'My documents', showBack: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final t in _tabs) ...[
                    _KindChip(
                      key: _chipKeys[t.$1],
                      label: '${t.$2} (${_count(account, t.$1)})',
                      selected: _tab == t.$1,
                      onTap: () {
                        setState(() => _tab = t.$1);
                        _reveal();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final account = ref.read(accountControllerProvider.notifier);
                await account.refreshAccount();
                await account.loadReferences();
              },
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KindChip({
    super.key,
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

class _RecordCard extends StatelessWidget {
  final String title;
  final List<Widget> pills;
  final List<String> lines;
  final List<Widget> extraActions;
  final VoidCallback? onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.title,
    required this.pills,
    required this.lines,
    required this.extraActions,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...extraActions,
              if (onView != null)
                DesignButton(
                  'View file',
                  small: true,
                  secondary: true,
                  icon: Icons.open_in_new,
                  onPressed: onView,
                ),
              DesignButton(
                'Edit',
                small: true,
                secondary: true,
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              DesignButton(
                'Delete',
                small: true,
                secondary: true,
                icon: Icons.delete_outline,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
