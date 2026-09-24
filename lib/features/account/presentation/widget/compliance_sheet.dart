import 'package:well_trust_mobile_app/core/services/upload_service.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';

/// Add the carer's own Right to Work and DBS record (POST
/// admin-staff-records/compliance).
///
/// A carer can do this once, when there is no record on file. After it is
/// saved only the office can change it, so the form says so and asks the carer
/// to confirm before saving.
class ComplianceSheet extends ConsumerStatefulWidget {
  const ComplianceSheet({super.key});

  @override
  ConsumerState<ComplianceSheet> createState() => _ComplianceSheetState();
}

class _ComplianceSheetState extends ConsumerState<ComplianceSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();

  final _ni = TextEditingController();
  final _dbsType = TextEditingController();
  final _dbsDisclosure = TextEditingController();
  final _dbsUpdateService = TextEditingController();
  final _rtwReference = TextEditingController();
  final _shareCode = TextEditingController();
  final _passport = TextEditingController();
  final _visaType = TextEditingController();
  final _visaNumber = TextEditingController();
  final _regBody = TextEditingController();
  final _regNumber = TextEditingController();

  String _dbsStatus = 'NotProvided';
  String _rtwStatus = 'NotProvided';
  String? _rtwDocumentType;
  DateTime? _dbsChecked;
  DateTime? _dbsExpiry;
  DateTime? _rtwChecked;
  DateTime? _rtwExpiry;
  DateTime? _passportExpiry;
  DateTime? _visaExpiry;
  DateTime? _regDate;
  DateTime? _regExpiry;
  String _dbsCertificate = '';
  String _rtwDocument = '';

  /// How many file uploads are running. Saving waits for them.
  int _uploads = 0;

  @override
  void dispose() {
    for (final c in [
      _ni,
      _dbsType,
      _dbsDisclosure,
      _dbsUpdateService,
      _rtwReference,
      _shareCode,
      _passport,
      _visaType,
      _visaNumber,
      _regBody,
      _regNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _busy(bool on) => setState(() => _uploads += on ? 1 : -1);

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Save your right to work record?',
          style: TextStyle(color: AppColors.ink),
        ),
        content: Text(
          'You cannot change it after you save. Only the office can. Check that everything is right first.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Go back', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Save', style: TextStyle(color: AppColors.ink)),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;

    submit(
      () => ref
          .read(accountControllerProvider.notifier)
          .saveStaffRecord(
            ComplianceRequest(
              niNumber: clean(_ni),
              dbsStatus: _dbsStatus,
              dbsCertificateUrl: _dbsCertificate,
              dbsCheckDate: _dbsChecked,
              dbsExpiryDate: _dbsExpiry,
              dbsType: clean(_dbsType),
              dbsDisclosureNumber: clean(_dbsDisclosure),
              dbsUpdateServiceStatus: clean(_dbsUpdateService),
              rightToWorkStatus: _rtwStatus,
              rightToWorkDocumentUrl: _rtwDocument,
              rightToWorkExpiryDate: _rtwExpiry,
              rightToWorkCheckDate: _rtwChecked,
              rightToWorkShareCode: clean(_shareCode),
              rightToWorkDocumentType: _rtwDocumentType,
              rightToWorkDocumentReference: clean(_rtwReference),
              ukVisaType: clean(_visaType),
              visaNumber: clean(_visaNumber),
              visaExpiryDate: _visaExpiry,
              passportNumber: clean(_passport),
              passportExpiryDate: _passportExpiry,
              registrationBody: clean(_regBody),
              registrationNumber: clean(_regNumber),
              registrationDate: _regDate,
              registrationExpiryDate: _regExpiry,
            ),
          ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.goldDeep,
      ),
    ),
  );

  Widget _gap() => const SizedBox(height: 14);

  StaffDateField _date(
    String label,
    DateTime? value,
    ValueChanged<DateTime?> set, {
    bool future = false,
  }) => StaffDateField(
    label: label,
    value: value,
    future: future,
    onChanged: (d) => setState(() => set(d)),
  );

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: 'Right to work and DBS',
      intro:
          'You can add this once. After you save, only the office can change it.',
      saveLabel: 'Save my record',
      saving: saving,
      canSave: _uploads == 0,
      error: saveError,
      onSave: _save,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(
                label: 'National Insurance number',
                controller: _ni,
              ),

              _gap(),
              _heading('DBS'),
              _gap(),
              StaffDropdown(
                label: 'DBS status',
                value: _dbsStatus,
                options: staffDbsStatuses,
                display: humanize,
                onChanged: (v) => setState(() => _dbsStatus = v ?? _dbsStatus),
              ),
              _gap(),
              StaffTextField(
                label: 'DBS type (e.g. Enhanced)',
                controller: _dbsType,
              ),
              _gap(),
              StaffTextField(
                label: 'Disclosure number',
                controller: _dbsDisclosure,
              ),
              _gap(),
              StaffTextField(
                label: 'Update service status (e.g. Registered)',
                controller: _dbsUpdateService,
              ),
              _gap(),
              _date('DBS checked on', _dbsChecked, (d) => _dbsChecked = d),
              _gap(),
              _date(
                'DBS expires on',
                _dbsExpiry,
                (d) => _dbsExpiry = d,
                future: true,
              ),
              _gap(),
              StaffAttachment(
                label: 'DBS certificate',
                folder: UploadFolder.certificates,
                url: _dbsCertificate,
                onUrl: (u) => setState(() => _dbsCertificate = u),
                onBusy: _busy,
              ),

              _gap(),
              _heading('Right to work'),
              _gap(),
              StaffDropdown(
                label: 'Right to work status',
                value: _rtwStatus,
                options: staffRightToWorkStatuses,
                display: humanize,
                onChanged: (v) => setState(() => _rtwStatus = v ?? _rtwStatus),
              ),
              _gap(),
              StaffDropdown(
                label: 'Document type',
                value: _rtwDocumentType,
                options: staffRightToWorkDocumentTypes,
                onChanged: (v) => setState(() => _rtwDocumentType = v),
              ),
              _gap(),
              StaffTextField(
                label: 'Document reference',
                controller: _rtwReference,
              ),
              _gap(),
              StaffTextField(label: 'Share code', controller: _shareCode),
              _gap(),
              _date('Date checked', _rtwChecked, (d) => _rtwChecked = d),
              _gap(),
              _date(
                'Right to work expires on',
                _rtwExpiry,
                (d) => _rtwExpiry = d,
                future: true,
              ),
              _gap(),
              StaffAttachment(
                label: 'Right to work document',
                folder: UploadFolder.documents,
                url: _rtwDocument,
                onUrl: (u) => setState(() => _rtwDocument = u),
                onBusy: _busy,
              ),

              _gap(),
              _heading('Passport and visa'),
              _gap(),
              StaffTextField(label: 'Passport number', controller: _passport),
              _gap(),
              _date(
                'Passport expires on',
                _passportExpiry,
                (d) => _passportExpiry = d,
                future: true,
              ),
              _gap(),
              StaffTextField(label: 'UK visa type', controller: _visaType),
              _gap(),
              StaffTextField(label: 'Visa number', controller: _visaNumber),
              _gap(),
              _date(
                'Visa expires on',
                _visaExpiry,
                (d) => _visaExpiry = d,
                future: true,
              ),

              _gap(),
              _heading('Professional registration'),
              _gap(),
              StaffTextField(label: 'Professional body', controller: _regBody),
              _gap(),
              StaffTextField(
                label: 'Registration number',
                controller: _regNumber,
              ),
              _gap(),
              _date('Registered on', _regDate, (d) => _regDate = d),
              _gap(),
              _date(
                'Registration expires on',
                _regExpiry,
                (d) => _regExpiry = d,
                future: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
