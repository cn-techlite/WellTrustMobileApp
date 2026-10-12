import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'dart:convert';

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/state/providers/visit_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/account_provider.dart';

/// Shared scaffold for the simple list pages reached from the More tab.
class _MorePage extends StatelessWidget {
  final String title;
  final String lead;
  final List<Widget> children;

  const _MorePage({
    required this.title,
    required this.lead,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: title, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppText(
                  text: lead,
                  type: AppTextType.bodySmall,
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.4,
                ),
                addVerticalSpacing(1.66),
                ...children.expand((w) => [w, addVerticalSpacing(1.42)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shifts management has published as open. Carers can only ask for one.
class OpenShiftsScreen extends StatelessWidget {
  const OpenShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MorePage(
      title: 'Open shifts',
      lead:
          'Open shifts are not published through the mobile API. Your assigned work appears in Visits (Rota).',
      children: const [
        _MoreEmptyState(
          title: 'No open shifts available',
          body: 'Management-assigned shifts appear in Visits (Rota).',
        ),
      ],
    );
  }
}

String _durationLabel(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}

class MyHoursScreen extends ConsumerStatefulWidget {
  const MyHoursScreen({super.key});

  @override
  ConsumerState<MyHoursScreen> createState() => _MyHoursScreenState();
}

class _MyHoursScreenState extends ConsumerState<MyHoursScreen> {
  String tab = 'this';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadWeek);
  }

  Future<void> _loadWeek() async {
    final now = DateTime.now();
    final thisMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final start = tab == 'this'
        ? thisMonday
        : thisMonday.subtract(const Duration(days: 7));
    await ref
        .read(visitControllerProvider.notifier)
        .refresh(from: start, to: start.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    final visits =
        ref.watch(visitControllerProvider).value?.visits ??
        const <TodayVisit>[];
    final rows = _workedVisits(visits);
    final careMinutes = rows.fold<int>(0, (sum, row) => sum + row.minutes);
    final travelMinutes = rows.fold<int>(
      0,
      (sum, row) => sum + row.visit.travelMins,
    );

    return _MorePage(
      title: 'My hours',
      lead:
          'Worked out from the times you clocked in and out. Check it against your payslip.',
      children: [
        SegmentTabs(
          options: const [('this', 'This week'), ('last', 'Last week')],
          active: tab,
          onChanged: (v) {
            setState(() => tab = v);
            _loadWeek();
          },
        ),
        DesignCard(
          child: Row(
            children: [
              Expanded(
                child: _Stat(
                  _durationLabel(Duration(minutes: careMinutes)),
                  'Care time',
                ),
              ),
              Expanded(
                child: _Stat(
                  _durationLabel(Duration(minutes: travelMinutes)),
                  'Planned travel',
                ),
              ),
              Expanded(child: _Stat('${rows.length}', 'Visits')),
            ],
          ),
        ),
        if (rows.isEmpty)
          const _MoreEmptyState(
            title: 'No finished visits',
            body: 'Clock in and out of a visit and it appears here.',
          )
        else
          for (final row in rows)
            DesignCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: DateFormat('HH:mm').format(row.clockIn),
                          type: AppTextType.bodySmall,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                        AppText(
                          text: _durationLabel(Duration(minutes: row.minutes)),
                          type: AppTextType.labelMedium,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                  addHorizontalSpacing(2.56),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: row.visit.name,
                          type: AppTextType.bodySmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        AppText(
                          text:
                              '${DateFormat('EEE d MMM').format(row.clockIn)}, in ${DateFormat('HH:mm').format(row.clockIn)}, out ${DateFormat('HH:mm').format(row.clockOut)}',
                          type: AppTextType.labelMedium,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                  addHorizontalSpacing(2.05),
                  AppText(
                    text: '${row.visit.minutes} min planned',
                    type: AppTextType.labelMedium,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  List<_WorkedVisit> _workedVisits(List<TodayVisit> visits) {
    final rows = <_WorkedVisit>[];
    for (final visit in visits) {
      final clockIn = visit.checkInAt;
      final clockOut = visit.checkOutAt;
      if (clockIn == null || clockOut == null) continue;
      rows.add(_WorkedVisit(visit, clockIn, clockOut));
    }
    rows.sort((a, b) => a.clockIn.compareTo(b.clockIn));
    return rows;
  }
}

class _WorkedVisit {
  final TodayVisit visit;
  final DateTime clockIn;
  final DateTime clockOut;

  const _WorkedVisit(this.visit, this.clockIn, this.clockOut);

  int get minutes => clockOut.difference(clockIn).inMinutes.clamp(0, 1440);
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AppText(
        text: value,
        type: AppTextType.bodySmall,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        textAlign: TextAlign.center,
      ),
      AppText(
        text: label,
        type: AppTextType.bodySmall,
        color: AppColors.muted,
        fontSize: 12.5,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class AssessmentsScreen extends ConsumerStatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  ConsumerState<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends ConsumerState<AssessmentsScreen> {
  final List<_AssessmentItem> _items = [];
  final Map<String, _AssessmentAnswer> _answers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAssessments);
  }

  Future<void> _loadAssessments() async {
    try {
      final clients = (await ref.read(
        assignedClientsProvider.future,
      )).assignedClients;
      final rows = hasActiveSession
          ? await ref.read(accountControllerProvider.notifier).getAssessments()
          : <Map<String, dynamic>>[];
      final answersByClient = <String, _AssessmentAnswer>{};
      for (final row in rows) {
        final clientId = (row['residentDataModelId'] ?? row['clientId'] ?? '')
            .toString();
        if (clientId.isNotEmpty) {
          answersByClient[clientId] = _AssessmentAnswer.fromJson(row);
        }
      }
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll([
            for (final client in clients)
              _AssessmentItem(
                'assessment-${client.id}',
                'Home risk review',
                client,
                DateTime.now(),
              ),
          ]);
        _answers
          ..clear()
          ..addEntries(
            _items
                .where((item) => answersByClient.containsKey(item.client.id))
                .map(
                  (item) => MapEntry(item.id, answersByClient[item.client.id]!),
                ),
          );
      });
    } catch (_) {
      // Keep the page available; the next visit can retry the live list.
    }
  }

  @override
  Widget build(BuildContext context) {
    return _MorePage(
      title: 'Assessments',
      lead: 'Assessments management has asked you to complete.',
      children: [
        for (final assessment in _items)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: assessment.title,
                        type: AppTextType.titleSmall,
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    _assessmentPill(_answers[assessment.id]),
                  ],
                ),
                addVerticalSpacing(0.47),
                AppText(
                  text: assessment.client.name,
                  type: AppTextType.bodySmall,
                  color: AppColors.ink,
                ),
                AppText(
                  text: _assessmentDueText(assessment, _answers[assessment.id]),
                  type: AppTextType.bodySmall,
                  color: AppColors.muted,
                ),
                addVerticalSpacing(1.66),
                DesignButton(
                  _assessmentButtonLabel(_answers[assessment.id]),
                  secondary: _answers[assessment.id]?.submittedAt != null,
                  onPressed: () => _openAssessment(assessment),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openAssessment(_AssessmentItem assessment) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _AssessmentDetailsScreen(
          assessment: assessment,
          answer: _answers[assessment.id],
          onSaved: (answer, submitted) =>
              _saveAssessment(assessment, answer, submitted),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<bool> _saveAssessment(
    _AssessmentItem assessment,
    _AssessmentAnswer answer,
    bool submitted,
  ) async {
    try {
      if (!hasActiveSession) throw StateError('You must be signed in.');
      await ref.read(accountControllerProvider.notifier).createAssessment({
        'residentDataModelId': assessment.client.id,
        'assessmentType': 'ReviewAssessment',
        'title': assessment.title,
        'fullThought': answer.summary,
        'needLevel': _needLevel(answer.ratings),
        'specificNeed': null,
        'supportToBeProvided': null,
        'frequency': 'AsRequired',
        'templateKey': 'mobile-seven-area-review',
        'assessmentDate': DateFormat('yyyy-MM-dd').format(answer.reviewDate),
        'nextReviewDate': null,
        'roleCompetence': 'Care worker',
        'status': submitted ? 'Submitted' : 'Draft',
        'personInvolved': assessment.client.name,
        'riskLevel': _riskLevel(answer.ratings),
        'immediateActionRequired': null,
        'riskFactorsConcerns': null,
        'controlMeasures': null,
        'personViewsConsent': submitted
            ? 'Confirmed by the staff member.'
            : null,
        'escalationProfessionalAdvice': null,
        'outcomeCarePlanChanges': null,
        'reviewNotes': null,
        'templateFieldsJson': jsonEncode({
          'confirmed': answer.confirmed,
          'ratings': answer.ratings,
          'notes': answer.notes,
        }),
      });
      _answers[assessment.id] = answer;
      return true;
    } catch (e) {
      if (mounted) _showFormMessage(context, e.toString());
      return false;
    }
  }

  Pill _assessmentPill(_AssessmentAnswer? answer) {
    if (answer?.submittedAt != null) return Pill.ok('Submitted');
    if (answer != null) return Pill.info('Draft saved');
    return Pill.neutral('Not started');
  }

  String _assessmentButtonLabel(_AssessmentAnswer? answer) {
    if (answer?.submittedAt != null) return 'View submission';
    if (answer != null) return 'Continue assessment';
    return 'Open assessment';
  }

  String _assessmentDueText(
    _AssessmentItem assessment,
    _AssessmentAnswer? answer,
  ) {
    if (answer?.submittedAt != null) {
      return 'Submitted ${DateFormat('d MMM, HH:mm').format(answer!.submittedAt!)}';
    }
    final days = assessment.due.difference(DateTime.now()).inDays.clamp(0, 999);
    return 'Due ${DateFormat('d MMM yyyy').format(assessment.due)}, in $days ${days == 1 ? 'day' : 'days'}';
  }
}

class _AssessmentItem {
  final String id;
  final String title;
  final AssignedClient client;
  final DateTime due;

  const _AssessmentItem(this.id, this.title, this.client, this.due);
}

class _AssessmentAnswer {
  final DateTime reviewDate;
  final Map<String, String> ratings;
  final Map<String, String> notes;
  final String summary;
  final bool confirmed;
  final DateTime? submittedAt;

  const _AssessmentAnswer({
    required this.reviewDate,
    required this.ratings,
    required this.notes,
    required this.summary,
    required this.confirmed,
    this.submittedAt,
  });

  factory _AssessmentAnswer.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> fields = const {};
    try {
      final decoded = jsonDecode(
        (json['templateFieldsJson'] ?? '{}').toString(),
      );
      if (decoded is Map) fields = Map<String, dynamic>.from(decoded);
    } catch (_) {}
    final ratings = fields['ratings'] is Map
        ? Map<String, String>.from(
            (fields['ratings'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
        : <String, String>{};
    final notes = fields['notes'] is Map
        ? Map<String, String>.from(
            (fields['notes'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
        : <String, String>{};
    final submitted = (json['status'] ?? '').toString() == 'Submitted';
    return _AssessmentAnswer(
      reviewDate:
          DateTime.tryParse((json['assessmentDate'] ?? '').toString()) ??
          DateTime.now(),
      ratings: ratings,
      notes: notes,
      summary: (json['fullThought'] ?? '').toString(),
      confirmed: fields['confirmed'] == true,
      submittedAt: submitted
          ? DateTime.tryParse(
                  (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
                )?.toLocal() ??
                DateTime.now()
          : null,
    );
  }
}

String _needLevel(Map<String, String> ratings) {
  if (ratings.values.contains('Urgent concern')) return 'High';
  if (ratings.values.contains('Some concerns')) return 'Moderate';
  return 'Low';
}

String _riskLevel(Map<String, String> ratings) {
  if (ratings.values.contains('Urgent concern')) return 'High';
  if (ratings.values.contains('Some concerns')) return 'Medium';
  return 'Low';
}

class _AssessmentDetailsScreen extends StatefulWidget {
  final _AssessmentItem assessment;
  final _AssessmentAnswer? answer;
  final Future<bool> Function(_AssessmentAnswer, bool submitted) onSaved;

  const _AssessmentDetailsScreen({
    required this.assessment,
    required this.answer,
    required this.onSaved,
  });

  @override
  State<_AssessmentDetailsScreen> createState() =>
      _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<_AssessmentDetailsScreen> {
  static const _areas = [
    'Personal care',
    'Medication support',
    'Eating and drinking',
    'Moving and handling',
    'Skin and pressure areas',
    'Home safety and equipment',
    'Emotional wellbeing and company',
  ];
  late DateTime _reviewDate;
  late Map<String, String> _ratings;
  late Map<String, TextEditingController> _notes;
  late TextEditingController _summary;
  late bool _confirmed;

  bool get _submitted => widget.answer?.submittedAt != null;

  @override
  void initState() {
    super.initState();
    final answer = widget.answer;
    _reviewDate = answer?.reviewDate ?? DateTime.now();
    _ratings = {...?answer?.ratings};
    _notes = {
      for (final area in _areas)
        area: TextEditingController(text: answer?.notes[area] ?? ''),
    };
    _summary = TextEditingController(text: answer?.summary ?? '');
    _confirmed = answer?.confirmed ?? false;
  }

  @override
  void dispose() {
    for (final controller in _notes.values) {
      controller.dispose();
    }
    _summary.dispose();
    super.dispose();
  }

  _AssessmentAnswer _answer({DateTime? submittedAt}) => _AssessmentAnswer(
    reviewDate: _reviewDate,
    ratings: Map.unmodifiable(_ratings),
    notes: Map.unmodifiable({
      for (final entry in _notes.entries) entry.key: entry.value.text.trim(),
    }),
    summary: _summary.text.trim(),
    confirmed: _confirmed,
    submittedAt: submittedAt ?? widget.answer?.submittedAt,
  );

  Future<void> _saveDraft() async {
    if (await widget.onSaved(_answer(), false) && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final missingRating = _areas.any((area) => !_ratings.containsKey(area));
    final missingConcernNote = _areas.any(
      (area) =>
          _ratings[area] != null &&
          _ratings[area] != 'No concerns' &&
          _notes[area]!.text.trim().isEmpty,
    );
    if (missingRating ||
        missingConcernNote ||
        _summary.text.trim().isEmpty ||
        !_confirmed) {
      _showFormMessage(
        context,
        'Complete the highlighted questions before submitting.',
      );
      return;
    }
    final answer = _answer(submittedAt: DateTime.now());
    if (await widget.onSaved(answer, true) && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: widget.assessment.title, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_submitted)
                  NoticeBox.ok(
                    'Submitted ${DateFormat('d MMM, HH:mm').format(widget.answer!.submittedAt!)}. It can no longer be edited.',
                  )
                else
                  AppText(
                    text:
                        '${widget.assessment.client.name}. Your answers save on this phone as you type.',
                    type: AppTextType.bodySmall,
                    color: AppColors.muted,
                  ),
                addVerticalSpacing(1.42),
                DesignCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel('Date of review'),
                      addVerticalSpacing(0.71),
                      _DateField(
                        value: _reviewDate,
                        enabled: !_submitted,
                        onChanged: (value) =>
                            setState(() => _reviewDate = value),
                      ),
                      for (final area in _areas) ...[
                        addVerticalSpacing(2.13),
                        _FormLabel(area),
                        addVerticalSpacing(0.71),
                        _ChoiceSelector(
                          options: const [
                            'No concerns',
                            'Some concerns',
                            'Urgent concern',
                          ],
                          value: _ratings[area],
                          enabled: !_submitted,
                          onChanged: (value) =>
                              setState(() => _ratings[area] = value),
                        ),
                        addVerticalSpacing(0.95),
                        _DesignTextField(
                          controller: _notes[area]!,
                          hint: 'Add a note. Needed if there is a concern.',
                          maxLines: 2,
                          enabled: !_submitted,
                        ),
                      ],
                      addVerticalSpacing(2.13),
                      const _FormLabel('Overall summary'),
                      addVerticalSpacing(0.71),
                      _DesignTextField(
                        controller: _summary,
                        hint: 'Summarise the review and any actions needed',
                        maxLines: 4,
                        enabled: !_submitted,
                      ),
                      if (!_submitted) ...[
                        addVerticalSpacing(1.66),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _confirmed,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const AppText(
                            text:
                                'I confirm this assessment is accurate and complete.',
                            type: AppTextType.bodySmall,
                          ),
                          onChanged: (value) =>
                              setState(() => _confirmed = value ?? false),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DesignButton(
                                'Save draft',
                                secondary: true,
                                onPressed: _saveDraft,
                              ),
                            ),
                            addHorizontalSpacing(2.56),
                            Expanded(
                              child: DesignButton('Submit', onPressed: _submit),
                            ),
                          ],
                        ),
                      ],
                    ],
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

class IncidentReportScreen extends ConsumerStatefulWidget {
  final String? initialClientId;

  const IncidentReportScreen({super.key, this.initialClientId});

  @override
  ConsumerState<IncidentReportScreen> createState() =>
      _IncidentReportScreenState();
}

class _IncidentReportScreenState extends ConsumerState<IncidentReportScreen> {
  static const _types = [
    'Fall',
    'Medication error or concern',
    'Safeguarding concern',
    'Injury or illness',
    'Missed or late visit',
    'Could not get in',
    'Equipment fault',
    'Damage to property',
    'Near miss',
    'Other',
  ];
  static const _places = [
    "At the person's home",
    'Travelling between visits',
    'The office',
    'Somewhere else',
  ];

  String _tab = 'new';
  DateTime _when = DateTime.now();
  String? _type;
  String? _clientId;
  String? _place;
  String? _severity;
  String? _informed;
  final _what = TextEditingController();
  final _action = TextEditingController();
  final List<_IncidentRecord> _submitted = [];

  @override
  void initState() {
    super.initState();
    _clientId = widget.initialClientId;
    if (hasActiveSession) Future.microtask(_loadSubmitted);
  }

  Future<void> _loadSubmitted() async {
    try {
      final rows = await ref
          .read(accountControllerProvider.notifier)
          .getIncidents();
      if (!mounted) return;
      setState(() {
        _submitted
          ..clear()
          ..addAll(rows.map(_IncidentRecord.fromJson));
      });
    } catch (_) {
      // Keep the form usable if the records list cannot be refreshed.
    }
  }

  @override
  void dispose() {
    _what.dispose();
    _action.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_type == null ||
        _place == null ||
        _severity == null ||
        _what.text.trim().isEmpty ||
        _action.text.trim().isEmpty ||
        _informed == null) {
      _showFormMessage(context, 'Complete every required field.');
      return;
    }
    if (_when.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      _showFormMessage(context, 'The date and time cannot be in the future.');
      return;
    }

    late final _IncidentRecord saved;
    try {
      if (!hasActiveSession) throw StateError('You must be signed in.');
      final row = await ref
          .read(accountControllerProvider.notifier)
          .createIncident({
            'clientId': _clientId,
            'incidentType': _apiIncidentType(_type!),
            'severity': _severity,
            'occurredAt': _when.toIso8601String(),
            'description': _what.text.trim(),
            'immediateActionTaken': _action.text.trim(),
            'location': _place,
            'officeInformed': _informed == 'Yes'
                ? 'Office informed'
                : 'Not yet informed',
          });
      saved = _IncidentRecord.fromJson(row);
    } catch (e) {
      if (mounted) _showFormMessage(context, e.toString());
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitted.insert(0, saved);
      _tab = 'submitted';
      _resetForm();
    });
    showCustomSnackbar(
      context,
      title: 'Incident submitted',
      content: 'Incident report ${saved.reference} submitted.',
      type: SnackbarType.success,
      isTopPosition: false,
    );
  }

  void _resetForm() {
    _when = DateTime.now();
    _type = null;
    _clientId = null;
    _place = null;
    _severity = null;
    _informed = null;
    _what.clear();
    _action.clear();
  }

  @override
  Widget build(BuildContext context) {
    return _MorePage(
      title: 'Incident report',
      lead:
          'Report anything that affected the safety or wellbeing of a person you support, or a colleague.',
      children: [
        NoticeBox.danger(
          'If anyone is in immediate danger, call 999 first, then the office.',
        ),
        SegmentTabs(
          options: [
            ('new', 'New report'),
            ('submitted', 'Submitted (${_submitted.length})'),
          ],
          active: _tab,
          onChanged: (value) => setState(() => _tab = value),
        ),
        if (_tab == 'new') _incidentForm() else _incidentRecords(),
      ],
    );
  }

  Widget _incidentForm() {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormLabel('Date and time'),
          addVerticalSpacing(0.71),
          _DateTimeField(
            value: _when,
            onChanged: (value) => setState(() => _when = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('What kind of incident?'),
          addVerticalSpacing(0.71),
          GlobalSearchableDropdown<String>(
            title: 'What kind of incident?',
            hintText: 'Choose a type',
            value: _type,
            options: [
              for (final type in _types)
                SearchableDropdownOption(value: type, label: type),
            ],
            onChanged: (value) => setState(() => _type = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Who was involved?'),
          addVerticalSpacing(0.71),
          _PersonDropdown(
            value: _clientId,
            hint: 'Not about one person',
            onChanged: (value) => setState(() => _clientId = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Where did it happen?'),
          addVerticalSpacing(0.71),
          GlobalSearchableDropdown<String>(
            title: 'Where did it happen?',
            hintText: 'Choose a place',
            value: _place,
            options: [
              for (final place in _places)
                SearchableDropdownOption(value: place, label: place),
            ],
            onChanged: (value) => setState(() => _place = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('How serious was it?'),
          addVerticalSpacing(0.71),
          _ChoiceSelector(
            options: const ['Low', 'Medium', 'High', 'Critical'],
            value: _severity,
            onChanged: (value) => setState(() => _severity = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('What happened?'),
          addVerticalSpacing(0.71),
          _DesignTextField(
            controller: _what,
            hint: 'Describe the incident clearly',
            maxLines: 5,
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('What did you do straight away?'),
          addVerticalSpacing(0.71),
          _DesignTextField(
            controller: _action,
            hint:
                'For example: checked for injury, called the office, stayed until help came',
            maxLines: 4,
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Have you told the office?'),
          addVerticalSpacing(0.71),
          _ChoiceSelector(
            options: const ['Yes', 'Not yet'],
            value: _informed,
            onChanged: (value) => setState(() => _informed = value),
          ),
          addVerticalSpacing(2.13),
          DesignButton('Submit incident report', onPressed: _submit),
        ],
      ),
    );
  }

  Widget _incidentRecords() {
    if (_submitted.isEmpty) {
      return const _MoreEmptyState(
        title: 'No incident reports yet',
        body: 'Reports you submit appear here.',
      );
    }
    return Column(
      children: [
        for (final record in _submitted)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecordExpansion(
              title: record.reference,
              subtitle:
                  '${record.type}, ${DateFormat('d MMM, HH:mm').format(record.when)}',
              pill: _severityPill(record.severity),
              details: [
                if (record.clientId != null) ('Involved', record.clientName),
                ('Where', record.place),
                ('What happened', record.what),
                ('Action taken', record.action),
                ('Office told', record.informed),
                (
                  'Submitted',
                  DateFormat('d MMM yyyy, HH:mm').format(record.submittedAt),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IncidentRecord {
  final String reference;
  final DateTime when;
  final String type;
  final String? clientId;
  final String clientName;
  final String place;
  final String severity;
  final String what;
  final String action;
  final String informed;
  final DateTime submittedAt;

  const _IncidentRecord({
    required this.reference,
    required this.when,
    required this.type,
    required this.clientId,
    required this.clientName,
    required this.place,
    required this.severity,
    required this.what,
    required this.action,
    required this.informed,
    required this.submittedAt,
  });

  factory _IncidentRecord.fromJson(
    Map<String, dynamic> json,
  ) => _IncidentRecord(
    reference:
        (json['reference'] ?? json['referenceNumber'] ?? json['id'] ?? '')
            .toString(),
    when:
        DateTime.tryParse((json['occurredAt'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
    type: (json['incidentType'] ?? '').toString(),
    clientId: json['clientId']?.toString(),
    clientName: (json['clientName'] ?? 'Assigned client').toString(),
    place: (json['location'] ?? '').toString(),
    severity: (json['severity'] ?? '').toString(),
    what: (json['description'] ?? '').toString(),
    action: (json['immediateActionTaken'] ?? '').toString(),
    informed: (json['officeInformed'] ?? '').toString(),
    submittedAt:
        DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
  );
}

String _apiIncidentType(String label) => switch (label) {
  'Medication error or concern' => 'MedicationError',
  'Safeguarding concern' => 'Safeguarding',
  'Injury or illness' => 'Injury',
  'Missed or late visit' => 'MissedVisit',
  'Damage to property' => 'PropertyDamage',
  'Near miss' => 'NearMiss',
  'Could not get in' || 'Equipment fault' || 'Other' => 'Other',
  _ => label,
};

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  static const _raisedByOptions = [
    'Person we support',
    'Relative or visitor',
    'Colleague',
    'Other',
  ];
  static const _categories = [
    'Quality of care',
    'Late or missed visit',
    'Staff conduct',
    'Communication',
    'Other',
  ];

  String _tab = 'new';
  String? _raisedBy;
  String? _clientId;
  String? _category;
  DateTime _when = DateTime.now();
  final _details = TextEditingController();
  final List<_ComplaintRecord> _submitted = [];

  @override
  void initState() {
    super.initState();
    if (hasActiveSession) Future.microtask(_loadSubmitted);
  }

  Future<void> _loadSubmitted() async {
    try {
      final rows = await ref
          .read(accountControllerProvider.notifier)
          .getComplaints();
      if (!mounted) return;
      setState(() {
        _submitted
          ..clear()
          ..addAll(rows.map(_ComplaintRecord.fromJson));
      });
    } catch (_) {
      // Keep the form usable if the records list cannot be refreshed.
    }
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_raisedBy == null ||
        _category == null ||
        _details.text.trim().isEmpty) {
      _showFormMessage(context, 'Complete every required field.');
      return;
    }
    late final _ComplaintRecord saved;
    try {
      if (!hasActiveSession) throw StateError('You must be signed in.');
      final row = await ref
          .read(accountControllerProvider.notifier)
          .createComplaint({
            'clientId': _clientId,
            'isAnonymous': false,
            'complainantName': null,
            'complainantContact': null,
            'raisedBy': _raisedBy,
            'occurredOn': DateFormat('yyyy-MM-dd').format(_when),
            'category': _category,
            'details': _details.text.trim(),
            'summary': null,
            'fullDetails': null,
            'priority': 'Medium',
            'safeguardingConcern': false,
            'safeguardingDetails': null,
          });
      saved = _ComplaintRecord.fromJson(row);
    } catch (e) {
      if (mounted) _showFormMessage(context, e.toString());
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitted.insert(0, saved);
      _tab = 'submitted';
      _raisedBy = null;
      _clientId = null;
      _category = null;
      _when = DateTime.now();
      _details.clear();
    });
    showCustomSnackbar(
      context,
      title: 'Complaint submitted',
      content: 'Complaint ${saved.reference} submitted.',
      type: SnackbarType.success,
      isTopPosition: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MorePage(
      title: 'Complaints',
      lead: 'Record a complaint or concern.',
      children: [
        SegmentTabs(
          options: [
            ('new', 'New complaint'),
            ('submitted', 'Submitted (${_submitted.length})'),
          ],
          active: _tab,
          onChanged: (value) => setState(() => _tab = value),
        ),
        if (_tab == 'new') _complaintForm() else _complaintRecords(),
      ],
    );
  }

  Widget _complaintForm() {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormLabel('Who raised it?'),
          addVerticalSpacing(0.71),
          GlobalSearchableDropdown<String>(
            title: 'Who raised it?',
            hintText: 'Choose one',
            value: _raisedBy,
            options: [
              for (final option in _raisedByOptions)
                SearchableDropdownOption(value: option, label: option),
            ],
            onChanged: (value) => setState(() => _raisedBy = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Who is it about?'),
          addVerticalSpacing(0.71),
          _PersonDropdown(
            value: _clientId,
            hint: 'Not about one person',
            onChanged: (value) => setState(() => _clientId = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Category'),
          addVerticalSpacing(0.71),
          GlobalSearchableDropdown<String>(
            title: 'Category',
            hintText: 'Choose a category',
            value: _category,
            options: [
              for (final category in _categories)
                SearchableDropdownOption(value: category, label: category),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Date it happened'),
          addVerticalSpacing(0.71),
          _DateField(
            value: _when,
            onChanged: (value) => setState(() => _when = value),
          ),
          addVerticalSpacing(1.66),
          const _FormLabel('Complaint details'),
          addVerticalSpacing(0.71),
          _DesignTextField(
            controller: _details,
            hint: 'Enter the complaint details',
            maxLines: 6,
          ),
          addVerticalSpacing(2.13),
          DesignButton('Submit complaint', onPressed: _submit),
        ],
      ),
    );
  }

  Widget _complaintRecords() {
    if (_submitted.isEmpty) {
      return const _MoreEmptyState(
        title: 'No complaints recorded',
        body: 'Complaints you submit appear here.',
      );
    }
    return Column(
      children: [
        for (final record in _submitted)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecordExpansion(
              title: record.reference,
              subtitle:
                  '${record.category}, ${DateFormat('d MMM yyyy').format(record.when)}',
              pill: Pill.info('Submitted'),
              details: [
                ('Raised by', record.raisedBy),
                if (record.clientId != null) ('About', record.clientName),
                ('Details', record.details),
                (
                  'Submitted',
                  DateFormat('d MMM yyyy, HH:mm').format(record.submittedAt),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ComplaintRecord {
  final String reference;
  final String raisedBy;
  final String? clientId;
  final String clientName;
  final String category;
  final DateTime when;
  final String details;
  final DateTime submittedAt;

  const _ComplaintRecord({
    required this.reference,
    required this.raisedBy,
    required this.clientId,
    required this.clientName,
    required this.category,
    required this.when,
    required this.details,
    required this.submittedAt,
  });

  factory _ComplaintRecord.fromJson(Map<String, dynamic> json) =>
      _ComplaintRecord(
        reference:
            (json['reference'] ?? json['referenceNumber'] ?? json['id'] ?? '')
                .toString(),
        raisedBy: (json['raisedBy'] ?? json['complainantRelationship'] ?? '')
            .toString(),
        clientId: json['clientId']?.toString(),
        clientName: (json['clientName'] ?? 'Assigned client').toString(),
        category: (json['category'] ?? '').toString(),
        when:
            DateTime.tryParse((json['occurredOn'] ?? '').toString()) ??
            DateTime.now(),
        details: (json['details'] ?? json['fullDetails'] ?? '').toString(),
        submittedAt:
            DateTime.tryParse(
              (json['createdAt'] ?? '').toString(),
            )?.toLocal() ??
            DateTime.now(),
      );
}

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) => AppText(
    text: text,
    type: AppTextType.bodySmall,
    color: AppColors.ink,
    fontWeight: FontWeight.w700,
  );
}

class _PersonDropdown extends ConsumerWidget {
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  const _PersonDropdown({
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients =
        ref.watch(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];
    return GlobalSearchableDropdown<String>(
      title: 'Choose a person',
      hintText: hint,
      value: value,
      options: [
        for (final client in clients)
          SearchableDropdownOption(value: client.id, label: client.name),
      ],
      emptyMessage: 'No residents or clients are currently assigned to you.',
      onChanged: onChanged,
    );
  }
}

class _DesignTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool enabled;

  const _DesignTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalTextField(
      fieldName: hint,
      keyBoardType: maxLines == 1
          ? TextInputType.text
          : TextInputType.multiline,
      textController: controller,
      enabled: enabled,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : 2,
      maxLength: 500,
      isOptional: true,
      removeSpace: false,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class _ChoiceSelector extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _ChoiceSelector({
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: AppText(
              text: option,
              type: AppTextType.labelMedium,
              color: value == option ? AppColors.onPrimary : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            selected: value == option,
            onSelected: enabled ? (_) => onChanged(option) : null,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: value == option ? AppColors.primary : AppColors.line2,
            ),
            showCheckmark: false,
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  const _DateField({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  Future<void> _pick(BuildContext context) async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: value.isAfter(today) ? today : value,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) => _PickerField(
    label: DateFormat('dd/MM/yyyy').format(value),
    icon: Icons.calendar_today_outlined,
    enabled: enabled,
    onTap: () => _pick(context),
  );
}

class _DateTimeField extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeField({required this.value, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value.isAfter(now) ? now : value,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) => _PickerField(
    label: DateFormat('dd/MM/yyyy, HH:mm').format(value),
    icon: Icons.calendar_today_outlined,
    onTap: () => _pick(context),
  );
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.surface : AppColors.bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line2, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  text: label,
                  type: AppTextType.bodySmall,
                  color: AppColors.ink,
                ),
              ),
              Icon(icon, color: AppColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreEmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _MoreEmptyState({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        AppText(
          text: title,
          type: AppTextType.bodySmall,
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
        ),
        addVerticalSpacing(0.47),
        AppText(
          text: body,
          type: AppTextType.bodySmall,
          color: AppColors.muted,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _RecordExpansion extends StatelessWidget {
  final String title;
  final String subtitle;
  final Pill pill;
  final List<(String, String)> details;

  const _RecordExpansion({
    required this.title,
    required this.subtitle,
    required this.pill,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    type: AppTextType.bodySmall,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  AppText(
                    text: subtitle,
                    type: AppTextType.labelMedium,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
            pill,
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                for (final detail in details)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 105,
                          child: AppText(
                            text: detail.$1,
                            type: AppTextType.labelMedium,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: detail.$2,
                            type: AppTextType.bodySmall,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
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

Pill _severityPill(String severity) => switch (severity) {
  'High' => Pill.bad(severity),
  'Medium' => Pill.warn(severity),
  _ => Pill.ok(severity),
};

void _showFormMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: AppText(text: message, type: AppTextType.bodySmall),
    ),
  );
}
