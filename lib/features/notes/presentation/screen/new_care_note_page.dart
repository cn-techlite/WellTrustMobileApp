import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/clients/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/providers/care_note_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

const _supportTypes = [
  'Personal care',
  'Meals & drinks',
  'Medication',
  'Mobility & transfers',
  'Domestic support',
  'Companionship & social',
  'Appointment / escort',
  'Other',
];

const _outcomeLabels = {'ok': 'No concerns', 'concern': 'Concern raised'};

class NewCareNotePage extends ConsumerStatefulWidget {
  final String? clientId;

  const NewCareNotePage({super.key, this.clientId});

  @override
  ConsumerState<NewCareNotePage> createState() => _NewCareNotePageState();
}

class _NewCareNotePageState extends ConsumerState<NewCareNotePage> {
  final noteController = TextEditingController();

  String? clientId;
  String? mood;
  String? intake;
  String? skin;
  bool flagged = false;
  String? error;

  bool isDailyCareNote = false;
  DateTime? visitDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? supportType;
  String? outcome;

  @override
  void initState() {
    super.initState();
    clientId = widget.clientId;
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final missingQuickFields =
        !isDailyCareNote && (mood == null || intake == null || skin == null);
    final missingDailyFields =
        isDailyCareNote &&
        (visitDate == null ||
            startTime == null ||
            endTime == null ||
            supportType == null ||
            outcome == null);

    if (clientId == null ||
        missingQuickFields ||
        missingDailyFields ||
        noteController.text.trim().isEmpty) {
      setState(() {
        error = 'Complete each question and write the care note.';
      });
      return;
    }

    final tellOffice = flagged || skin == 'Concern' || outcome == 'concern';
    final clients =
        ref.read(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];
    final selectedClient = clients
        .where((client) => client.id == clientId)
        .firstOrNull;
    try {
      await ref
          .read(careNotesProvider.notifier)
          .add(
            CareNoteEntry(
              id: 'N${DateTime.now().microsecondsSinceEpoch}',
              clientId: clientId!,
              clientName: selectedClient?.preferred ?? '',
              at: DateTime.now(),
              mood: isDailyCareNote ? '' : mood!,
              intake: isDailyCareNote ? '' : intake!,
              skin: isDailyCareNote ? '' : skin!,
              text: noteController.text.trim(),
              flagged: tellOffice,
              visitDate: isDailyCareNote ? visitDate : null,
              startTime: isDailyCareNote ? _formatTime(startTime!) : null,
              endTime: isDailyCareNote ? _formatTime(endTime!) : null,
              supportType: isDailyCareNote ? supportType : null,
              outcome: isDailyCareNote ? outcome : null,
            ),
          );
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.pop(context);
    messenger?.showSnackBar(
      SnackBar(
        content: AppText(
          text: tellOffice
              ? 'Care note saved and flagged for the office.'
              : 'Care note saved.',
          type: AppTextType.bodySmall,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> pickVisitDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: visitDate ?? today,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (selected != null) {
      setState(() {
        visitDate = selected;
        error = null;
      });
    }
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
        error = null;
      });
    }
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
        error = null;
      });
    }
  }

  Widget pickerField({
    required String label,
    required VoidCallback onTap,
  }) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
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
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );

  Widget label(String value, {String? help}) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: value,
          type: AppTextType.bodySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        if (help != null) ...[
          addVerticalSpacing(0.24),
          AppText(
            text: help,
            type: AppTextType.labelLarge,
            color: AppColors.muted,
          ),
        ],
      ],
    ),
  );

  Widget segments(
    List<String> options,
    String? selected,
    ValueChanged<String> onChanged,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          _CareNoteSegment(
            label: option,
            selected: option == selected,
            onSelected: () => setState(() {
              onChanged(option);
              error = null;
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients =
        ref.watch(assignedClientsProvider).value?.assignedClients ??
        const <AssignedClient>[];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'New care note', showBack: true),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text:
                          'Use this for something you noticed outside a visit, such as a phone call from a family member.',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                    ),
                    addVerticalSpacing(2.13),
                    DesignCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label('Who is it about?'),
                          GlobalSearchableDropdown<String>(
                            title: 'Choose a person',
                            hintText: 'Choose a person',
                            value: clientId,
                            options: [
                              for (final client in clients)
                                SearchableDropdownOption(
                                  value: client.id,
                                  label: client.name,
                                ),
                            ],
                            emptyMessage:
                                'No residents or clients are currently assigned to you.',
                            onChanged: (value) => setState(() {
                              clientId = value;
                              error = null;
                            }),
                          ),
                          label('Note type'),
                          segments(
                            const ['Quick note', 'Daily Care Note'],
                            isDailyCareNote ? 'Daily Care Note' : 'Quick note',
                            (value) => isDailyCareNote =
                                value == 'Daily Care Note',
                          ),
                          if (!isDailyCareNote) ...[
                            label('How were they?'),
                            segments(
                              const ['Settled', 'Low', 'Anxious', 'Unwell'],
                              mood,
                              (value) => mood = value,
                            ),
                            label('Food and drink'),
                            segments(
                              const [
                                'Good',
                                'Some',
                                'Little',
                                'Refused',
                                'Not needed',
                              ],
                              intake,
                              (value) => intake = value,
                            ),
                            label('Skin and comfort'),
                            segments(
                              const ['No concerns', 'Concern'],
                              skin,
                              (value) => skin = value,
                            ),
                          ],
                          if (isDailyCareNote) ...[
                            label('Visit date'),
                            pickerField(
                              label: visitDate == null
                                  ? 'Choose the visit date'
                                  : DateFormat('dd/MM/yyyy').format(visitDate!),
                              onTap: pickVisitDate,
                            ),
                            label('Visit start time'),
                            pickerField(
                              label: startTime == null
                                  ? 'Choose a start time'
                                  : _formatTime(startTime!),
                              onTap: pickStartTime,
                            ),
                            label('Visit end time'),
                            pickerField(
                              label: endTime == null
                                  ? 'Choose an end time'
                                  : _formatTime(endTime!),
                              onTap: pickEndTime,
                            ),
                            label('Support type'),
                            segments(
                              _supportTypes,
                              supportType,
                              (value) => supportType = value,
                            ),
                            label('Outcome'),
                            segments(
                              _outcomeLabels.values.toList(),
                              outcome != null ? _outcomeLabels[outcome] : null,
                              (value) => outcome = _outcomeLabels.entries
                                  .firstWhere((entry) => entry.value == value)
                                  .key,
                            ),
                          ],
                          label(
                            'What you did and how they were',
                            help:
                                'Write what happened. The office and other carers will read this.',
                          ),
                          GlobalTextField(
                            fieldName:
                                'For example: helped Harold wash and dress. He was in good spirits and ate all his breakfast.',
                            keyBoardType: TextInputType.multiline,
                            textController: noteController,
                            minLines: 5,
                            maxLines: 7,
                            maxLength: 1000,
                            removeSpace: false,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (_) {
                              if (error != null) setState(() => error = null);
                            },
                          ),
                          addVerticalSpacing(1.90),
                          Material(
                            color: AppColors.bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.line),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CheckboxListTile(
                              value: flagged,
                              onChanged: (value) =>
                                  setState(() => flagged = value ?? false),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                              title: const AppText(
                                text:
                                    'Tell the office about this. Tick it for anything that worries you.',
                                type: AppTextType.bodySmall,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: AppText(
                                text: error!,
                                type: AppTextType.bodySmall,
                                color: AppColors.rose,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          addVerticalSpacing(2.61),
                          DesignButton('Save care note', onPressed: save),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareNoteSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _CareNoteSegment({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: AppText(
        text: label,
        type: AppTextType.labelLarge,
        color: selected ? AppColors.onPrimary : AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.line2,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
