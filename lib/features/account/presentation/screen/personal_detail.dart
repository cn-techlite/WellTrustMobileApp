import 'package:well_trust_mobile_app/core/helpers/endpoints.dart';
import 'package:well_trust_mobile_app/core/services/upload_service.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/office_records_screen.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/compliance_card.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_detail_sheets.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// The signed-in carer's own record: what they can edit, and what the office
/// keeps for them (shown read only).
class AccountDetailsPage extends ConsumerStatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(accountControllerProvider.notifier).getAccount();
    });
  }

  ImageProvider? _photo(RegisterResponseModel user) {
    final image = user.imagePath?.trim() ?? '';
    if (image.isEmpty) return null;
    // The API sends a path on its own server, e.g. /uploads/staff-photos/x.jpg.
    if (image.startsWith('/')) {
      final host = Endpoints.appBaseUrl.replaceFirst(RegExp(r'/+$'), '');
      return NetworkImage('$host$image');
    }
    return NetworkImage(image);
  }

  String _initials(RegisterResponseModel user) {
    final f = (user.firstName ?? '').trim();
    final s = (user.surName ?? '').trim();
    final out = '${f.isEmpty ? '' : f[0]}${s.isEmpty ? '' : s[0]}';
    return out.isEmpty ? '?' : out.toUpperCase();
  }

  Future<void> _changePhoto() async {
    if (_uploadingPhoto) return;
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _uploadingPhoto = true);
      final url = await ApiService.upload(
        image.path,
        folder: UploadFolder.images,
      );

      final result = await ref
          .read(accountControllerProvider.notifier)
          .updateProfile(UpdateStaffRequest(imagePath: url));
      _toast(
        result.isSuccess ? 'Photo saved' : 'Photo not saved',
        result.message ?? '',
        result.isSuccess,
      );
    } on UploadException catch (e) {
      _toast('Photo not saved', e.message, false);
    } catch (_) {
      _toast(
        'Photo not saved',
        'Something went wrong. Please try again.',
        false,
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _toast(String title, String content, bool ok) {
    if (!mounted) return;
    showCustomSnackbar(
      context,
      title: title,
      content: content,
      type: ok ? SnackbarType.success : SnackbarType.error,
      isTopPosition: false,
    );
  }

  String _mask(String? v) {
    final t = v?.trim() ?? '';
    if (t.length <= 4) return t;
    return '••••${t.substring(t.length - 4)}';
  }

  /// Joins the parts with commas, skipping empty ones and any part the text
  /// already contains (the API often puts the town inside the address line).
  String? _join(Iterable<String?> parts) {
    var out = '';
    for (final p in parts) {
      final t = p?.trim() ?? '';
      if (t.isEmpty || out.toLowerCase().contains(t.toLowerCase())) continue;
      out = out.isEmpty ? t : '$out, $t';
    }
    return out.isEmpty ? null : out;
  }

  Widget _header(RegisterResponseModel user) {
    final name = '${user.firstName ?? ''} ${user.surName ?? ''}'.trim();
    return DesignCard(
      child: Row(
        children: [
          GestureDetector(
            onTap: _changePhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.gold,
                  foregroundImage: _photo(user),
                  onForegroundImageError: _photo(user) == null
                      ? null
                      : (_, _) {},
                  child: _uploadingPhoto
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.navy,
                        )
                      : Text(
                          _initials(user),
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Staff member' : name,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.ink,
                  ),
                ),
                if (applicable(user.staffCode) != null)
                  Text(
                    'Staff code ${user.staffCode}',
                    style: TextStyle(color: AppColors.muted),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (applicable(user.staffStatus) != null)
                      statusPill(user.staffStatus),
                    if (applicable(user.complianceStatus) != null)
                      statusPill(user.complianceStatus),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(RegisterResponseModel user) {
    final profile = user.profile;
    final contact = user.emergencyContact;
    final c = user.compliance;
    final pay = user.employmentPay;
    final letter = user.appointmentLetter;

    return [
      _header(user),
      SectionCard(
        title: 'My details',
        actionLabel: 'Edit',
        onAction: () => openStaffSheet(context, EditDetailsSheet(user: user)),
        children: [
          InfoRow('Email', user.email),
          InfoRow('Phone number', user.phoneNo),
          InfoRow('Sex', user.sex),
          InfoRow('Date of birth', fmtDate(user.dateOfBirth)),
          InfoRow('Nationality', user.nationality),
          InfoRow('Address', _join([user.address, user.locality, user.state])),
          InfoRow(
            'Next of kin',
            _join([user.nextOfKin, user.nextOfKinPhoneNo]),
          ),
          InfoRow('Reference 1', user.referenceEmail),
          InfoRow('Reference 2', user.referenceEmail2),
          InfoRow('National Insurance number', user.insuranceNo),
          InfoRow('DBS number', user.dbsCode),
          InfoRow(
            'Bank',
            _join([
              user.bankAccName,
              if ((user.bankAccNo ?? '').isNotEmpty) _mask(user.bankAccNo),
              if ((user.bankSortCode ?? '').isNotEmpty)
                'sort code ${user.bankSortCode}',
            ]),
          ),
          InfoRow('Branch', user.branch),
        ],
      ),
      SectionCard(
        title: 'Job and home address',
        actionLabel: profile == null ? 'Add' : 'Edit',
        onAction: () => openStaffSheet(
          context,
          JobDetailsSheet(
            profile: profile,
            fallbackDateOfBirth: user.dateOfBirth,
          ),
        ),
        children: profile == null
            ? [
                const SizedBox(height: 10),
                const EmptyBox(
                  'Nothing added yet',
                  body: 'Add your job title and home address.',
                ),
              ]
            : [
                InfoRow('Job title', profile.jobTitle),
                InfoRow(
                  'Employment type',
                  profile.employmentType == null
                      ? null
                      : employmentTypeLabel(profile.employmentType!),
                ),
                InfoRow(
                  'Gender',
                  profile.gender == null ? null : genderLabel(profile.gender!),
                ),
                InfoRow('Date of birth', fmtDate(profile.dateOfBirth)),
                InfoRow(
                  'Home address',
                  _join([
                    profile.addressLine1,
                    profile.addressLine2,
                    profile.city,
                    profile.county,
                    profile.postCode,
                    profile.country,
                  ]),
                ),
                InfoRow('Shift pattern', profile.shiftPattern),
                InfoRow('Availability', profile.availabilityNotes),
                InfoRow('Wing or area', profile.wingArea),
                InfoRow('Key worker for', profile.keyWorkerFor),
              ],
      ),
      SectionCard(
        title: 'Emergency contact',
        actionLabel: contact == null ? 'Add' : 'Edit',
        onAction: () =>
            openStaffSheet(context, EmergencyContactSheet(contact: contact)),
        children: contact == null
            ? [
                const SizedBox(height: 10),
                const EmptyBox(
                  'Nothing added yet',
                  body: 'Add someone the office can call if they need to.',
                ),
              ]
            : [
                InfoRow('Name', contact.emergencyContactName),
                InfoRow('Relationship', contact.emergencyContactRelationship),
                InfoRow('Phone number', contact.emergencyContactPhone),
                InfoRow('Notes', contact.notes),
              ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'Kept by the office',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.ink,
          ),
        ),
      ),
      Text(
        'You can see these. Only the office can change them, except your right to work record, which you can add once if none is on file. Your supervisions, probation and declarations are under From the office.',
        style: TextStyle(color: AppColors.muted),
      ),
      DesignButton(
        'From the office',
        secondary: true,
        icon: Icons.assignment_outlined,
        onPressed: () => navigateToRoute(context, const OfficeRecordsScreen()),
      ),
      ComplianceCard(compliance: c),
      SectionCard(
        title: 'Employment and pay',
        children: pay == null
            ? [
                const SizedBox(height: 10),
                const EmptyBox('Nothing recorded yet'),
              ]
            : [
                InfoRow('Started', fmtDate(pay.employmentStartDate)),
                InfoRow(
                  'Ends',
                  fmtDate(pay.employmentEndDate) ?? 'No end date',
                ),
                InfoRow(
                  'Hours a week',
                  pay.hoursPerWeek == null ? null : '${pay.hoursPerWeek}',
                ),
                InfoRow('Hourly rate', fmtMoney(pay.hourlyRate, pay.currency)),
                InfoRow(
                  'Annual salary',
                  fmtMoney(pay.annualSalary, pay.currency),
                ),
              ],
      ),
      SectionCard(
        title: 'Appointment letter',
        children: letter == null
            ? [
                const SizedBox(height: 10),
                const EmptyBox('Nothing recorded yet'),
              ]
            : [
                InfoRow(
                  'Status',
                  null,
                  valueWidget: applicable(letter.status) == null
                      ? Text(
                          'Not set',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 16,
                          ),
                        )
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: statusPill(letter.status),
                        ),
                ),
                InfoRow('Reference', letter.referenceNumber),
                InfoRow('Issued', fmtDate(letter.issueDate)),
                InfoRow('Contract', letter.contractType),
                InfoRow(
                  'Probation',
                  letter.probationPeriodMonths == null
                      ? null
                      : '${letter.probationPeriodMonths} months',
                ),
                InfoRow('Notice period', letter.noticePeriod),
                InfoRow('Reports to', letter.reportsTo),
                InfoRow('Work base', letter.workBase),
                InfoRow(
                  'Signed by',
                  _join([letter.signatoryName, letter.signatoryTitle]),
                ),
              ],
      ),
      SectionCard(
        title: 'Access and roles',
        children: [
          const SizedBox(height: 10),
          if (user.roles.isEmpty && user.permissions.isEmpty)
            const EmptyBox('Nothing recorded yet')
          else ...[
            Text(
              'Roles',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final r in user.roles) Pill.neutral(humanize(r))],
            ),
            const SizedBox(height: 12),
            Text(
              'What you are allowed to do',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in user.permissions) Pill.info(humanize(p)),
              ],
            ),
          ],
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(accountControllerProvider);
    final user = async.value?.userData;

    Widget body;
    if (user != null) {
      final items = _content(user);
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) => items[i],
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          EmptyBox('Could not load your details', body: async.error.toString()),
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
          const WellTrustAppBar(title: 'My details', showBack: true),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(accountControllerProvider.notifier).refreshAccount(),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
