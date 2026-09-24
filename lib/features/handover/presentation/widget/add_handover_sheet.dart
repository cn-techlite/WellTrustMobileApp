import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/state/provider/handover_provider.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';

class AddHandoverSheet extends ConsumerStatefulWidget {
  final String? clientId;

  const AddHandoverSheet({super.key, this.clientId});

  @override
  ConsumerState<AddHandoverSheet> createState() => _AddHandoverSheetState();
}

class _AddHandoverSheetState extends ConsumerState<AddHandoverSheet> {
  final text = TextEditingController();
  String? clientId;
  HandoverKind kind = HandoverKind.info;
  HandoverPriority priority = HandoverPriority.routine;
  bool followUp = false;
  String forWhom = 'Next carer';
  String? error;

  @override
  void initState() {
    super.initState();
    clientId = widget.clientId;
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void save() {
    if (clientId == null) return setState(() => error = 'Choose a person.');
    if (text.text.trim().isEmpty) {
      return setState(() => error = 'Write what the next carer needs to know.');
    }
    ref
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
            needsFollowUp: followUp,
            followUpFor: forWhom,
          ),
        );
    Navigator.pop(context);
  }

  Widget label(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      t,
      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
    ),
  );

  Widget seg<T>(
    List<T> opts,
    T value,
    String Function(T) name,
    ValueChanged<T> on,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final o in opts)
          ChoiceChip(
            label: Text(name(o)),
            selected: o == value,
            showCheckmark: false,
            onSelected: (_) => setState(() => on(o)),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: o == value ? AppColors.onPrimary : AppColors.ink,
            ),
            side: BorderSide(color: AppColors.line2, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      ],
    );
  }

  InputDecoration deco(String? hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.line2, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.line2, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add handover',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tell the next carer, and the office, what they need to know. You cannot change it after you save.',
              style: TextStyle(color: AppColors.muted),
            ),
            label('Who is it about?'),
            DropdownButtonFormField<String>(
              initialValue: clientId,
              decoration: deco('Choose a person'),
              items: [
                for (final c in handoverClients)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => clientId = v),
            ),
            label('What kind of handover?'),
            seg(HandoverKind.values, kind, (k) => k.label, (v) => kind = v),
            label('How important is it?'),
            seg(
              HandoverPriority.values,
              priority,
              (p) => p.label,
              (v) => priority = v,
            ),
            label('What does the next carer need to know?'),
            TextField(
              controller: text,
              minLines: 4,
              maxLines: 6,
              decoration: deco(
                'For example: Harold ate very little at lunch. Check his sugar readings.',
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: followUp,
              onChanged: (v) => setState(() => followUp = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              title: const Text('Someone needs to do something about this.'),
            ),
            if (followUp) ...[
              label('Who should do it?'),
              seg(
                const ['Next carer', 'Office', 'Anyone'],
                forWhom,
                (s) => s,
                (v) => forWhom = v,
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  error!,
                  style: TextStyle(
                    color: AppColors.rose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 22),
            DesignButton('Save handover', onPressed: save),
          ],
        ),
      ),
    );
  }
}
