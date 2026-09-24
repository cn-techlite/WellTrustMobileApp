import 'package:well_trust_mobile_app/core/services/upload_service.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

/// [base] plus the record's current value, so an existing value that is not in
/// the list is kept rather than lost.
List<String> _withCurrent(List<String> base, String? current) => [
  ...base,
  if (current != null && current.isNotEmpty && !base.contains(current)) current,
];

/// Add, or edit when [id] is given.
Future<GeneralResultModel> _save(
  WidgetRef ref,
  StaffRecordRequest request, {
  String? id,
}) {
  final account = ref.read(accountControllerProvider.notifier);
  return id == null
      ? account.saveStaffRecord(request)
      : account.updateStaffRecord(id, request);
}

/// Add or edit a document. The file is uploaded first, then its URL is saved
/// with the record.
class DocumentSheet extends ConsumerStatefulWidget {
  final StaffDocument? document;

  const DocumentSheet({super.key, this.document});

  @override
  ConsumerState<DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends ConsumerState<DocumentSheet>
    with StaffSheetSaving {
  static const _categories = [
    'Identity',
    'Right to work',
    'Training',
    'Health',
    'Other',
  ];
  static const _confidentiality = ['Standard', 'Confidential'];

  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.document?.name);
  late final _notes = TextEditingController(text: widget.document?.notes);
  late String? _category = widget.document?.category;
  late String? _level = widget.document?.confidentiality ?? 'Standard';
  late DateTime? _documentDate = widget.document?.documentDate;
  late String _url = widget.document?.url ?? '';
  bool _uploading = false;
  String? _missing;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (_url.isEmpty) {
      setState(() => _missing = 'Add a photo of the document first.');
      return;
    }
    setState(() => _missing = null);
    final old = widget.document;
    submit(
      () => _save(
        ref,
        DocumentRequest(
          name: clean(_name),
          url: _url,
          category: _category ?? '',
          uploadedAt: _url == old?.url && old?.uploadedAt != null
              ? old!.uploadedAt!
              : DateTime.now(),
          notes: clean(_notes),
          confidentiality: _level ?? 'Standard',
          documentDate: _documentDate,
        ),
        id: old?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: widget.document == null ? 'Add a document' : 'Edit document',
      saving: saving,
      canSave: !_uploading,
      error: saveError ?? _missing,
      onSave: _submit,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(label: 'Name', controller: _name, required: true),
              const SizedBox(height: 14),
              StaffAttachment(
                label: 'The document *',
                folder: UploadFolder.documents,
                url: _url,
                onUrl: (u) => setState(() => _url = u),
                onBusy: (b) => setState(() => _uploading = b),
              ),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Category',
                value: _category,
                options: _withCurrent(_categories, _category),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Who can see it',
                value: _level,
                options: _withCurrent(_confidentiality, _level),
                onChanged: (v) => setState(() => _level = v),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Date on the document',
                value: _documentDate,
                onChanged: (d) => setState(() => _documentDate = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Notes',
                controller: _notes,
                multiline: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add or edit a qualification.
class QualificationSheet extends ConsumerStatefulWidget {
  final StaffQualification? qualification;

  const QualificationSheet({super.key, this.qualification});

  @override
  ConsumerState<QualificationSheet> createState() => _QualificationSheetState();
}

class _QualificationSheetState extends ConsumerState<QualificationSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.qualification?.title);
  late final _body = TextEditingController(
    text: widget.qualification?.awardingBody,
  );
  late final _category = TextEditingController(
    text: widget.qualification?.category,
  );
  late final _notes = TextEditingController(text: widget.qualification?.notes);
  late DateTime? _achieved = widget.qualification?.dateAchieved;
  late DateTime? _expiry = widget.qualification?.expiryDate;
  late String _url = widget.qualification?.documentUrl ?? '';
  bool _uploading = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _category.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    submit(
      () => _save(
        ref,
        QualificationRequest(
          title: clean(_title),
          awardingBody: clean(_body),
          dateAchieved: _achieved,
          expiryDate: _expiry,
          documentUrl: _url,
          notes: clean(_notes),
          category: clean(_category),
        ),
        id: widget.qualification?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: widget.qualification == null
          ? 'Add a qualification'
          : 'Edit qualification',
      saving: saving,
      canSave: !_uploading,
      error: saveError,
      onSave: _submit,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(
                label: 'Title',
                controller: _title,
                required: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Awarded by', controller: _body),
              const SizedBox(height: 14),
              StaffTextField(label: 'Category', controller: _category),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Date achieved',
                value: _achieved,
                onChanged: (d) => setState(() => _achieved = d),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Expires (leave empty if it does not)',
                value: _expiry,
                future: true,
                onChanged: (d) => setState(() => _expiry = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Notes',
                controller: _notes,
                multiline: true,
              ),
              const SizedBox(height: 14),
              StaffAttachment(
                label: 'Certificate or proof',
                folder: UploadFolder.certificates,
                url: _url,
                onUrl: (u) => setState(() => _url = u),
                onBusy: (b) => setState(() => _uploading = b),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add or edit a training certificate.
class CertificateSheet extends ConsumerStatefulWidget {
  final StaffCertificate? certificate;

  const CertificateSheet({super.key, this.certificate});

  @override
  ConsumerState<CertificateSheet> createState() => _CertificateSheetState();
}

class _CertificateSheetState extends ConsumerState<CertificateSheet>
    with StaffSheetSaving {
  static const _types = ['Mandatory Training', 'Additional Training', 'Other'];

  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.certificate?.name);
  late final _issuer = TextEditingController(
    text: widget.certificate?.issuingBody,
  );
  late final _reference = TextEditingController(
    text: widget.certificate?.referenceNumber,
  );
  late final _notes = TextEditingController(text: widget.certificate?.notes);
  late String? _type = widget.certificate?.type;
  late DateTime? _issued = widget.certificate?.issueDate;
  late DateTime? _expiry = widget.certificate?.expiryDate;
  late String _url = widget.certificate?.certificateUrl ?? '';
  bool _uploading = false;

  @override
  void dispose() {
    _name.dispose();
    _issuer.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    submit(
      () => _save(
        ref,
        CertificateRequest(
          name: clean(_name),
          issuingBody: clean(_issuer),
          issueDate: _issued,
          expiryDate: _expiry,
          certificateUrl: _url,
          notes: clean(_notes),
          type: _type ?? '',
          referenceNumber: clean(_reference),
        ),
        id: widget.certificate?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: widget.certificate == null
          ? 'Add a certificate'
          : 'Edit certificate',
      saving: saving,
      canSave: !_uploading,
      error: saveError,
      onSave: _submit,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(
                label: 'Name',
                controller: _name,
                required: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Type',
                value: _type,
                options: _withCurrent(_types, _type),
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Issued by', controller: _issuer),
              const SizedBox(height: 14),
              StaffTextField(label: 'Reference number', controller: _reference),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Issued on',
                value: _issued,
                onChanged: (d) => setState(() => _issued = d),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Expires on',
                value: _expiry,
                future: true,
                onChanged: (d) => setState(() => _expiry = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Notes',
                controller: _notes,
                multiline: true,
              ),
              const SizedBox(height: 14),
              StaffAttachment(
                label: 'The certificate',
                folder: UploadFolder.certificates,
                url: _url,
                onUrl: (u) => setState(() => _url = u),
                onBusy: (b) => setState(() => _uploading = b),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add or edit a competency.
class CompetencySheet extends ConsumerStatefulWidget {
  final StaffCompetency? competency;

  const CompetencySheet({super.key, this.competency});

  @override
  ConsumerState<CompetencySheet> createState() => _CompetencySheetState();
}

class _CompetencySheetState extends ConsumerState<CompetencySheet>
    with StaffSheetSaving {
  static const _statuses = ['Competent', 'In Progress', 'Not Yet Competent'];

  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.competency?.name);
  late final _category = TextEditingController(
    text: widget.competency?.category,
  );
  late final _assessor = TextEditingController(
    text: widget.competency?.assessor,
  );
  late final _notes = TextEditingController(text: widget.competency?.notes);
  late String? _status = widget.competency?.status;
  late DateTime? _assessed = widget.competency?.assessedDate;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _assessor.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    submit(
      () => _save(
        ref,
        CompetencyRequest(
          name: clean(_name),
          assessedDate: _assessed,
          notes: clean(_notes),
          category: clean(_category),
          status: _status ?? '',
          assessor: clean(_assessor),
        ),
        id: widget.competency?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: widget.competency == null ? 'Add a competency' : 'Edit competency',
      saving: saving,
      error: saveError,
      onSave: _submit,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(
                label: 'Name',
                controller: _name,
                required: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Category', controller: _category),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Status',
                value: _status,
                options: _withCurrent(_statuses, _status),
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Assessed on',
                value: _assessed,
                onChanged: (d) => setState(() => _assessed = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Assessed by', controller: _assessor),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Notes',
                controller: _notes,
                multiline: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add or edit a referee. Saving does not email them: use "Send request" on
/// the reference once it is saved.
class ReferenceSheet extends ConsumerStatefulWidget {
  final StaffReference? reference;

  const ReferenceSheet({super.key, this.reference});

  @override
  ConsumerState<ReferenceSheet> createState() => _ReferenceSheetState();
}

class _ReferenceSheetState extends ConsumerState<ReferenceSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.reference?.refereeName);
  late final _organisation = TextEditingController(
    text: widget.reference?.organisationName,
  );
  late final _jobTitle = TextEditingController(
    text: widget.reference?.jobTitle,
  );
  late final _email = TextEditingController(text: widget.reference?.email);
  late final _phone = TextEditingController(
    text: widget.reference?.phoneNumber,
  );
  late final _relationship = TextEditingController(
    text: widget.reference?.relationshipToStaff,
  );
  late final _notes = TextEditingController(text: widget.reference?.notes);
  late String? _type = widget.reference?.referenceType;
  late DateTime? _start = widget.reference?.employmentStartDate;
  late DateTime? _end = widget.reference?.employmentEndDate;
  late String _url = widget.reference?.jobDescriptionUrl ?? '';
  bool _uploading = false;
  String? _missing;

  @override
  void dispose() {
    for (final c in [
      _name,
      _organisation,
      _jobTitle,
      _email,
      _phone,
      _relationship,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (_type == null) {
      setState(() => _missing = 'Choose the type of reference.');
      return;
    }
    setState(() => _missing = null);
    submit(
      () => _save(
        ref,
        ReferenceRequest(
          referenceType: _type!,
          refereeName: clean(_name),
          organisationName: clean(_organisation),
          jobTitle: clean(_jobTitle),
          email: clean(_email),
          phoneNumber: clean(_phone),
          relationshipToStaff: clean(_relationship),
          employmentStartDate: _start,
          employmentEndDate: _end,
          status: widget.reference?.status ?? 'NotRequested',
          notes: clean(_notes),
          jobDescriptionUrl: _url,
        ),
        id: widget.reference?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: widget.reference == null ? 'Add a referee' : 'Edit referee',
      intro: 'Saving does not contact them. Send the request afterwards.',
      saving: saving,
      canSave: !_uploading,
      error: saveError ?? _missing,
      onSave: _submit,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffDropdown(
                label: 'Type of reference *',
                value: _type,
                options: _withCurrent(staffReferenceTypes, _type),
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: "Referee's name",
                controller: _name,
                required: true,
                name: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Organisation',
                controller: _organisation,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Their job title', controller: _jobTitle),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Email (needed to send the request)',
                controller: _email,
                email: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Phone number', controller: _phone),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'How they know you',
                controller: _relationship,
                maxLength: 120,
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'You worked together from',
                value: _start,
                onChanged: (d) => setState(() => _start = d),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Until',
                value: _end,
                onChanged: (d) => setState(() => _end = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Notes',
                controller: _notes,
                multiline: true,
              ),
              const SizedBox(height: 14),
              StaffAttachment(
                label: 'Job description (optional)',
                folder: UploadFolder.documents,
                url: _url,
                onUrl: (u) => setState(() => _url = u),
                onBusy: (b) => setState(() => _uploading = b),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
