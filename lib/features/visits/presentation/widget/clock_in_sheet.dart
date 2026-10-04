import 'package:well_trust_mobile_app/core/services/location_service.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/data/dto/clock_in_details.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

/// Starting outside this on-time tolerance needs a reason for the office.
const clockInGraceMins = 15;

/// A visit can be clocked into from two hours before until two hours after its
/// planned start, matching the rota rules in the design.
const clockInWindowMins = 120;

class ClockInTiming {
  final DateTime start;
  final DateTime now;

  const ClockInTiming({required this.start, required this.now});

  int get minutesFromStart => now.difference(start).inMinutes;
  bool get isEarly => minutesFromStart < -clockInGraceMins;
  bool get isLate => minutesFromStart > clockInGraceMins;
  bool get needsReason => isEarly || isLate;
  bool get isOpen =>
      !now.isBefore(
        start.subtract(const Duration(minutes: clockInWindowMins)),
      ) &&
      !now.isAfter(start.add(const Duration(minutes: clockInWindowMins)));
  bool get hasClosed =>
      now.isAfter(start.add(const Duration(minutes: clockInWindowMins)));
  DateTime get opensAt =>
      start.subtract(const Duration(minutes: clockInWindowMins));
}

/// Beyond this distance from the client's address, a clock-in at "home" is
/// flagged for the office to check.
const clockInDistanceThresholdMetres = 400.0;

/// The stage the clock-in sheet is showing.
enum _Stage {
  /// The reason box (if early) and the two "where are you" buttons.
  start,

  /// Reading the phone's position.
  locating,

  /// The phone is further from the client's address than expected.
  tooFar,
}

/// Opens the clock-in sheet. Completes with what to save, or null when the
/// carer cancelled.
///
/// [start] is the planned start; leave it out when there is none to compare.
/// [clientLatitude] and [clientLongitude] are the client's home, so the sheet
/// can check the carer is nearby; leave them out when that is not known.
Future<ClockInDetails?> showClockInSheet(
  BuildContext context, {
  required String preferred,
  DateTime? start,
  double? clientLatitude,
  double? clientLongitude,
  LocationService locationService = const LocationService(),
}) {
  return showModalBottomSheet<ClockInDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => ClockInSheet(
      preferred: preferred,
      start: start,
      clientLatitude: clientLatitude,
      clientLongitude: clientLongitude,
      locationService: locationService,
    ),
  );
}

class ClockInSheet extends StatefulWidget {
  final String preferred;
  final DateTime? start;
  final double? clientLatitude;
  final double? clientLongitude;
  final LocationService locationService;

  const ClockInSheet({
    super.key,
    required this.preferred,
    this.start,
    this.clientLatitude,
    this.clientLongitude,
    this.locationService = const LocationService(),
  });

  @override
  State<ClockInSheet> createState() => _ClockInSheetState();
}

class _ClockInSheetState extends State<ClockInSheet> {
  final _reason = TextEditingController();
  final _scroll = ScrollController();

  /// Fixed when the sheet opens so the wording does not change while the
  /// carer types.
  late final ClockInTiming? _timing = widget.start == null
      ? null
      : ClockInTiming(start: widget.start!, now: DateTime.now());

  _Stage _stage = _Stage.start;

  /// Which button is waiting on the phone's location, while [_stage] is
  /// [_Stage.start] or [_Stage.locating].
  bool? _atHome;

  LocationFix? _fix;
  double? _distanceMetres;
  String? _reasonError;
  LocationException? _problem;

  bool get _needsTimingReason => _timing?.needsReason ?? false;
  bool get _early => _timing?.isEarly ?? false;
  int get _timingMinutes => _timing?.minutesFromStart.abs() ?? 0;

  bool get _hasClientAddress =>
      widget.clientLatitude != null && widget.clientLongitude != null;

  @override
  void dispose() {
    _reason.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String? _reasonOrNull() {
    if (!_needsTimingReason) return null;
    final text = _reason.text.trim();
    return text.isEmpty ? null : text;
  }

  /// Shows the missing-reason message, and scrolls up to it: the buttons that
  /// trigger it can be below the fold on a small phone.
  void _askForReason() {
    setState(() => _reasonError = 'Please tell the office why you are early.');
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _finish({double? distanceMetres, bool flaggedTooFar = false}) {
    Navigator.pop(
      context,
      ClockInDetails(
        at: DateTime.now(),
        atClientHome: _atHome,
        earlyReason: _reasonOrNull(),
        location: _fix,
        distanceFromClientMetres: distanceMetres,
        flaggedTooFarFromClient: flaggedTooFar,
      ),
    );
  }

  Future<void> _selectWhere({required bool atHome}) async {
    if (_needsTimingReason && _reasonOrNull() == null) {
      _askForReason();
      return;
    }
    setState(() {
      _atHome = atHome;
      _stage = _Stage.locating;
      _fix = null;
      _problem = null;
    });
    await _locate();
  }

  Future<void> _locate() async {
    try {
      final fix = await widget.locationService.currentFix();
      if (!mounted) return;
      setState(() => _fix = fix);
      // A short pause so the carer sees the accuracy before the sheet moves
      // on, rather than it flashing past.
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      if (_atHome == true && _hasClientAddress) {
        final distance = LocationService.distanceBetween(
          fix.latitude,
          fix.longitude,
          widget.clientLatitude!,
          widget.clientLongitude!,
        );
        if (distance > clockInDistanceThresholdMetres) {
          setState(() {
            _distanceMetres = distance;
            _stage = _Stage.tooFar;
          });
          return;
        }
        _finish(distanceMetres: distance);
      } else {
        _finish();
      }
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.start;
        _problem = e;
      });
    }
  }

  /// Last resort when the phone cannot give a location. It is recorded as
  /// clocked in without one, so the office can see that.
  void _clockInWithoutLocation() {
    if (_needsTimingReason && _reasonOrNull() == null) {
      _askForReason();
      return;
    }
    Navigator.pop(
      context,
      ClockInDetails(at: DateTime.now(), earlyReason: _reasonOrNull()),
    );
  }

  void _cancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage == _Stage.start,
      child: Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: switch (_stage) {
              _Stage.start => _startStage(),
              _Stage.locating => _locatingStage(),
              _Stage.tooFar => _tooFarStage(),
            },
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => AppText(
    text: text,
    type: AppTextType.bodySmall,
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.ink,
  );

  Widget _startStage() {
    final name = widget.preferred;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Clock in to $name'),
        addVerticalSpacing(1.66),
        if (_needsTimingReason) ...[
          NoticeBox(
            'You are $_timingMinutes min ${_early ? 'early for' : 'after'} the '
            '${hhmm(widget.start!)} start. Tell the office why you are '
            'starting ${_early ? 'early' : 'late'}.',
            bg: AppColors.amberBg,
            fg: AppColors.amber,
            icon: Icons.access_time,
          ),
          addVerticalSpacing(2.13),
          AppText(
            text: 'Why are you starting ${_early ? 'early' : 'late'}?',
            type: AppTextType.bodySmall,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
          addVerticalSpacing(0.95),
          _ReasonField(
            controller: _reason,
            hasError: _reasonError != null,
            hint: _early
                ? 'For example: the previous visit finished early'
                : 'For example: heavy traffic on the A14',
            onChanged: (_) {
              if (_reasonError != null) setState(() => _reasonError = null);
            },
          ),
          if (_reasonError != null) ...[
            addVerticalSpacing(0.71),
            AppText(
              text: _reasonError!,
              type: AppTextType.bodySmall,
              color: AppColors.rose,
              fontSize: 14,
            ),
          ],
          addVerticalSpacing(2.13),
        ],
        AppText(
          text: 'Where are you now?',
          type: AppTextType.bodySmall,
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        addVerticalSpacing(0.71),
        AppText(
          text:
              'Your exact location is saved with your clock-in, and the '
              'office can see it in the audit log.',
          type: AppTextType.bodySmall,
          color: AppColors.muted,
          fontSize: 15,
          height: 1.4,
        ),
        if (_problem != null) ...[
          addVerticalSpacing(1.42),
          NoticeBox.warn(_problem!.message),
        ],
        addVerticalSpacing(1.66),
        DesignButton(
          "I am at $name's home",
          onPressed: () => _selectWhere(atHome: true),
        ),
        addVerticalSpacing(1.18),
        DesignButton(
          'I am somewhere else',
          secondary: true,
          onPressed: () => _selectWhere(atHome: false),
        ),
        if (_problem != null) ...[
          addVerticalSpacing(1.18),
          if (_problem!.needsSettings) ...[
            DesignButton(
              'Open Settings',
              secondary: true,
              icon: Icons.settings_outlined,
              onPressed: () => widget.locationService.openSettings(_problem!),
            ),
            addVerticalSpacing(1.18),
          ],
          DesignButton(
            'Clock in without location',
            secondary: true,
            onPressed: _clockInWithoutLocation,
          ),
        ],
        addVerticalSpacing(0.71),
        Center(
          child: AppButton(
            text: 'Cancel',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.ink,
            onPressed: _cancel,
          ),
        ),
      ],
    );
  }

  Widget _locatingStage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Finding your exact location'),
        addVerticalSpacing(1.42),
        AppText(
          text:
              'Keep the app open. Stand by a window or outside for the best '
              'result.',
          type: AppTextType.bodySmall,
          color: AppColors.muted,
          fontSize: 16,
          height: 1.4,
        ),
        if (_fix != null) ...[
          addVerticalSpacing(2.13),
          AppText(
            text: 'Accurate to about ${_fix!.accuracy.round()} m',
            type: AppTextType.bodySmall,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.ink,
          ),
        ],
        addVerticalSpacing(2.61),
        DesignButton('Cancel', secondary: true, onPressed: _cancel),
      ],
    );
  }

  Widget _tooFarStage() {
    final name = widget.preferred;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Clock in to $name'),
        addVerticalSpacing(1.66),
        NoticeBox.danger(
          'You look to be about ${formatDistance(_distanceMetres!)} from '
          "$name's address. Check you are at the right house. You can still "
          'clock in, and the office will see this.',
        ),
        addVerticalSpacing(2.13),
        DesignButton(
          'Clock in anyway',
          onPressed: () =>
              _finish(distanceMetres: _distanceMetres, flaggedTooFar: true),
        ),
        addVerticalSpacing(1.18),
        DesignButton(
          'Try again',
          secondary: true,
          onPressed: () {
            setState(() => _stage = _Stage.locating);
            _locate();
          },
        ),
        addVerticalSpacing(0.71),
        Center(
          child: AppButton(
            text: 'I am somewhere else',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.ink,
            onPressed: () {
              setState(() => _atHome = false);
              _finish(distanceMetres: _distanceMetres);
            },
          ),
        ),
        Center(
          child: AppButton(
            text: 'Cancel',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.ink,
            onPressed: _cancel,
          ),
        ),
      ],
    );
  }
}

class _ReasonField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final String hint;
  final ValueChanged<String> onChanged;

  const _ReasonField({
    required this.controller,
    required this.hasError,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalTextField(
      fieldName: hint,
      keyBoardType: TextInputType.multiline,
      textController: controller,
      onChanged: onChanged,
      minLines: 4,
      maxLines: 6,
      maxLength: 300,
      removeSpace: false,
      textCapitalization: TextCapitalization.sentences,
      borderRadius: 12,
      hasError: hasError,
    );
  }
}
