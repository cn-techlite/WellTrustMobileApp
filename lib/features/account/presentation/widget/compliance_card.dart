import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/compliance_sheet.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';

/// Right to work and compliance: every field the office records, from the NI
/// number to professional registration.
///
/// A carer can add their own record once, while none is on file. After that it
/// is read only for them: only the office can change it, so there is no edit
/// button once it exists.
///
/// The API sends null, or an "N/A - reason" sentence, for a field that does
/// not apply (no visa for a British citizen, no registration for a role that
/// needs none). Both show as "Not applicable".
class ComplianceCard extends StatelessWidget {
  final StaffCompliance? compliance;

  const ComplianceCard({super.key, required this.compliance});

  static const _na = 'Not applicable';

  /// A view button for an uploaded document, or plain text if there is none.
  Widget _file(String? url) {
    final has = applicable(url) != null;
    return Builder(
      builder: (context) => has
          ? TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(url!),
                mode: LaunchMode.externalApplication,
              ),
              icon: Icon(Icons.open_in_new, size: 18, color: AppColors.ink),
              label: Text('View', style: TextStyle(color: AppColors.ink)),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _group(String title) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.goldDeep,
      ),
    ),
  );

  Widget _status(String? v) => applicable(v) == null
      ? Text('Not set', style: TextStyle(color: AppColors.muted, fontSize: 16))
      : Align(alignment: Alignment.centerLeft, child: statusPill(v));

  /// A date row. [expires] adds a pill when the date has passed or is close.
  /// [notApplicable] says "Not applicable" instead of "Not set" when empty.
  InfoRow _date(
    String label,
    DateTime? d, {
    bool expires = false,
    bool notApplicable = false,
  }) => InfoRow(
    label,
    fmtDate(d),
    empty: (expires || notApplicable) ? _na : 'Not set',
    trailing: expires ? expiryPill(d) : null,
  );

  @override
  Widget build(BuildContext context) {
    final c = compliance;
    if (c == null) {
      // A carer can add their own once. After that only the office can change it.
      return SectionCard(
        title: 'Right to work and checks',
        actionLabel: 'Add',
        onAction: () => openStaffSheet(context, const ComplianceSheet()),
        children: const [
          SizedBox(height: 10),
          EmptyBox(
            'Nothing recorded yet',
            body:
                'You can add your own right to work and DBS details once. After that only the office can change them.',
          ),
        ],
      );
    }
    return SectionCard(
      title: 'Right to work and checks',
      children: [
        InfoRow('National Insurance number', applicable(c.niNumber)),
        InfoRow('Checked by', applicable(c.checkedBy)),

        _group('DBS'),
        InfoRow('Status', null, valueWidget: _status(c.dbsStatus)),
        InfoRow('Type', applicable(c.dbsType)),
        InfoRow('Disclosure number', applicable(c.dbsDisclosureNumber)),
        InfoRow('Update service', applicable(c.dbsUpdateServiceStatus)),
        _date('Checked on', c.dbsCheckDate),
        _date('Expires on', c.dbsExpiryDate, expires: true),
        InfoRow(
          'Certificate',
          applicable(c.dbsCertificateUrl) == null ? 'Not uploaded' : 'Uploaded',
          trailing: _file(c.dbsCertificateUrl),
        ),

        _group('Right to work'),
        InfoRow('Status', null, valueWidget: _status(c.rightToWorkStatus)),
        InfoRow('Document type', applicable(c.rightToWorkDocumentType)),
        InfoRow(
          'Document reference',
          applicable(c.rightToWorkDocumentReference),
        ),
        InfoRow('Share code', applicable(c.rightToWorkShareCode), empty: _na),
        _date('Checked on', c.rightToWorkCheckDate),
        _date('Expires on', c.rightToWorkExpiryDate, expires: true),
        InfoRow(
          'Document',
          applicable(c.rightToWorkDocumentUrl) == null
              ? 'Not uploaded'
              : 'Uploaded',
          trailing: _file(c.rightToWorkDocumentUrl),
        ),

        _group('Passport and visa'),
        InfoRow('Passport number', applicable(c.passportNumber)),
        _date('Passport expires', c.passportExpiryDate, expires: true),
        InfoRow('UK visa type', applicable(c.ukVisaType), empty: _na),
        InfoRow('Visa number', applicable(c.visaNumber), empty: _na),
        _date('Visa expires', c.visaExpiryDate, expires: true),

        _group('Professional registration'),
        InfoRow(
          'Professional body',
          applicable(c.registrationBody),
          empty: _na,
        ),
        InfoRow(
          'Registration number',
          applicable(c.registrationNumber),
          empty: _na,
        ),
        _date('Registered on', c.registrationDate, notApplicable: true),
        _date('Registration expires', c.registrationExpiryDate, expires: true),

        if (c.createdAt != null) ...[
          const SizedBox(height: 14),
          Text(
            'Recorded ${fmtDate(c.createdAt)}',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
