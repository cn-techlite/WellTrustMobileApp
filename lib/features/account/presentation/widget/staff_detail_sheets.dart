import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_form.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';

const _sexOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

/// Edit the core details of the signed-in carer (PUT admin-users/update).
class EditDetailsSheet extends ConsumerStatefulWidget {
  final RegisterResponseModel user;

  const EditDetailsSheet({super.key, required this.user});

  @override
  ConsumerState<EditDetailsSheet> createState() => _EditDetailsSheetState();
}

class _EditDetailsSheetState extends ConsumerState<EditDetailsSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _surName = TextEditingController(text: widget.user.surName);
  late final _phone = TextEditingController(text: widget.user.phoneNo);
  late final _nationality = TextEditingController(
    text: widget.user.nationality,
  );
  late final _address = TextEditingController(text: widget.user.address);
  late final _locality = TextEditingController(text: widget.user.locality);
  late final _state = TextEditingController(text: widget.user.state);
  late final _nextOfKin = TextEditingController(text: widget.user.nextOfKin);
  late final _nextOfKinPhone = TextEditingController(
    text: widget.user.nextOfKinPhoneNo,
  );
  late final _ref1 = TextEditingController(text: widget.user.referenceEmail);
  late final _ref2 = TextEditingController(text: widget.user.referenceEmail2);
  late final _insurance = TextEditingController(text: widget.user.insuranceNo);
  late final _dbs = TextEditingController(text: widget.user.dbsCode);
  late final _bankName = TextEditingController(text: widget.user.bankAccName);
  late final _bankNo = TextEditingController(text: widget.user.bankAccNo);
  late final _sortCode = TextEditingController(text: widget.user.bankSortCode);
  late String? _sex = widget.user.sex;
  late DateTime? _dob = widget.user.dateOfBirth;

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _surName,
      _phone,
      _nationality,
      _address,
      _locality,
      _state,
      _nextOfKin,
      _nextOfKinPhone,
      _ref1,
      _ref2,
      _insurance,
      _dbs,
      _bankName,
      _bankNo,
      _sortCode,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    submit(
      () => ref
          .read(accountControllerProvider.notifier)
          .updateProfile(
            UpdateStaffRequest(
              firstName: clean(_firstName),
              surName: clean(_surName),
              phoneNo: clean(_phone),
              sex: _sex,
              dateOfBirth: _dob,
              nationality: clean(_nationality),
              address: clean(_address),
              locality: clean(_locality),
              state: clean(_state),
              nextOfKin: clean(_nextOfKin),
              nextOfKinPhoneNo: clean(_nextOfKinPhone),
              referenceEmail: clean(_ref1),
              referenceEmail2: clean(_ref2),
              insuranceNo: clean(_insurance),
              dbsCode: clean(_dbs),
              bankAccName: clean(_bankName),
              bankAccNo: clean(_bankNo),
              bankSortCode: clean(_sortCode),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sexOptions = [
      ..._sexOptions,
      if (_sex != null && _sex!.isNotEmpty && !_sexOptions.contains(_sex))
        _sex!,
    ];
    return StaffSheet(
      title: 'Edit my details',
      intro: 'Your email and staff code are set by the office.',
      saving: saving,
      error: saveError,
      onSave: _save,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(
                label: 'First name',
                controller: _firstName,
                required: true,
                name: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Surname',
                controller: _surName,
                required: true,
                name: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Phone number', controller: _phone),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Sex',
                value: _sex,
                options: sexOptions,
                onChanged: (v) => setState(() => _sex = v),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Date of birth',
                value: _dob,
                allowClear: false,
                onChanged: (d) => setState(() => _dob = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Nationality', controller: _nationality),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Address',
                controller: _address,
                maxLength: 150,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Town or city', controller: _locality),
              const SizedBox(height: 14),
              StaffTextField(label: 'County', controller: _state),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Next of kin',
                controller: _nextOfKin,
                name: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Next of kin phone',
                controller: _nextOfKinPhone,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Reference email 1',
                controller: _ref1,
                email: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Reference email 2',
                controller: _ref2,
                email: true,
                maxLength: 100,
              ),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'National Insurance number',
                controller: _insurance,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'DBS number', controller: _dbs),
              const SizedBox(height: 14),
              StaffTextField(label: 'Bank account name', controller: _bankName),
              const SizedBox(height: 14),
              StaffTextField(label: 'Bank account number', controller: _bankNo),
              const SizedBox(height: 14),
              StaffTextField(label: 'Bank sort code', controller: _sortCode),
            ],
          ),
        ),
      ],
    );
  }
}

/// Job details and home address (POST admin-staff-records/profile).
class JobDetailsSheet extends ConsumerStatefulWidget {
  final StaffProfile? profile;
  final DateTime? fallbackDateOfBirth;

  const JobDetailsSheet({super.key, this.profile, this.fallbackDateOfBirth});

  @override
  ConsumerState<JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends ConsumerState<JobDetailsSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();
  late final _jobTitle = TextEditingController(text: widget.profile?.jobTitle);
  late final _line1 = TextEditingController(text: widget.profile?.addressLine1);
  late final _line2 = TextEditingController(text: widget.profile?.addressLine2);
  late final _city = TextEditingController(text: widget.profile?.city);
  late final _county = TextEditingController(text: widget.profile?.county);
  late final _postCode = TextEditingController(text: widget.profile?.postCode);
  late final _country = TextEditingController(text: widget.profile?.country);
  late final _shift = TextEditingController(text: widget.profile?.shiftPattern);
  late final _availability = TextEditingController(
    text: widget.profile?.availabilityNotes,
  );
  late final _wing = TextEditingController(text: widget.profile?.wingArea);
  late final _keyWorker = TextEditingController(
    text: widget.profile?.keyWorkerFor,
  );
  late String? _employmentType = widget.profile?.employmentType;
  late String? _gender = widget.profile?.gender;
  late DateTime? _dob =
      widget.profile?.dateOfBirth ?? widget.fallbackDateOfBirth;
  String? _choiceError;

  @override
  void dispose() {
    for (final c in [
      _jobTitle,
      _line1,
      _line2,
      _city,
      _county,
      _postCode,
      _country,
      _shift,
      _availability,
      _wing,
      _keyWorker,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_employmentType == null || _gender == null) {
      setState(() => _choiceError = 'Choose an employment type and a gender.');
      return;
    }
    setState(() => _choiceError = null);
    submit(
      () => ref
          .read(accountControllerProvider.notifier)
          .saveStaffRecord(
            ProfileRecordRequest(
              jobTitle: clean(_jobTitle),
              employmentType: _employmentType!,
              dateOfBirth: _dob,
              gender: _gender!,
              addressLine1: clean(_line1),
              addressLine2: clean(_line2),
              city: clean(_city),
              county: clean(_county),
              postCode: clean(_postCode),
              country: clean(_country),
              shiftPattern: clean(_shift),
              availabilityNotes: clean(_availability),
              wingArea: clean(_wing),
              keyWorkerFor: clean(_keyWorker),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: 'Job and home address',
      saving: saving,
      error: saveError ?? _choiceError,
      onSave: _save,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffTextField(label: 'Job title', controller: _jobTitle),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Employment type',
                value: _employmentType,
                options: staffEmploymentTypes,
                display: employmentTypeLabel,
                onChanged: (v) => setState(() => _employmentType = v),
              ),
              const SizedBox(height: 14),
              StaffDropdown(
                label: 'Gender',
                value: _gender,
                options: staffGenders,
                display: genderLabel,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 14),
              StaffDateField(
                label: 'Date of birth',
                value: _dob,
                allowClear: false,
                onChanged: (d) => setState(() => _dob = d),
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Address line 1', controller: _line1),
              const SizedBox(height: 14),
              StaffTextField(label: 'Address line 2', controller: _line2),
              const SizedBox(height: 14),
              StaffTextField(label: 'Town or city', controller: _city),
              const SizedBox(height: 14),
              StaffTextField(label: 'County', controller: _county),
              const SizedBox(height: 14),
              StaffTextField(label: 'Post code', controller: _postCode),
              const SizedBox(height: 14),
              StaffTextField(label: 'Country', controller: _country),
              const SizedBox(height: 14),
              StaffTextField(label: 'Shift pattern', controller: _shift),
              const SizedBox(height: 14),
              StaffTextField(
                label: 'Availability notes',
                controller: _availability,
                multiline: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Wing or area', controller: _wing),
              const SizedBox(height: 14),
              StaffTextField(label: 'Key worker for', controller: _keyWorker),
            ],
          ),
        ),
      ],
    );
  }
}

/// Who to call in an emergency (POST admin-staff-records/emergency-contact).
class EmergencyContactSheet extends ConsumerStatefulWidget {
  final StaffEmergencyContact? contact;

  const EmergencyContactSheet({super.key, this.contact});

  @override
  ConsumerState<EmergencyContactSheet> createState() =>
      _EmergencyContactSheetState();
}

class _EmergencyContactSheetState extends ConsumerState<EmergencyContactSheet>
    with StaffSheetSaving {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.contact?.emergencyContactName,
  );
  late final _relationship = TextEditingController(
    text: widget.contact?.emergencyContactRelationship,
  );
  late final _phone = TextEditingController(
    text: widget.contact?.emergencyContactPhone,
  );
  late final _notes = TextEditingController(text: widget.contact?.notes);

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    submit(
      () => ref
          .read(accountControllerProvider.notifier)
          .saveStaffRecord(
            EmergencyContactRequest(
              name: clean(_name),
              relationship: clean(_relationship),
              phone: clean(_phone),
              notes: clean(_notes),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffSheet(
      title: 'Emergency contact',
      intro: 'The office calls this person if something happens to you.',
      saving: saving,
      error: saveError,
      onSave: _save,
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
                name: true,
              ),
              const SizedBox(height: 14),
              StaffTextField(label: 'Relationship', controller: _relationship),
              const SizedBox(height: 14),
              StaffTextField(label: 'Phone number', controller: _phone),
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
