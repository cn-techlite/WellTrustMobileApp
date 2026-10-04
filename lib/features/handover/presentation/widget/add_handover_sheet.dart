import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/clients/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/providers/client_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/providers/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class AddHandoverPage extends ConsumerStatefulWidget {
  final String? clientId;

  const AddHandoverPage({super.key, this.clientId});

  @override
  ConsumerState<AddHandoverPage> createState() => _AddHandoverPageState();
}

class _AddHandoverPageState extends ConsumerState<AddHandoverPage> {
  final text = TextEditingController();
  final home = TextEditingController();
  final contacts = TextEditingController();

  String? clientId;
  HandoverKind kind = HandoverKind.info;
  HandoverPriority priority = HandoverPriority.routine;
  String? mood;
  String? eating;
  String? medication;
  String? skin;
  bool followUp = false;
  String forWhom = 'Next carer';
  DateTime? followUpDue;
  String? error;

  @override
  void initState() {
    super.initState();
    clientId = widget.clientId;
  }

  @override
  void dispose() {
    text.dispose();
    home.dispose();
    contacts.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (clientId == null) {
      setState(() => error = 'Choose a person.');
      return;
    }
    if (text.text.trim().isEmpty) {
      setState(() => error = 'Write what the next carer needs to know.');
      return;
    }

    final details = <String, String>{
      'How they were': ?mood,
      'Food and drink': ?eating,
      'Medication': ?medication,
      'Skin and mobility': ?skin,
      if (home.text.trim().isNotEmpty) 'Home and equipment': home.text.trim(),
      if (contacts.text.trim().isNotEmpty)
        'Contact with family or others': contacts.text.trim(),
    };

    try {
      await ref
          .read(handoverProvider.notifier)
          .add(
            HandoverEntry(
              id: 'H${DateTime.now().microsecondsSinceEpoch}',
              clientId: clientId!,
              at: DateTime.now(),
              by: 'You',
              kind: kind,
              priority: priority,
              text: text.text.trim(),
              details: details,
              needsFollowUp: followUp,
              followUpFor: forWhom,
              followUpDue: followUp ? followUpDue : null,
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
      const SnackBar(
        content: AppText(
          text: 'Handover saved. The next carer and the office can read it.',
          type: AppTextType.bodySmall,
        ),
      ),
    );
  }

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

  Widget requiredSegments<T>(
    List<T> options,
    T value,
    String Function(T) name,
    ValueChanged<T> onChanged,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          _SegmentChip(
            label: name(option),
            selected: option == value,
            onSelected: () => setState(() => onChanged(option)),
          ),
      ],
    );
  }

  Widget optionalSegments(
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _SegmentChip(
          label: 'Not noted',
          selected: value == null,
          onSelected: () => setState(() => onChanged(null)),
        ),
        for (final option in options)
          _SegmentChip(
            label: option,
            selected: option == value,
            onSelected: () => setState(() => onChanged(option)),
          ),
      ],
    );
  }

  Future<void> pickDueDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: followUpDue ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2, 12, 31),
      helpText: 'Needed by',
    );
    if (date != null && mounted) setState(() => followUpDue = date);
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
          const WellTrustAppBar(title: 'Add handover', showBack: true),
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
                          'Tell the next carer, and the office, what they need to know. You cannot change it after you save, so check it first.',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                    ),
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
                    label('What kind of handover?'),
                    requiredSegments(
                      HandoverKind.values,
                      kind,
                      (value) => value.label,
                      (value) => kind = value,
                    ),
                    label('How important is it?'),
                    requiredSegments(
                      HandoverPriority.values,
                      priority,
                      (value) => value.label,
                      (value) => priority = value,
                    ),
                    label('What does the next carer need to know?'),
                    GlobalTextField(
                      fieldName:
                          'For example: Harold ate very little at lunch. Check his sugar readings.',
                      keyBoardType: TextInputType.multiline,
                      textController: text,
                      minLines: 5,
                      maxLines: 7,
                      maxLength: 1000,
                      removeSpace: false,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) {
                        if (error != null) setState(() => error = null);
                      },
                    ),
                    addVerticalSpacing(2.84),
                    AppText(
                      text: 'More detail (optional)',
                      type: AppTextType.titleSmall,
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    label('How were they?'),
                    optionalSegments(
                      const ['Settled', 'Low', 'Anxious', 'Unwell'],
                      mood,
                      (value) => mood = value,
                    ),
                    label('Food and drink'),
                    optionalSegments(
                      const ['Good', 'Some', 'Little', 'Refused'],
                      eating,
                      (value) => eating = value,
                    ),
                    label('Medication'),
                    optionalSegments(
                      const [
                        'No issues',
                        'Refused or missed',
                        'Changed',
                        'Running low',
                      ],
                      medication,
                      (value) => medication = value,
                    ),
                    label('Skin and mobility'),
                    optionalSegments(
                      const ['No concerns', 'Concern'],
                      skin,
                      (value) => skin = value,
                    ),
                    label('Home and equipment'),
                    GlobalTextField(
                      fieldName: 'For example: bathroom light is out',
                      keyBoardType: TextInputType.text,
                      textController: home,
                      maxLength: 160,
                      isOptional: true,
                      removeSpace: false,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    label('Contact with family or others'),
                    GlobalTextField(
                      fieldName: 'For example: daughter phoned at 4pm',
                      keyBoardType: TextInputType.text,
                      textController: contacts,
                      maxLength: 160,
                      isOptional: true,
                      removeSpace: false,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    addVerticalSpacing(0.47),
                    Material(
                      color: AppColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CheckboxListTile(
                        value: followUp,
                        onChanged: (value) =>
                            setState(() => followUp = value ?? false),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        title: const AppText(
                          text: 'Someone needs to do something about this.',
                          type: AppTextType.bodySmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    label(
                      'Who should do it?',
                      help: 'Used when the box above is ticked.',
                    ),
                    requiredSegments(
                      const ['Next carer', 'Office', 'Anyone'],
                      forWhom,
                      (value) => value,
                      (value) => forWhom = value,
                    ),
                    label('Needed by (optional)'),
                    InkWell(
                      onTap: pickDueDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 54),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.line2,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: AppColors.muted,
                            ),
                            addHorizontalSpacing(2.56),
                            Expanded(
                              child: AppText(
                                text: followUpDue == null
                                    ? 'Choose a date'
                                    : DateFormat(
                                        'd MMMM yyyy',
                                      ).format(followUpDue!),
                                type: AppTextType.bodySmall,
                                color: followUpDue == null
                                    ? AppColors.muted
                                    : AppColors.ink,
                              ),
                            ),
                            if (followUpDue != null)
                              IconButton(
                                tooltip: 'Clear date',
                                onPressed: () =>
                                    setState(() => followUpDue = null),
                                icon: const Icon(Icons.close_rounded, size: 20),
                              ),
                          ],
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
                    DesignButton('Save handover', onPressed: save),
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

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _SegmentChip({
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
