import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:well_trust_mobile_app/core/services/mobile_api_client.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/abc_chart_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/abc_chart_widgets.dart';
import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class AbcChartScreen extends ConsumerStatefulWidget {
  final String? initialClientId;

  const AbcChartScreen({super.key, this.initialClientId});

  @override
  ConsumerState<AbcChartScreen> createState() => _AbcChartScreenState();
}

class _AbcChartScreenState extends ConsumerState<AbcChartScreen> {
  String _tab = 'new';
  String? _residentId;
  DateTime _episodeDate = DateTime.now();
  TimeOfDay? _episodeTime = TimeOfDay.now();
  String? _possibleFunction;
  String? _formError;
  bool _submitting = false;

  final _location = TextEditingController();
  final _antecedent = TextEditingController();
  final _behaviour = TextEditingController();
  final _duration = TextEditingController();
  final _consequence = TextEditingController();
  final _staffInvolved = TextEditingController();

  @override
  void initState() {
    super.initState();
    _residentId = widget.initialClientId;
    if (_residentId != null) {
      Future.microtask(() => _loadEntries(_residentId!));
    }
  }

  @override
  void dispose() {
    _location.dispose();
    _antecedent.dispose();
    _behaviour.dispose();
    _duration.dispose();
    _consequence.dispose();
    _staffInvolved.dispose();
    super.dispose();
  }

  Future<void> _loadEntries(String residentId) =>
      ref.read(abcChartProvider.notifier).loadForClient(residentId);

  void _selectResident(String residentId) {
    setState(() {
      _residentId = residentId;
      _formError = null;
    });
    _loadEntries(residentId);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _episodeDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (value != null && mounted) setState(() => _episodeDate = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _episodeTime ?? TimeOfDay.now(),
    );
    if (value != null && mounted) setState(() => _episodeTime = value);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_residentId == null ||
        _antecedent.text.trim().isEmpty ||
        _behaviour.text.trim().isEmpty ||
        _consequence.text.trim().isEmpty) {
      setState(() {
        _formError =
            'Choose a person and complete the antecedent, behaviour and consequence.';
      });
      return;
    }

    final now = DateTime.now();
    final episodeMoment = DateTime(
      _episodeDate.year,
      _episodeDate.month,
      _episodeDate.day,
      _episodeTime?.hour ?? 0,
      _episodeTime?.minute ?? 0,
    );
    if (_episodeTime != null && episodeMoment.isAfter(now)) {
      setState(() => _formError = 'The episode time cannot be in the future.');
      return;
    }

    setState(() {
      _submitting = true;
      _formError = null;
    });

    try {
      await ref
          .read(abcChartProvider.notifier)
          .create(
            AbcChartDraft(
              residentId: _residentId!,
              episodeDate: _episodeDate,
              episodeTime: _apiTime(_episodeTime),
              location: _location.text,
              antecedent: _antecedent.text,
              behaviour: _behaviour.text,
              duration: _duration.text,
              consequence: _consequence.text,
              possibleFunction: _possibleFunction,
              staffInvolved: _staffInvolved.text,
            ),
          );
    } on MobileApiException catch (error) {
      if (mounted) setState(() => _formError = error.message);
      return;
    } catch (_) {
      if (mounted) {
        setState(() {
          _formError =
              'We could not confirm whether this entry saved. Check Records and refresh before trying again.';
        });
      }
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;
    _clearEpisodeFields();
    setState(() => _tab = 'records');
    showCustomSnackbar(
      context,
      title: 'ABC entry saved',
      content: 'The behaviour episode has been added.',
      type: SnackbarType.success,
      isTopPosition: false,
    );
  }

  void _clearEpisodeFields() {
    setState(() {
      _episodeDate = DateTime.now();
      _episodeTime = TimeOfDay.now();
      _possibleFunction = null;
      _formError = null;
      _location.clear();
      _antecedent.clear();
      _behaviour.clear();
      _duration.clear();
      _consequence.clear();
      _staffInvolved.clear();
    });
  }

  String? _apiTime(TimeOfDay? value) => value == null
      ? null
      : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final clients =
        ref.watch(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'ABC Chart', showBack: true),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                children: [
                  AppText(
                    text:
                        'Record what happened before, during and after a behaviour episode. Accidents and injuries should still be reported as incidents.',
                    type: AppTextType.bodySmall,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                  addVerticalSpacing(1.66),
                  DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AbcFormLabel(
                          'Who is the entry about?',
                          requiredField: true,
                        ),
                        GlobalSearchableDropdown<String>(
                          title: 'Choose a person',
                          hintText: 'Choose an assigned person',
                          value: _residentId,
                          options: [
                            for (final client in clients)
                              SearchableDropdownOption(
                                value: client.id,
                                label: client.name,
                              ),
                          ],
                          emptyMessage:
                              'No residents or clients are currently assigned to you.',
                          onChanged: _selectResident,
                        ),
                      ],
                    ),
                  ),
                  addVerticalSpacing(1.42),
                  SegmentTabs(
                    options: const [
                      ('new', 'New entry'),
                      ('records', 'Records'),
                    ],
                    active: _tab,
                    onChanged: (value) {
                      setState(() => _tab = value);
                      if (value == 'records' && _residentId != null) {
                        _loadEntries(_residentId!);
                      }
                    },
                  ),
                  addVerticalSpacing(1.42),
                  if (_tab == 'new') _buildForm() else _buildRecords(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() => DesignCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Episode details',
          type: AppTextType.bodySmall,
          fontWeight: FontWeight.w800,
        ),
        const AbcFormLabel('Date', requiredField: true),
        AbcPickerField(
          text: DateFormat('dd/MM/yyyy').format(_episodeDate),
          icon: Icons.calendar_today_outlined,
          onTap: _pickDate,
        ),
        const AbcFormLabel('Time', help: 'Optional'),
        AbcPickerField(
          text: _episodeTime?.format(context) ?? 'Choose a time',
          icon: Icons.schedule_outlined,
          onTap: _pickTime,
          onClear: _episodeTime == null
              ? null
              : () => setState(() => _episodeTime = null),
        ),
        const AbcFormLabel('Location', help: 'Where did it happen?'),
        _textField(
          controller: _location,
          hint: 'For example: living room, during personal care',
          maxLength: 250,
        ),
        const AbcFormLabel(
          'Antecedent — what happened before?',
          help:
              'Describe triggers, requests, changes or events immediately beforehand.',
          requiredField: true,
        ),
        _textField(
          controller: _antecedent,
          hint: 'What was happening just before the behaviour?',
          maxLength: 1500,
          lines: 4,
        ),
        const AbcFormLabel(
          'Behaviour — what did the person do?',
          help: 'Be specific and factual. Avoid labels or assumptions.',
          requiredField: true,
        ),
        _textField(
          controller: _behaviour,
          hint: 'Describe exactly what you saw or heard',
          maxLength: 1500,
          lines: 4,
        ),
        const AbcFormLabel('Duration', help: 'Optional'),
        _textField(
          controller: _duration,
          hint: 'For example: about 5 minutes',
          maxLength: 100,
        ),
        const AbcFormLabel(
          'Consequence — what happened after?',
          help: 'Include how staff responded and what happened next.',
          requiredField: true,
        ),
        _textField(
          controller: _consequence,
          hint: 'What response or outcome followed?',
          maxLength: 1500,
          lines: 4,
        ),
        const AbcFormLabel(
          'Possible function',
          help: 'Optional. Leave blank if this was not assessed.',
        ),
        AbcFunctionChoices(
          selected: _possibleFunction,
          onChanged: (value) => setState(() => _possibleFunction = value),
        ),
        const AbcFormLabel('Staff involved', help: 'Optional'),
        _textField(
          controller: _staffInvolved,
          hint: 'Names of staff present or involved',
          maxLength: 250,
        ),
        if (_formError != null) ...[
          addVerticalSpacing(1.66),
          NoticeBox.danger(_formError!),
        ],
        addVerticalSpacing(2.13),
        DesignButton(
          _submitting ? 'Saving…' : 'Save ABC entry',
          onPressed: _submitting ? null : _submit,
        ),
      ],
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    int lines = 1,
  }) => GlobalTextField(
    fieldName: hint,
    keyBoardType: lines > 1 ? TextInputType.multiline : TextInputType.text,
    textController: controller,
    maxLength: maxLength,
    minLines: lines,
    maxLines: lines == 1 ? 1 : lines + 2,
    isOptional: true,
    removeSpace: false,
    textCapitalization: TextCapitalization.sentences,
    onChanged: (_) {
      if (_formError != null) setState(() => _formError = null);
    },
  );

  Widget _buildRecords() {
    if (_residentId == null) {
      return const AbcEmptyState(
        title: 'Choose a person',
        body: 'Select an assigned person above to view their ABC entries.',
      );
    }

    final state = ref.watch(abcChartProvider);
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.error != null) {
      return Column(
        children: [
          NoticeBox.danger(state.error!),
          addVerticalSpacing(1.42),
          DesignButton(
            'Try again',
            secondary: true,
            onPressed: () => _loadEntries(_residentId!),
          ),
        ],
      );
    }

    if (state.entries.isEmpty) {
      return const AbcEmptyState(
        title: 'No ABC entries yet',
        body:
            'New behaviour episodes recorded for this person will appear here.',
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _loadEntries(_residentId!),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ),
        for (final entry in state.entries) ...[
          AbcEntryCard(entry: entry),
          addVerticalSpacing(1.42),
        ],
      ],
    );
  }
}
